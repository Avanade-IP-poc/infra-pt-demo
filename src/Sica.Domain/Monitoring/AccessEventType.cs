namespace Sica.Domain.Monitoring;

/// <summary>
/// Classification of a physical access movement (RULE-011). <see cref="Unknown"/>
/// events are ignored when computing presence.
/// </summary>
public enum AccessEventType
{
    Unknown = 0,
    Entry = 1,
    Exit = 2,
}
