using Sica.Shared;

namespace Sica.Application.Iam;

/// <summary>IAM bounded-context errors (stable codes for clients and tests).</summary>
public static class IamErrors
{
    public static readonly Error TerminalNotRegistered =
        new("Terminal.NotRegistered", "Terminal no registrado");

    public static readonly Error TerminalInactive =
        new("Terminal.Inactive", "Terminal inactivo");
}
