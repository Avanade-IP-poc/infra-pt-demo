using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Sica.Domain.Iam;

namespace Sica.Infrastructure.Persistence.Configurations;

internal sealed class TerminalConfiguration : IEntityTypeConfiguration<Terminal>
{
    public void Configure(EntityTypeBuilder<Terminal> builder)
    {
        builder.ToTable("Terminals");

        builder.HasKey(t => t.Id);

        builder.Property(t => t.Id)
            .HasColumnName("Id")
            .HasConversion(id => id.Value, value => new TerminalId(value))
            .ValueGeneratedOnAdd();

        builder.Property(t => t.Hostname)
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(t => t.IpAddress)
            .HasMaxLength(45);

        builder.Property(t => t.Description)
            .HasMaxLength(255);

        builder.Property(t => t.IsActive)
            .IsRequired();

        builder.HasIndex(t => t.Hostname).IsUnique();
        builder.HasIndex(t => t.IpAddress);
    }
}
