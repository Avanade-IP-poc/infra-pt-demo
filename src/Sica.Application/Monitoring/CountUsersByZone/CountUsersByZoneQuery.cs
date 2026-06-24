using Sica.Application.Abstractions;

namespace Sica.Application.Monitoring.CountUsersByZone;

/// <summary>Counts the current occupants of every geographical zone.</summary>
public sealed record CountUsersByZoneQuery : IQuery<IReadOnlyList<ZoneOccupancyDto>>;

/// <summary>Read model for a zone's current occupancy.</summary>
public sealed record ZoneOccupancyDto(int ZoneId, string ZoneName, int UserCount);
