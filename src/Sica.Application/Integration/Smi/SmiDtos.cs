namespace Sica.Application.Integration.Smi;

/// <summary>Smart card as exposed by the SMI master system (ACL DTO).</summary>
public sealed record SmiSmartCard(
    int Id,
    string Label,
    string Tag,
    int UserId,
    DateTime ExpirationDate,
    SmiSmartCardStatus Status,
    string LogicalCode);

/// <summary>Access family / group as exposed by SMI.</summary>
public sealed record SmiFamily(int Id, string Label);

/// <summary>Physical access circuit (reader point) as exposed by SMI.</summary>
public sealed record SmiCircuit(int Id, string Label, string? IpAddress);

/// <summary>Geographical zone with its current occupant count, as exposed by SMI.</summary>
public sealed record SmiZone(int Id, string Label, int UserCount);

/// <summary>Access event captured at a circuit, as exposed by SMI.</summary>
public sealed record SmiAccessEvent(
    DateTime Timestamp,
    string Name,
    int FamilyId,
    string Family,
    int CompanyId,
    string Company,
    string LogicalCode,
    int EventId,
    string Event,
    int GeoZoneId,
    string GeoZone,
    int CircuitId,
    string Circuit);
