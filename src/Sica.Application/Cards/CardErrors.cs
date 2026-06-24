using Sica.Shared;

namespace Sica.Application.Cards;

/// <summary>Application-level errors for the Card Management bounded context.</summary>
public static class CardErrors
{
    public static readonly Error CardNotFound = new("Card.NotFound", "Tarjeta no encontrada.");

    public static readonly Error CardNotAvailable =
        new("Card.NotAvailable", "La tarjeta no está disponible para asignar.");

    public static readonly Error AssignmentNotFound =
        new("VisitorCard.AssignmentNotFound", "Asignación no encontrada.");

    public static readonly Error NoCardSelected =
        new("VisitorCard.NoCardSelected", "Seleccione un o mais cartões disponíveis.");
}
