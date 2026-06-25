using Sica.Domain.Primitives;
using Sica.Shared;

namespace Sica.Domain.Cards;

/// <summary>
/// A smart-card logical code. The first character classifies the card type
/// (RULE-004) and determines whether it is eligible for SMI synchronization
/// (RULE-005). Stored upper-cased for consistent matching.
/// </summary>
public sealed class CardCode : ValueObject
{
    /// <summary>Prefixes eligible for synchronization from the SMI master (RULE-005).</summary>
    private static readonly HashSet<char> SyncablePrefixes = ['C', 'V', 'M', 'A', 'R'];

    private CardCode(string value) => Value = value;

    public string Value { get; }

    public char Prefix => Value[0];

    public static CardCode Create(string value)
    {
        Guard.AgainstNullOrWhiteSpace(value, nameof(value));
        return new CardCode(value.Trim().ToUpperInvariant());
    }

    /// <summary>RULE-004: derive the card type from the code prefix (default Visitor).</summary>
    public CardType ClassifyType() => Prefix switch
    {
        'V' => CardType.Visitor,
        'M' => CardType.Service,
        'C' or 'A' or 'R' or 'E' => CardType.Employee,
        _ => CardType.Visitor,
    };

    /// <summary>RULE-005: only specific prefixes are synchronized from the SMI master.</summary>
    public bool IsSyncable() => SyncablePrefixes.Contains(Prefix);

    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Value;
    }

    public override string ToString() => Value;
}
