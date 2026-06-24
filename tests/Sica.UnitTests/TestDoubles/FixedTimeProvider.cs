namespace Sica.UnitTests.TestDoubles;

/// <summary>Deterministic <see cref="TimeProvider"/> for tests (avoids external package).</summary>
public sealed class FixedTimeProvider(DateTimeOffset now) : TimeProvider
{
    public override DateTimeOffset GetUtcNow() => now;
}
