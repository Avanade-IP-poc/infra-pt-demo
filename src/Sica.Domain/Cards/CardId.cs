namespace Sica.Domain.Cards;

/// <summary>Strongly-typed identifier for a <see cref="SmartCard"/>.</summary>
public readonly record struct CardId(Guid Value)
{
    public static CardId New() => new(Guid.NewGuid());

    public override string ToString() => Value.ToString();
}
