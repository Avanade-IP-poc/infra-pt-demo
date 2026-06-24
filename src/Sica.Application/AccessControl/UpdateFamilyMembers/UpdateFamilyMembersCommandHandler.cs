using Sica.Application.Abstractions;
using Sica.Domain.AccessControl;
using Sica.Shared;

namespace Sica.Application.AccessControl.UpdateFamilyMembers;

/// <summary>Replaces an access family's membership set atomically.</summary>
public sealed class UpdateFamilyMembersCommandHandler(
    IAccessFamilyRepository families,
    IUnitOfWork unitOfWork)
    : ICommandHandler<UpdateFamilyMembersCommand>
{
    private readonly IAccessFamilyRepository _families = Guard.AgainstNull(families, nameof(families));
    private readonly IUnitOfWork _unitOfWork = Guard.AgainstNull(unitOfWork, nameof(unitOfWork));

    public async Task<Result> HandleAsync(
        UpdateFamilyMembersCommand command,
        CancellationToken cancellationToken = default)
    {
        var family = await _families.GetByIdAsync(new AccessFamilyId(command.FamilyId), cancellationToken);
        if (family is null)
        {
            return Result.Failure(AccessControlErrors.FamilyNotFound);
        }

        family.ReplaceMembers(command.UserIds ?? []);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
