using Microsoft.EntityFrameworkCore;
using Sica.Domain.AccessControl;

namespace Sica.Infrastructure.Persistence.Repositories;

internal sealed class AccessFamilyRepository(SicaDbContext context) : IAccessFamilyRepository
{
    private readonly SicaDbContext _context = context;

    public async Task<AccessFamily?> GetByIdAsync(
        AccessFamilyId id,
        CancellationToken cancellationToken = default)
        => await _context.AccessFamilies.FirstOrDefaultAsync(f => f.Id == id, cancellationToken);

    public async Task<AccessFamily?> GetByNameAsync(
        string name,
        CancellationToken cancellationToken = default)
        => await _context.AccessFamilies.FirstOrDefaultAsync(f => f.Name == name, cancellationToken);

    public async Task<IReadOnlyList<AccessFamily>> ListAsync(CancellationToken cancellationToken = default)
        => await _context.AccessFamilies.AsNoTracking().ToListAsync(cancellationToken);

    public void Add(AccessFamily family) => _context.AccessFamilies.Add(family);
}
