namespace Sica.Application.Integration.Smi;

/// <summary>
/// Anti-Corruption Layer port over the legacy SMI master system. Translates the
/// legacy SOAP <c>SMIMethods</c> web service into clean, domain-agnostic DTOs so
/// the rest of the application never depends on the SOAP contract directly.
/// </summary>
public interface ISmiService
{
    /// <summary>Returns a smart card by its SMI identifier, or <c>null</c> if not found.</summary>
    Task<SmiSmartCard?> GetSmartCardByIdAsync(int smartCardId, CancellationToken cancellationToken = default);

    /// <summary>Returns the external smart cards known to the SMI master.</summary>
    Task<IReadOnlyList<SmiSmartCard>> GetExternalSmartCardsAsync(CancellationToken cancellationToken = default);

    /// <summary>Updates a smart card's expiration date and status in the SMI master.</summary>
    Task<bool> UpdateSmartCardAsync(
        int smartCardId,
        DateTime expirationDate,
        SmiSmartCardStatus status,
        CancellationToken cancellationToken = default);

    /// <summary>Returns the most recent access events for the given circuits.</summary>
    Task<IReadOnlyList<SmiAccessEvent>> GetLastCircuitEventsAsync(
        IReadOnlyCollection<int> circuitIds,
        int lastHours,
        int maxRecords,
        CancellationToken cancellationToken = default);

    /// <summary>Returns all access families known to the SMI master.</summary>
    Task<IReadOnlyList<SmiFamily>> GetFamiliesAsync(CancellationToken cancellationToken = default);

    /// <summary>Returns all access circuits known to the SMI master.</summary>
    Task<IReadOnlyList<SmiCircuit>> GetCircuitsAsync(CancellationToken cancellationToken = default);

    /// <summary>Returns the current occupant count per geographical zone.</summary>
    Task<IReadOnlyList<SmiZone>> CountUsersByZoneAsync(CancellationToken cancellationToken = default);
}
