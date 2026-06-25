using Microsoft.EntityFrameworkCore;
using Sica.Application.Abstractions;
using Sica.Domain.AccessControl;
using Sica.Domain.Cards;
using Sica.Domain.Iam;

namespace Sica.Infrastructure.Persistence;

/// <summary>EF Core DbContext for the SICA transactional database (schema <c>sica</c>).</summary>
public sealed class SicaDbContext(DbContextOptions<SicaDbContext> options)
    : DbContext(options), IUnitOfWork
{
    public DbSet<Terminal> Terminals => Set<Terminal>();

    public DbSet<SmartCard> SmartCards => Set<SmartCard>();

    public DbSet<VisitorCardAssignment> VisitorCardAssignments => Set<VisitorCardAssignment>();

    public DbSet<AccessFamily> AccessFamilies => Set<AccessFamily>();

    public DbSet<Circuit> Circuits => Set<Circuit>();

    public DbSet<TerminalAccessPolicy> TerminalAccessPolicies => Set<TerminalAccessPolicy>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("sica");
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(SicaDbContext).Assembly);
        base.OnModelCreating(modelBuilder);
    }
}
