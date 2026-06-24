using Sica.Domain.Primitives;
using Sica.Shared;

namespace Sica.Domain.Iam;

/// <summary>
/// A registered access terminal. Maps the legacy <c>tblTerminais</c> table.
/// Authorization is governed by RULE-001: a terminal may access the system only
/// if its hostname or IP address is registered and the terminal is active.
/// </summary>
public sealed class Terminal : Entity<TerminalId>, IAggregateRoot
{
    private Terminal(TerminalId id, string hostname, string? ipAddress, string? description, bool isActive)
        : base(id)
    {
        Hostname = hostname;
        IpAddress = ipAddress;
        Description = description;
        IsActive = isActive;
    }

    /// <summary>Registered hostname, stored upper-cased for case-insensitive matching.</summary>
    public string Hostname { get; private set; }

    /// <summary>Registered IPv4/IPv6 address, optional.</summary>
    public string? IpAddress { get; private set; }

    public string? Description { get; private set; }

    public bool IsActive { get; private set; }

    public static Terminal Register(
        TerminalId id,
        string hostname,
        string? ipAddress = null,
        string? description = null,
        bool isActive = true)
    {
        Guard.AgainstNullOrWhiteSpace(hostname, nameof(hostname));

        return new Terminal(
            id,
            Normalize(hostname),
            string.IsNullOrWhiteSpace(ipAddress) ? null : ipAddress.Trim(),
            description,
            isActive);
    }

    /// <summary>
    /// RULE-001: returns true when the given hostname (case-insensitive) or IP
    /// address matches this terminal's registered values.
    /// </summary>
    public bool Matches(string? hostname, string? ipAddress)
    {
        var hostnameMatch = !string.IsNullOrWhiteSpace(hostname)
            && string.Equals(Hostname, Normalize(hostname), StringComparison.Ordinal);

        var ipMatch = !string.IsNullOrWhiteSpace(ipAddress)
            && IpAddress is not null
            && string.Equals(IpAddress, ipAddress.Trim(), StringComparison.Ordinal);

        return hostnameMatch || ipMatch;
    }

    public void Deactivate() => IsActive = false;

    public void Activate() => IsActive = true;

    private static string Normalize(string hostname) => hostname.Trim().ToUpperInvariant();
}
