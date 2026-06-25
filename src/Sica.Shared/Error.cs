namespace Sica.Shared;

/// <summary>
/// Represents an error with a stable machine-readable code and a human-readable description.
/// </summary>
public sealed record Error(string Code, string Description)
{
    public static readonly Error None = new(string.Empty, string.Empty);

    public static Error NotFound(string description) => new("General.NotFound", description);

    public static Error Validation(string description) => new("General.Validation", description);

    public static Error Conflict(string description) => new("General.Conflict", description);

    public static Error Unauthorized(string description) => new("General.Unauthorized", description);
}
