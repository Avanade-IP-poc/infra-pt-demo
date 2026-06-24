using Sica.Application.Abstractions;
using Sica.Domain.AccessControl;
using Sica.Shared;

namespace Sica.Application.AccessControl.ListCircuits;

/// <summary>Returns every circuit projected to <see cref="CircuitDto"/>.</summary>
public sealed class ListCircuitsQueryHandler(ICircuitRepository circuits)
    : IQueryHandler<ListCircuitsQuery, IReadOnlyList<CircuitDto>>
{
    private readonly ICircuitRepository _circuits = Guard.AgainstNull(circuits, nameof(circuits));

    public async Task<Result<IReadOnlyList<CircuitDto>>> HandleAsync(
        ListCircuitsQuery query,
        CancellationToken cancellationToken = default)
    {
        var circuits = await _circuits.ListAsync(cancellationToken);

        IReadOnlyList<CircuitDto> result = circuits
            .Select(c => new CircuitDto(c.Id.Value, c.Name, c.CircuitGroupId, c.SmiCircuitId))
            .ToList();

        return Result.Success(result);
    }
}
