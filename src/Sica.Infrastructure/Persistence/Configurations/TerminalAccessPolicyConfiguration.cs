using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Sica.Domain.AccessControl;

namespace Sica.Infrastructure.Persistence.Configurations;

internal sealed class TerminalAccessPolicyConfiguration
    : IEntityTypeConfiguration<TerminalAccessPolicy>
{
    public void Configure(EntityTypeBuilder<TerminalAccessPolicy> builder)
    {
        builder.ToTable("TerminalAccessPolicies");

        builder.HasKey(p => p.Id);

        builder.Property(p => p.Id)
            .HasColumnName("Id")
            .HasConversion(id => id.Value, value => new TerminalAccessPolicyId(value))
            .ValueGeneratedNever();

        builder.Property(p => p.TerminalId).IsRequired();

        builder.Ignore(p => p.FamilyIds);
        builder.Ignore(p => p.CircuitIds);

        builder.Property<List<Guid>>("_familyIds")
            .HasColumnName("FamilyIds")
            .HasColumnType("nvarchar(max)")
            .HasConversion(
                ids => string.Join(',', ids),
                value => string.IsNullOrEmpty(value)
                    ? new List<Guid>()
                    : value.Split(',', StringSplitOptions.RemoveEmptyEntries).Select(Guid.Parse).ToList(),
                new ValueComparer<List<Guid>>(
                    (a, b) => a!.SequenceEqual(b!),
                    c => c.Aggregate(0, (hash, id) => HashCode.Combine(hash, id.GetHashCode())),
                    c => c.ToList()));

        builder.Property<List<int>>("_circuitIds")
            .HasColumnName("CircuitIds")
            .HasColumnType("nvarchar(max)")
            .HasConversion(
                ids => string.Join(',', ids),
                value => string.IsNullOrEmpty(value)
                    ? new List<int>()
                    : value.Split(',', StringSplitOptions.RemoveEmptyEntries)
                        .Select(v => int.Parse(v, System.Globalization.CultureInfo.InvariantCulture))
                        .ToList(),
                new ValueComparer<List<int>>(
                    (a, b) => a!.SequenceEqual(b!),
                    c => c.Aggregate(0, (hash, id) => HashCode.Combine(hash, id)),
                    c => c.ToList()));

        builder.HasIndex(p => p.TerminalId).IsUnique();
    }
}
