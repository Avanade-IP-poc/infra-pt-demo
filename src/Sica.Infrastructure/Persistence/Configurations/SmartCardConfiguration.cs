using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Sica.Domain.Cards;

namespace Sica.Infrastructure.Persistence.Configurations;

internal sealed class SmartCardConfiguration : IEntityTypeConfiguration<SmartCard>
{
    public void Configure(EntityTypeBuilder<SmartCard> builder)
    {
        builder.ToTable("SmartCards");

        builder.HasKey(c => c.Id);

        builder.Property(c => c.Id)
            .HasColumnName("Id")
            .HasConversion(id => id.Value, value => new CardId(value))
            .ValueGeneratedNever();

        builder.Property(c => c.Code)
            .HasColumnName("CardCode")
            .HasMaxLength(50)
            .HasConversion(code => code.Value, value => CardCode.Create(value))
            .IsRequired();

        builder.Property(c => c.Type)
            .HasColumnName("CardType")
            .HasConversion<string>()
            .HasMaxLength(20)
            .IsRequired();

        builder.Property(c => c.Label)
            .HasMaxLength(100);

        builder.Property(c => c.Status)
            .HasConversion<string>()
            .HasMaxLength(20)
            .IsRequired();

        builder.Property(c => c.ExpirationDate);
        builder.Property(c => c.OwnerId);
        builder.Property(c => c.SmiCardId).HasColumnName("SMICardId");

        builder.Ignore(c => c.IsActive);

        builder.HasIndex(c => c.Code).IsUnique();
        builder.HasIndex(c => c.OwnerId);
    }
}
