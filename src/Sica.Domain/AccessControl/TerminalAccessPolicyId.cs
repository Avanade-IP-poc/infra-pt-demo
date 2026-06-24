namespace Sica.Domain.AccessControl;

/// <summary>Strongly-typed identifier for a <see cref="TerminalAccessPolicy"/>.</summary>
public readonly record struct TerminalAccessPolicyId(Guid Value)
{
    public static TerminalAccessPolicyId New() => new(Guid.NewGuid());

    public override string ToString() => Value.ToString();
}
