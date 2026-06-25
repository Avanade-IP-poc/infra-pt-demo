using Sica.Application.Abstractions;
using Sica.Domain.Iam;
using Sica.Shared;

namespace Sica.Application.Iam.AuthorizeTerminal;

/// <summary>
/// Handles <see cref="AuthorizeTerminalQuery"/> applying RULE-001: a terminal is
/// authorized only when it is registered (by hostname or IP) and active.
/// </summary>
public sealed class AuthorizeTerminalQueryHandler(ITerminalRepository terminals)
    : IQueryHandler<AuthorizeTerminalQuery, AuthorizeTerminalResult>
{
    private readonly ITerminalRepository _terminals =
        Guard.AgainstNull(terminals, nameof(terminals));

    public async Task<Result<AuthorizeTerminalResult>> HandleAsync(
        AuthorizeTerminalQuery query,
        CancellationToken cancellationToken = default)
    {
        var terminal = await _terminals.FindByHostnameOrIpAsync(
            query.Hostname,
            query.IpAddress,
            cancellationToken);

        if (terminal is null)
        {
            return IamErrors.TerminalNotRegistered;
        }

        if (!terminal.IsActive)
        {
            return IamErrors.TerminalInactive;
        }

        return new AuthorizeTerminalResult(terminal.Id.Value, terminal.Hostname);
    }
}
