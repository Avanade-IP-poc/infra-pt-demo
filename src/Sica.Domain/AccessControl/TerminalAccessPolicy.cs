using Sica.Domain.Primitives;
using Sica.Shared;

namespace Sica.Domain.AccessControl;

/// <summary>
/// The access profile of a terminal: which access families and circuits are
/// authorized. Maps the legacy <c>tblFamiliasTerminal</c> / <c>tblCircuitosTerminal</c>
/// relations. RULE-007: updating the profile is a complete replacement of the
/// previous configuration (delete + insert), applied atomically by the persistence
/// unit of work.
/// </summary>
public sealed class TerminalAccessPolicy : Entity<TerminalAccessPolicyId>, IAggregateRoot
{
    private readonly List<Guid> _familyIds;
    private readonly List<int> _circuitIds;

    private TerminalAccessPolicy(
        TerminalAccessPolicyId id,
        int terminalId,
        IEnumerable<Guid> familyIds,
        IEnumerable<int> circuitIds)
        : base(id)
    {
        TerminalId = terminalId;
        _familyIds = [.. familyIds];
        _circuitIds = [.. circuitIds];
    }

    public int TerminalId { get; private set; }

    public IReadOnlyCollection<Guid> FamilyIds => _familyIds.AsReadOnly();

    public IReadOnlyCollection<int> CircuitIds => _circuitIds.AsReadOnly();

    public static TerminalAccessPolicy Create(int terminalId)
    {
        Guard.AgainstNegativeOrZero(terminalId, nameof(terminalId));

        return new TerminalAccessPolicy(TerminalAccessPolicyId.New(), terminalId, [], []);
    }

    /// <summary>
    /// RULE-007: replaces the entire access profile with the supplied families and
    /// circuits. Passing empty collections clears all permissions (terminal locked
    /// down). Duplicates are ignored.
    /// </summary>
    public void ReplaceRules(IReadOnlyCollection<Guid> familyIds, IReadOnlyCollection<int> circuitIds)
    {
        Guard.AgainstNull(familyIds, nameof(familyIds));
        Guard.AgainstNull(circuitIds, nameof(circuitIds));

        _familyIds.Clear();
        _circuitIds.Clear();
        _familyIds.AddRange(familyIds.Distinct());
        _circuitIds.AddRange(circuitIds.Distinct());
    }
}
