namespace Sica.Application.Abstractions;

/// <summary>Commits pending aggregate changes to the underlying store as a single unit.</summary>
public interface IUnitOfWork
{
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
