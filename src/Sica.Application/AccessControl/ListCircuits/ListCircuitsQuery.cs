using Sica.Application.Abstractions;

namespace Sica.Application.AccessControl.ListCircuits;

/// <summary>Lists all physical access circuits.</summary>
public sealed record ListCircuitsQuery : IQuery<IReadOnlyList<CircuitDto>>;

/// <summary>Read model for a circuit.</summary>
public sealed record CircuitDto(int Id, string Name, int? CircuitGroupId, int? SmiCircuitId);
