using Microsoft.EntityFrameworkCore;
using Sica.Domain.Iam;

namespace Sica.Infrastructure.Persistence;

/// <summary>EF Core DbContext for the SICA transactional database (schema <c>sica</c>).</summary>
public sealed class SicaDbContext(DbContextOptions<SicaDbContext> options) : DbContext(options)
{
    public DbSet<Terminal> Terminals => Set<Terminal>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("sica");
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(SicaDbContext).Assembly);
        base.OnModelCreating(modelBuilder);
    }
}
