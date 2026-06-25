using Microsoft.EntityFrameworkCore;
using Sica.Domain.Cards;

namespace Sica.Infrastructure.Persistence.Repositories;

internal sealed class SmartCardRepository(SicaDbContext context) : ISmartCardRepository
{
    private readonly SicaDbContext _context = context;

    public async Task<SmartCard?> GetByIdAsync(CardId id, CancellationToken cancellationToken = default)
        => await _context.SmartCards.FirstOrDefaultAsync(c => c.Id == id, cancellationToken);

    public async Task<SmartCard?> GetByCodeAsync(CardCode code, CancellationToken cancellationToken = default)
        => await _context.SmartCards.FirstOrDefaultAsync(c => c.Code == code, cancellationToken);

    public async Task<IReadOnlyList<SmartCard>> ListByTypeAsync(
        CardType type,
        CancellationToken cancellationToken = default)
        => await _context.SmartCards
            .AsNoTracking()
            .Where(c => c.Type == type)
            .ToListAsync(cancellationToken);

    public void Add(SmartCard card) => _context.SmartCards.Add(card);
}
