using Sica.Application.Abstractions;
using Sica.Application.Integration.Smi;
using Sica.Shared;

namespace Sica.Application.Monitoring.CountUsersByZone;

/// <summary>Projects the SMI zone occupancy snapshot into a clean read model.</summary>
public sealed class CountUsersByZoneQueryHandler(ISmiService smi)
    : IQueryHandler<CountUsersByZoneQuery, IReadOnlyList<ZoneOccupancyDto>>
{
    private readonly ISmiService _smi = Guard.AgainstNull(smi, nameof(smi));

    public async Task<Result<IReadOnlyList<ZoneOccupancyDto>>> HandleAsync(
        CountUsersByZoneQuery query,
        CancellationToken cancellationToken = default)
    {
        var zones = await _smi.CountUsersByZoneAsync(cancellationToken);

        IReadOnlyList<ZoneOccupancyDto> result = zones
            .Select(z => new ZoneOccupancyDto(z.Id, z.Label, z.UserCount))
            .ToList();

        return Result.Success(result);
    }
}
