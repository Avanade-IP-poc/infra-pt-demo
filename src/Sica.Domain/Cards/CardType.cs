namespace Sica.Domain.Cards;

/// <summary>Classification of a smart card, derived from its code prefix (RULE-004).</summary>
public enum CardType
{
    Employee = 0,
    Visitor = 1,
    Service = 2,
}
