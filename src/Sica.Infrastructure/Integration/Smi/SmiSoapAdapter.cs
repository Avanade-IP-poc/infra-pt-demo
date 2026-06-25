using Microsoft.Extensions.Options;
using Sica.Application.Integration.Smi;

namespace Sica.Infrastructure.Integration.Smi;

/// <summary>
/// Production <see cref="ISmiService"/> adapter targeting the legacy SMI SOAP web
/// service (<c>SMIMethods.asmx</c>).
/// </summary>
/// <remarks>
/// The real WSDL has no formal specification and the endpoint must be captured from
/// the legacy environment (see plan.md §4.4). Until the connected service / SOAP
/// client is generated, every operation fails fast with a descriptive error so the
/// system never silently falls back to stale data. Wire <c>Smi:Mode = Mock</c> for
/// local/test scenarios.
/// </remarks>
public sealed class SmiSoapAdapter : ISmiService
{
    private readonly string _endpoint;

    public SmiSoapAdapter(IOptions<SmiOptions> options)
    {
        var endpoint = options.Value.Endpoint;
        if (string.IsNullOrWhiteSpace(endpoint))
        {
            throw new InvalidOperationException(
                "Smi:Endpoint must be configured when Smi:Mode is 'Soap'.");
        }

        _endpoint = endpoint;
    }

    public Task<SmiSmartCard?> GetSmartCardByIdAsync(int smartCardId, CancellationToken cancellationToken = default)
        => throw NotWired(nameof(GetSmartCardByIdAsync));

    public Task<IReadOnlyList<SmiSmartCard>> GetExternalSmartCardsAsync(CancellationToken cancellationToken = default)
        => throw NotWired(nameof(GetExternalSmartCardsAsync));

    public Task<bool> UpdateSmartCardAsync(
        int smartCardId,
        DateTime expirationDate,
        SmiSmartCardStatus status,
        CancellationToken cancellationToken = default)
        => throw NotWired(nameof(UpdateSmartCardAsync));

    public Task<IReadOnlyList<SmiAccessEvent>> GetLastCircuitEventsAsync(
        IReadOnlyCollection<int> circuitIds,
        int lastHours,
        int maxRecords,
        CancellationToken cancellationToken = default)
        => throw NotWired(nameof(GetLastCircuitEventsAsync));

    public Task<IReadOnlyList<SmiFamily>> GetFamiliesAsync(CancellationToken cancellationToken = default)
        => throw NotWired(nameof(GetFamiliesAsync));

    public Task<IReadOnlyList<SmiCircuit>> GetCircuitsAsync(CancellationToken cancellationToken = default)
        => throw NotWired(nameof(GetCircuitsAsync));

    public Task<IReadOnlyList<SmiZone>> CountUsersByZoneAsync(CancellationToken cancellationToken = default)
        => throw NotWired(nameof(CountUsersByZoneAsync));

    private NotSupportedException NotWired(string operation) => new(
        $"SMI SOAP operation '{operation}' is not wired yet (endpoint '{_endpoint}'). " +
        "Generate the SOAP client from the captured WSDL before enabling Smi:Mode = Soap.");
}
