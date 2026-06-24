using Sica.Application.Abstractions;

namespace Sica.Application.AccessControl.UpdateTerminalPolicy;

/// <summary>
/// RULE-007: replaces a terminal's complete access profile with the supplied
/// families and circuits. Empty collections lock the terminal down.
/// </summary>
public sealed record UpdateTerminalPolicyCommand(
    int TerminalId,
    IReadOnlyList<Guid> FamilyIds,
    IReadOnlyList<int> CircuitIds) : ICommand;
