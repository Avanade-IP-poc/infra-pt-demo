using Sica.Shared;

namespace Sica.Application.AccessControl;

/// <summary>Domain-level errors for the Access Control bounded context.</summary>
public static class AccessControlErrors
{
    public static readonly Error FamilyNotFound =
        new("AccessControl.FamilyNotFound", "La familia de acceso indicada no existe.");

    public static readonly Error FamilyNameConflict =
        new("AccessControl.FamilyNameConflict", "Ya existe una familia de acceso con ese nombre.");

    public static readonly Error CircuitNotFound =
        new("AccessControl.CircuitNotFound", "El circuito indicado no existe.");
}
