namespace Sica.Infrastructure.Integration.Smi;

/// <summary>Selects which <c>ISmiService</c> adapter is wired up.</summary>
public enum SmiMode
{
    /// <summary>In-memory adapter with captured legacy responses (tests / local dev).</summary>
    Mock = 0,

    /// <summary>Production SOAP adapter against the real SMI web service.</summary>
    Soap = 1,
}

/// <summary>Configuration for the SMI Anti-Corruption Layer (bound from <c>Smi</c> section).</summary>
public sealed class SmiOptions
{
    public const string SectionName = "Smi";

    /// <summary>Which adapter to use. Defaults to <see cref="SmiMode.Mock"/>.</summary>
    public SmiMode Mode { get; set; } = SmiMode.Mock;

    /// <summary>SOAP endpoint URL of the legacy SMI web service (required when <see cref="Mode"/> is Soap).</summary>
    public string? Endpoint { get; set; }
}
