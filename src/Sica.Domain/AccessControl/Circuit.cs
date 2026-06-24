using Sica.Domain.Primitives;
using Sica.Shared;

namespace Sica.Domain.AccessControl;

/// <summary>
/// A physical access point (door, gate, turnstile). Maps the legacy
/// <c>tblCircuitos</c> table and may form a hierarchy via <see cref="CircuitGroupId"/>.
/// </summary>
public sealed class Circuit : Entity<CircuitId>, IAggregateRoot
{
    private Circuit(CircuitId id, string name, int? circuitGroupId, int? smiCircuitId)
        : base(id)
    {
        Name = name;
        CircuitGroupId = circuitGroupId;
        SmiCircuitId = smiCircuitId;
    }

    public string Name { get; private set; }

    /// <summary>Self-referencing parent circuit identifier, when this circuit is grouped.</summary>
    public int? CircuitGroupId { get; private set; }

    /// <summary>Identifier of the matching circuit in the SMI master, when synchronized.</summary>
    public int? SmiCircuitId { get; private set; }

    public static Circuit Register(
        CircuitId id,
        string name,
        int? circuitGroupId = null,
        int? smiCircuitId = null)
    {
        Guard.AgainstNullOrWhiteSpace(name, nameof(name));

        return new Circuit(id, name.Trim(), circuitGroupId, smiCircuitId);
    }

    public void Rename(string name)
    {
        Guard.AgainstNullOrWhiteSpace(name, nameof(name));
        Name = name.Trim();
    }
}
