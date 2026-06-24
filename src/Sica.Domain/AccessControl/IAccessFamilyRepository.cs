namespace Sica.Domain.AccessControl;

/// <summary>Persistence port for the <see cref="AccessFamily"/> aggregate.</summary>
public interface IAccessFamilyRepository
{
    Task<AccessFamily?> GetByIdAsync(AccessFamilyId id, CancellationToken cancellationToken = default);

    Task<AccessFamily?> GetByNameAsync(string name, CancellationToken cancellationToken = default);

    Task<IReadOnlyList<AccessFamily>> ListAsync(CancellationToken cancellationToken = default);

    void Add(AccessFamily family);
}
