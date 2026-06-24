namespace Sica.Domain.AccessControl;

/// <summary>Strongly-typed identifier for a <see cref="Circuit"/>.</summary>
public readonly record struct CircuitId(int Value)
{
    public override string ToString() => Value.ToString(System.Globalization.CultureInfo.InvariantCulture);
}
