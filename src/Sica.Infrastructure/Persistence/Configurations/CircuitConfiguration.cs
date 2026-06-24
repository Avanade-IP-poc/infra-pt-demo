using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Sica.Domain.AccessControl;

namespace Sica.Infrastructure.Persistence.Configurations;

internal sealed class CircuitConfiguration : IEntityTypeConfiguration<Circuit>
{
    public void Configure(EntityTypeBuilder<Circuit> builder)
    {
        builder.ToTable("Circuits");

        builder.HasKey(c => c.Id);

        builder.Property(c => c.Id)
            .HasColumnName("Id")
            .HasConversion(id => id.Value, value => new CircuitId(value))
            .ValueGeneratedOnAdd();

        builder.Property(c => c.Name)
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(c => c.CircuitGroupId);
        builder.Property(c => c.SmiCircuitId).HasColumnName("SMICircuitId");

        builder.HasIndex(c => c.Name).IsUnique();
        builder.HasIndex(c => c.CircuitGroupId);
    }
}
