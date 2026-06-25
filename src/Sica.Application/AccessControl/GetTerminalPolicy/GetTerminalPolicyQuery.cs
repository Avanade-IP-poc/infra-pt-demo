using Sica.Application.Abstractions;

namespace Sica.Application.AccessControl.GetTerminalPolicy;

/// <summary>Retrieves the access profile of a terminal (RULE-007).</summary>
public sealed record GetTerminalPolicyQuery(int TerminalId) : IQuery<TerminalPolicyDto>;

/// <summary>Read model for a terminal access profile.</summary>
public sealed record TerminalPolicyDto(
    int TerminalId,
    IReadOnlyList<Guid> FamilyIds,
    IReadOnlyList<int> CircuitIds);
