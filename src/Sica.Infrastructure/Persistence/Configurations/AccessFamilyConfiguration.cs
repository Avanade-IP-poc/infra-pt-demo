using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Sica.Domain.AccessControl;

namespace Sica.Infrastructure.Persistence.Configurations;

internal sealed class AccessFamilyConfiguration : IEntityTypeConfiguration<AccessFamily>
{
    public void Configure(EntityTypeBuilder<AccessFamily> builder)
    {
        builder.ToTable("AccessFamilies");

        builder.HasKey(f => f.Id);

        builder.Property(f => f.Id)
            .HasColumnName("Id")
            .HasConversion(id => id.Value, value => new AccessFamilyId(value))
            .ValueGeneratedNever();

        builder.Property(f => f.Name)
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(f => f.SmiFamilyId).HasColumnName("SMIFamilyId");

        builder.Ignore(f => f.MemberUserIds);

        builder.Property<List<Guid>>("_memberUserIds")
            .HasColumnName("MemberUserIds")
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

        builder.HasIndex(f => f.Name).IsUnique();
    }
}
