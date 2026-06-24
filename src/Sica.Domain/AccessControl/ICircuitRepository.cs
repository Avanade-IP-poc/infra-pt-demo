namespace Sica.Domain.AccessControl;

/// <summary>Persistence port for the <see cref="Circuit"/> aggregate.</summary>
public interface ICircuitRepository
{
    Task<Circuit?> GetByIdAsync(CircuitId id, CancellationToken cancellationToken = default);

    Task<IReadOnlyList<Circuit>> ListAsync(CancellationToken cancellationToken = default);

    void Add(Circuit circuit);
}
