using Microsoft.EntityFrameworkCore;
using Sica.Domain.AccessControl;

namespace Sica.Infrastructure.Persistence.Repositories;

internal sealed class CircuitRepository(SicaDbContext context) : ICircuitRepository
{
    private readonly SicaDbContext _context = context;

    public async Task<Circuit?> GetByIdAsync(CircuitId id, CancellationToken cancellationToken = default)
        => await _context.Circuits.FirstOrDefaultAsync(c => c.Id == id, cancellationToken);

    public async Task<IReadOnlyList<Circuit>> ListAsync(CancellationToken cancellationToken = default)
        => await _context.Circuits.AsNoTracking().ToListAsync(cancellationToken);

    public void Add(Circuit circuit) => _context.Circuits.Add(circuit);
}
