using Microsoft.EntityFrameworkCore;
using Sica.Domain.Iam;

namespace Sica.Infrastructure.Persistence.Repositories;

internal sealed class TerminalRepository(SicaDbContext context) : ITerminalRepository
{
    private readonly SicaDbContext _context = context;

    public async Task<Terminal?> FindByHostnameOrIpAsync(
        string? hostname,
        string? ipAddress,
        CancellationToken cancellationToken = default)
    {
        var normalizedHostname = string.IsNullOrWhiteSpace(hostname)
            ? null
            : hostname.Trim().ToUpperInvariant();

        var normalizedIp = string.IsNullOrWhiteSpace(ipAddress) ? null : ipAddress.Trim();

        return await _context.Terminals
            .AsNoTracking()
            .FirstOrDefaultAsync(
                t => (normalizedHostname != null && t.Hostname == normalizedHostname)
                    || (normalizedIp != null && t.IpAddress == normalizedIp),
                cancellationToken);
    }
}
