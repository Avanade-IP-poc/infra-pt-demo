namespace Sica.Application.Integration.Smi;

/// <summary>
/// Smart-card lifecycle status as reported by the legacy SMI master system.
/// Mirrors the legacy <c>SmartCardStatus</c> enum (non-contiguous values are
/// preserved on purpose for faithful translation).
/// </summary>
public enum SmiSmartCardStatus
{
    Unknown = 0,
    Active = 2,
    Forbidden = 4,
    Lost = 8,
    Stolen = 16,
    Destroyed = 32,
}
