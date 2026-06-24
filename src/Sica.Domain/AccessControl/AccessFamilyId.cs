namespace Sica.Domain.AccessControl;

/// <summary>Strongly-typed identifier for an <see cref="AccessFamily"/>.</summary>
public readonly record struct AccessFamilyId(Guid Value)
{
    public static AccessFamilyId New() => new(Guid.NewGuid());

    public override string ToString() => Value.ToString();
}
