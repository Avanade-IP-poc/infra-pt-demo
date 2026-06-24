namespace Sica.Infrastructure;

/// <summary>
/// Marker type used to anchor assembly references for dependency injection
/// registration. Concrete persistence and integration services are added in
/// later Bolts (EF Core DbContext, SMI anti-corruption layer).
/// </summary>
public static class InfrastructureAssemblyMarker;
