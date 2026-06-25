using Sica.Application.Abstractions;
using Sica.Domain.AccessControl;
using Sica.Shared;

namespace Sica.Application.AccessControl.ListAccessFamilies;

/// <summary>Returns every access family projected to <see cref="AccessFamilyDto"/>.</summary>
public sealed class ListAccessFamiliesQueryHandler(IAccessFamilyRepository families)
    : IQueryHandler<ListAccessFamiliesQuery, IReadOnlyList<AccessFamilyDto>>
{
    private readonly IAccessFamilyRepository _families = Guard.AgainstNull(families, nameof(families));

    public async Task<Result<IReadOnlyList<AccessFamilyDto>>> HandleAsync(
        ListAccessFamiliesQuery query,
        CancellationToken cancellationToken = default)
    {
        var families = await _families.ListAsync(cancellationToken);

        IReadOnlyList<AccessFamilyDto> result = families
            .Select(f => new AccessFamilyDto(
                f.Id.Value,
                f.Name,
                f.SmiFamilyId,
                f.MemberUserIds.ToList()))
            .ToList();

        return Result.Success(result);
    }
}
