namespace Sica.Domain.Cards;

/// <summary>Lifecycle status of a smart card.</summary>
public enum CardStatus
{
    Active = 0,
    Inactive = 1,
    Lost = 2,
    Stolen = 3,
    Destroyed = 4,
}
