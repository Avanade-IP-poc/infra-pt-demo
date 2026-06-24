using Sica.Domain.Primitives;
using Sica.Shared;

namespace Sica.Domain.AccessControl;

/// <summary>
/// A group of users sharing the same physical-access permissions. Maps the legacy
/// <c>tblFamilias</c> table. Membership references users by identifier (the User
/// aggregate is owned by a separate context).
/// </summary>
public sealed class AccessFamily : Entity<AccessFamilyId>, IAggregateRoot
{
    private readonly List<Guid> _memberUserIds;

    private AccessFamily(AccessFamilyId id, string name, int? smiFamilyId, IEnumerable<Guid> members)
        : base(id)
    {
        Name = name;
        SmiFamilyId = smiFamilyId;
        _memberUserIds = [.. members];
    }

    public string Name { get; private set; }

    /// <summary>Identifier of the matching family in the SMI master, when synchronized.</summary>
    public int? SmiFamilyId { get; private set; }

    public IReadOnlyCollection<Guid> MemberUserIds => _memberUserIds.AsReadOnly();

    public static AccessFamily Create(string name, int? smiFamilyId = null)
    {
        Guard.AgainstNullOrWhiteSpace(name, nameof(name));

        return new AccessFamily(AccessFamilyId.New(), name.Trim(), smiFamilyId, []);
    }

    public void Rename(string name)
    {
        Guard.AgainstNullOrWhiteSpace(name, nameof(name));
        Name = name.Trim();
    }

    /// <summary>Replaces the whole membership set with the supplied users.</summary>
    public void ReplaceMembers(IReadOnlyCollection<Guid> userIds)
    {
        Guard.AgainstNull(userIds, nameof(userIds));

        _memberUserIds.Clear();
        _memberUserIds.AddRange(userIds.Distinct());
    }
}
