using Sica.Domain.Primitives;
using Sica.Shared;

namespace Sica.Domain.Cards;

/// <summary>
/// Smart card aggregate. Maps the legacy <c>tblCartoes</c> table. The card type is
/// derived from the code prefix (RULE-004); synchronization from the SMI master is
/// restricted to syncable prefixes (RULE-005).
/// </summary>
public sealed class SmartCard : Entity<CardId>, IAggregateRoot
{
    private SmartCard(
        CardId id,
        CardCode code,
        CardType type,
        string? label,
        CardStatus status,
        DateTime? expirationDate,
        Guid? ownerId,
        int? smiCardId)
        : base(id)
    {
        Code = code;
        Type = type;
        Label = label;
        Status = status;
        ExpirationDate = expirationDate;
        OwnerId = ownerId;
        SmiCardId = smiCardId;
    }

    public CardCode Code { get; private set; }

    public CardType Type { get; private set; }

    public string? Label { get; private set; }

    public CardStatus Status { get; private set; }

    public DateTime? ExpirationDate { get; private set; }

    public Guid? OwnerId { get; private set; }

    /// <summary>Identifier of the matching card in the SMI master, when synchronized.</summary>
    public int? SmiCardId { get; private set; }

    public bool IsActive => Status == CardStatus.Active;

    /// <summary>Creates a new card, classifying its type from the code prefix (RULE-004).</summary>
    public static SmartCard Create(
        CardCode code,
        string? label = null,
        CardStatus status = CardStatus.Active,
        DateTime? expirationDate = null,
        Guid? ownerId = null,
        int? smiCardId = null)
    {
        Guard.AgainstNull(code, nameof(code));

        return new SmartCard(
            CardId.New(),
            code,
            code.ClassifyType(),
            label,
            status,
            expirationDate,
            ownerId,
            smiCardId);
    }

    /// <summary>
    /// RULE-005: synchronizes the card from the SMI master. Returns a failure when the
    /// code prefix is not eligible for synchronization.
    /// </summary>
    public static Result<SmartCard> SyncFromMaster(
        CardCode code,
        int smiCardId,
        string? label,
        CardStatus status,
        DateTime? expirationDate)
    {
        Guard.AgainstNull(code, nameof(code));

        if (!code.IsSyncable())
        {
            return new Error(
                "Card.NotSyncable",
                $"El prefijo '{code.Prefix}' no es sincronizable desde el sistema maestro.");
        }

        return Create(code, label, status, expirationDate, ownerId: null, smiCardId);
    }

    public void Activate() => Status = CardStatus.Active;

    public void Deactivate() => Status = CardStatus.Inactive;

    public void ChangeStatus(CardStatus status) => Status = status;
}
