namespace Sica.Application.Iam.AuthorizeTerminal;

/// <summary>Result of a successful terminal authorization.</summary>
public sealed record AuthorizeTerminalResult(int TerminalId, string TerminalName);
