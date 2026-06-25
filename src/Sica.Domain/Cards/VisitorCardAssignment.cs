using Sica.Domain.Primitives;
using Sica.Shared;

namespace Sica.Domain.Cards;

/// <summary>Strongly-typed identifier for a <see cref="VisitorCardAssignment"/>.</summary>
public readonly record struct VisitorCardAssignmentId(Guid Value)
{
    public static VisitorCardAssignmentId New() => new(Guid.NewGuid());

    public override string ToString() => Value.ToString();
}

/// <summary>
/// Assignment of a visitor smart card to a visitor. Governs availability (RULE-008)
/// and required-data validation (RULE-009). Maps the legacy <c>tblVisitantes</c> table.
/// </summary>
public sealed class VisitorCardAssignment : Entity<VisitorCardAssignmentId>, IAggregateRoot
{
    private VisitorCardAssignment(
        VisitorCardAssignmentId id,
        CardId cardId,
        Guid visitorId,
        string company,
        string? visitedEntity,
        string? vehiclePlate,
        IReadOnlyCollection<Guid> accessFamilyIds,
        DateTime validFrom,
        DateTime validUntil,
        DateTime entryTime)
        : base(id)
    {
        CardId = cardId;
        VisitorId = visitorId;
        Company = company;
        VisitedEntity = visitedEntity;
        VehiclePlate = vehiclePlate;
        _accessFamilyIds = [.. accessFamilyIds];
        ValidFrom = validFrom;
        ValidUntil = validUntil;
        EntryTime = entryTime;
    }

    private readonly List<Guid> _accessFamilyIds;

    public CardId CardId { get; private set; }

    public Guid VisitorId { get; private set; }

    public string Company { get; private set; }

    public string? VisitedEntity { get; private set; }

    public string? VehiclePlate { get; private set; }

    public IReadOnlyCollection<Guid> AccessFamilyIds => _accessFamilyIds.AsReadOnly();

    public DateTime ValidFrom { get; private set; }

    public DateTime ValidUntil { get; private set; }

    public DateTime? EntryTime { get; private set; }

    public DateTime? ExitTime { get; private set; }

    /// <summary>RULE-008: an assignment is completed (card freed) once an exit is recorded.</summary>
    public bool IsCompleted => ExitTime is not null;

    /// <summary>
    /// RULE-009: assigns a visitor card after validating that the card, visitor
    /// identification and at least one access family are present. Records the entry
    /// timestamp on success.
    /// </summary>
    public static Result<VisitorCardAssignment> Assign(
        CardId cardId,
        Guid visitorId,
        string? company,
        string? visitedEntity,
        string? vehiclePlate,
        IReadOnlyCollection<Guid> accessFamilyIds,
        DateTime validFrom,
        DateTime validUntil,
        DateTime entryTime)
    {
        if (accessFamilyIds is null || accessFamilyIds.Count == 0)
        {
            return new Error("VisitorCard.NoFamily", "Seleccione el acceso pretendido.");
        }

        if (string.IsNullOrWhiteSpace(company) && string.IsNullOrWhiteSpace(visitedEntity))
        {
            return new Error(
                "VisitorCard.NoVisitorIdentification",
                "Identifique el destinatario del cartão.");
        }

        if (validUntil <= validFrom)
        {
            return new Error(
                "VisitorCard.InvalidValidityWindow",
                "La fecha de fin de validez debe ser posterior al inicio.");
        }

        return new VisitorCardAssignment(
            VisitorCardAssignmentId.New(),
            cardId,
            visitorId,
            company?.Trim() ?? string.Empty,
            string.IsNullOrWhiteSpace(visitedEntity) ? null : visitedEntity.Trim(),
            string.IsNullOrWhiteSpace(vehiclePlate) ? null : vehiclePlate.Trim(),
            accessFamilyIds,
            validFrom,
            validUntil,
            entryTime);
    }

    /// <summary>Records the visitor's exit, freeing the card for future assignments (RULE-008).</summary>
    public Result RecordExit(DateTime exitTime)
    {
        if (IsCompleted)
        {
            return Result.Failure(new Error("VisitorCard.AlreadyExited", "La salida ya fue registrada."));
        }

        if (EntryTime is not null && exitTime < EntryTime)
        {
            return Result.Failure(new Error(
                "VisitorCard.ExitBeforeEntry",
                "La hora de salida no puede ser anterior a la entrada."));
        }

        ExitTime = exitTime;
        return Result.Success();
    }
}
