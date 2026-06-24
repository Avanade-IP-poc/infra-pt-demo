using Sica.Application.Abstractions;

namespace Sica.Application.Iam.AuthorizeTerminal;

/// <summary>
/// Query to authorize a terminal by hostname or IP address (RULE-001).
/// </summary>
public sealed record AuthorizeTerminalQuery(string? Hostname, string? IpAddress)
    : IQuery<AuthorizeTerminalResult>;
