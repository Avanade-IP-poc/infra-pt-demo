namespace Sica.Domain.Iam;

/// <summary>
/// Persistence abstraction for the <see cref="Terminal"/> aggregate. Lives in the
/// domain layer per the Repository pattern; implemented in Infrastructure with EF Core.
/// </summary>
public interface ITerminalRepository
{
    /// <summary>
    /// Finds an active or inactive terminal whose hostname (case-insensitive) or
    /// IP address matches the supplied values. Returns null when none is registered.
    /// </summary>
    Task<Terminal?> FindByHostnameOrIpAsync(
        string? hostname,
        string? ipAddress,
        CancellationToken cancellationToken = default);
}
