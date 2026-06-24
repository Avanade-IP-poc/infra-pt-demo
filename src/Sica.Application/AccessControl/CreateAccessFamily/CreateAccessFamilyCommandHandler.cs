using Sica.Application.Abstractions;
using Sica.Domain.AccessControl;
using Sica.Shared;

namespace Sica.Application.AccessControl.CreateAccessFamily;

/// <summary>Creates an access family, rejecting duplicate names.</summary>
public sealed class CreateAccessFamilyCommandHandler(
    IAccessFamilyRepository families,
    IUnitOfWork unitOfWork)
    : ICommandHandler<CreateAccessFamilyCommand, Guid>
{
    private readonly IAccessFamilyRepository _families = Guard.AgainstNull(families, nameof(families));
    private readonly IUnitOfWork _unitOfWork = Guard.AgainstNull(unitOfWork, nameof(unitOfWork));

    public async Task<Result<Guid>> HandleAsync(
        CreateAccessFamilyCommand command,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(command.Name))
        {
            return Error.Validation("El nombre de la familia es obligatorio.");
        }

        var existing = await _families.GetByNameAsync(command.Name.Trim(), cancellationToken);
        if (existing is not null)
        {
            return AccessControlErrors.FamilyNameConflict;
        }

        var family = AccessFamily.Create(command.Name, command.SmiFamilyId);
        _families.Add(family);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return family.Id.Value;
    }
}
