namespace Sica.Domain.Iam;

/// <summary>Strongly-typed identifier for a <see cref="Terminal"/>.</summary>
public readonly record struct TerminalId(int Value)
{
    public override string ToString() => Value.ToString(System.Globalization.CultureInfo.InvariantCulture);
}
