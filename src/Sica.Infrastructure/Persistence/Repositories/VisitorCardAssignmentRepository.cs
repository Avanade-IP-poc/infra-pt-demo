using Microsoft.EntityFrameworkCore;
using Sica.Domain.Cards;

namespace Sica.Infrastructure.Persistence.Repositories;

internal sealed class VisitorCardAssignmentRepository(SicaDbContext context)
    : IVisitorCardAssignmentRepository
{
    private readonly SicaDbContext _context = context;

    public async Task<VisitorCardAssignment?> GetByIdAsync(
        VisitorCardAssignmentId id,
        CancellationToken cancellationToken = default)
        => await _context.VisitorCardAssignments
            .FirstOrDefaultAsync(a => a.Id == id, cancellationToken);

    public async Task<VisitorCardAssignment?> GetLatestForCardAsync(
        CardId cardId,
        CancellationToken cancellationToken = default)
        => await _context.VisitorCardAssignments
            .AsNoTracking()
            .Where(a => a.CardId == cardId)
            .OrderByDescending(a => a.EntryTime)
            .FirstOrDefaultAsync(cancellationToken);

    public async Task<IReadOnlyCollection<CardId>> GetCardIdsInUseAsync(
        CancellationToken cancellationToken = default)
        => await _context.VisitorCardAssignments
            .AsNoTracking()
            .Where(a => a.ExitTime == null)
            .Select(a => a.CardId)
            .Distinct()
            .ToListAsync(cancellationToken);

    public void Add(VisitorCardAssignment assignment)
        => _context.VisitorCardAssignments.Add(assignment);
}
