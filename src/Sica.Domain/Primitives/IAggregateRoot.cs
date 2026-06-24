namespace Sica.Domain.Primitives;

/// <summary>
/// Marks an entity as the root of an aggregate — the only entry point for
/// mutations within the aggregate's consistency boundary.
/// </summary>
public interface IAggregateRoot;
