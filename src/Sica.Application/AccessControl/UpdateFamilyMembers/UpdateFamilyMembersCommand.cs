using Sica.Application.Abstractions;

namespace Sica.Application.AccessControl.UpdateFamilyMembers;

/// <summary>Replaces the membership of an access family with the supplied users.</summary>
public sealed record UpdateFamilyMembersCommand(
    Guid FamilyId,
    IReadOnlyList<Guid> UserIds) : ICommand;
