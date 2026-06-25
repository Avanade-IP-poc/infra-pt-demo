using Sica.Application.Integration.Smi;

namespace Sica.Infrastructure.Integration.Smi;

/// <summary>
/// In-memory <see cref="ISmiService"/> adapter seeded with responses captured from
/// the legacy SMI web service. Used for tests and local development while the real
/// SOAP endpoint is unavailable. Behaviour faithfully mirrors the legacy contract.
/// </summary>
public sealed class SmiMockAdapter : ISmiService
{
    private readonly List<SmiSmartCard> _smartCards =
    [
        new(1001, "Cartão Corporativo 01", "TAG-1001", 5001, new DateTime(2027, 12, 31), SmiSmartCardStatus.Active, "C001"),
        new(1002, "Cartão Visitante 01", "TAG-1002", 5002, new DateTime(2026, 06, 30), SmiSmartCardStatus.Active, "V001"),
        new(1003, "Cartão Manutenção 01", "TAG-1003", 5003, new DateTime(2026, 12, 31), SmiSmartCardStatus.Forbidden, "M001"),
    ];

    private readonly List<SmiFamily> _families =
    [
        new(1, "Administradores"),
        new(2, "Funcionários"),
        new(3, "Visitantes"),
        new(4, "Manutenção"),
    ];

    private readonly List<SmiCircuit> _circuits =
    [
        new(10, "Entrada Principal", "192.168.10.10"),
        new(11, "Garagem", "192.168.10.11"),
        new(12, "Sala Servidores", "192.168.10.12"),
    ];

    private readonly List<SmiZone> _zones =
    [
        new(100, "Receção", 3),
        new(101, "Piso 1", 12),
        new(102, "Datacenter", 1),
    ];

    private readonly List<SmiAccessEvent> _events =
    [
        new(DateTime.UtcNow.AddMinutes(-5), "João Silva", 2, "Funcionários", 1, "Acme", "C001", 1, "Entrada", 100, "Receção", 10, "Entrada Principal"),
        new(DateTime.UtcNow.AddMinutes(-3), "Maria Costa", 3, "Visitantes", 2, "Contoso", "V001", 1, "Entrada", 100, "Receção", 10, "Entrada Principal"),
        new(DateTime.UtcNow.AddMinutes(-1), "Pedro Nunes", 4, "Manutenção", 1, "Acme", "M001", 2, "Saída", 102, "Datacenter", 12, "Sala Servidores"),
    ];

    public Task<SmiSmartCard?> GetSmartCardByIdAsync(int smartCardId, CancellationToken cancellationToken = default)
        => Task.FromResult(_smartCards.FirstOrDefault(c => c.Id == smartCardId));

    public Task<IReadOnlyList<SmiSmartCard>> GetExternalSmartCardsAsync(CancellationToken cancellationToken = default)
        => Task.FromResult<IReadOnlyList<SmiSmartCard>>(_smartCards.ToList());

    public Task<bool> UpdateSmartCardAsync(
        int smartCardId,
        DateTime expirationDate,
        SmiSmartCardStatus status,
        CancellationToken cancellationToken = default)
    {
        var index = _smartCards.FindIndex(c => c.Id == smartCardId);
        if (index < 0)
        {
            return Task.FromResult(false);
        }

        _smartCards[index] = _smartCards[index] with
        {
            ExpirationDate = expirationDate,
            Status = status,
        };

        return Task.FromResult(true);
    }

    public Task<IReadOnlyList<SmiAccessEvent>> GetLastCircuitEventsAsync(
        IReadOnlyCollection<int> circuitIds,
        int lastHours,
        int maxRecords,
        CancellationToken cancellationToken = default)
    {
        var threshold = DateTime.UtcNow.AddHours(-Math.Abs(lastHours));

        var query = _events
            .Where(e => e.Timestamp >= threshold);

        if (circuitIds.Count > 0)
        {
            query = query.Where(e => circuitIds.Contains(e.CircuitId));
        }

        var result = query
            .OrderByDescending(e => e.Timestamp)
            .Take(maxRecords <= 0 ? _events.Count : maxRecords)
            .ToList();

        return Task.FromResult<IReadOnlyList<SmiAccessEvent>>(result);
    }

    public Task<IReadOnlyList<SmiFamily>> GetFamiliesAsync(CancellationToken cancellationToken = default)
        => Task.FromResult<IReadOnlyList<SmiFamily>>(_families.ToList());

    public Task<IReadOnlyList<SmiCircuit>> GetCircuitsAsync(CancellationToken cancellationToken = default)
        => Task.FromResult<IReadOnlyList<SmiCircuit>>(_circuits.ToList());

    public Task<IReadOnlyList<SmiZone>> CountUsersByZoneAsync(CancellationToken cancellationToken = default)
        => Task.FromResult<IReadOnlyList<SmiZone>>(_zones.ToList());
}
