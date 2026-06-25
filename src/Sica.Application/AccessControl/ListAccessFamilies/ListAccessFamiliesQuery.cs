using Sica.Application.Abstractions;

namespace Sica.Application.AccessControl.ListAccessFamilies;

/// <summary>Lists all access families with their membership.</summary>
public sealed record ListAccessFamiliesQuery : IQuery<IReadOnlyList<AccessFamilyDto>>;

/// <summary>Read model for an access family.</summary>
public sealed record AccessFamilyDto(
    Guid Id,
    string Name,
    int? SmiFamilyId,
    IReadOnlyList<Guid> MemberUserIds);
