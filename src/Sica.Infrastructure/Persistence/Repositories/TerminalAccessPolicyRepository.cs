using Microsoft.EntityFrameworkCore;
using Sica.Domain.AccessControl;

namespace Sica.Infrastructure.Persistence.Repositories;

internal sealed class TerminalAccessPolicyRepository(SicaDbContext context)
    : ITerminalAccessPolicyRepository
{
    private readonly SicaDbContext _context = context;

    public async Task<TerminalAccessPolicy?> GetByTerminalIdAsync(
        int terminalId,
        CancellationToken cancellationToken = default)
        => await _context.TerminalAccessPolicies
            .FirstOrDefaultAsync(p => p.TerminalId == terminalId, cancellationToken);

    public void Add(TerminalAccessPolicy policy) => _context.TerminalAccessPolicies.Add(policy);
}
