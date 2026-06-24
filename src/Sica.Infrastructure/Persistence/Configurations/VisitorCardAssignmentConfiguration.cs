using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Sica.Domain.Cards;

namespace Sica.Infrastructure.Persistence.Configurations;

internal sealed class VisitorCardAssignmentConfiguration
    : IEntityTypeConfiguration<VisitorCardAssignment>
{
    public void Configure(EntityTypeBuilder<VisitorCardAssignment> builder)
    {
        builder.ToTable("VisitorCardAssignments");

        builder.HasKey(a => a.Id);

        builder.Property(a => a.Id)
            .HasColumnName("Id")
            .HasConversion(id => id.Value, value => new VisitorCardAssignmentId(value))
            .ValueGeneratedNever();

        builder.Property(a => a.CardId)
            .HasConversion(id => id.Value, value => new CardId(value))
            .IsRequired();

        builder.Property(a => a.VisitorId).IsRequired();
        builder.Property(a => a.Company).HasMaxLength(255).IsRequired();
        builder.Property(a => a.VisitedEntity).HasMaxLength(255);
        builder.Property(a => a.VehiclePlate).HasMaxLength(20);
        builder.Property(a => a.ValidFrom).IsRequired();
        builder.Property(a => a.ValidUntil).IsRequired();
        builder.Property(a => a.EntryTime);
        builder.Property(a => a.ExitTime);

        builder.Ignore(a => a.AccessFamilyIds);
        builder.Ignore(a => a.IsCompleted);

        builder.Property<List<Guid>>("_accessFamilyIds")
            .HasColumnName("AccessFamilyIds")
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

        builder.HasIndex(a => a.CardId);
        builder.HasIndex(a => a.VisitorId);
        builder.HasIndex(a => new { a.EntryTime, a.ExitTime });
    }
}
