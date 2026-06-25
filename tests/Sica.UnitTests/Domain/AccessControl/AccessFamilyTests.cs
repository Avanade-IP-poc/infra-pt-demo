using FluentAssertions;
using Sica.Domain.AccessControl;
using Xunit;

namespace Sica.UnitTests.Domain.AccessControl;

public sealed class AccessFamilyTests
{
    [Fact]
    public void Create_ShouldTrimNameAndStartEmpty()
    {
        var family = AccessFamily.Create("  Visitantes VIP ", smiFamilyId: 7);

        family.Name.Should().Be("Visitantes VIP");
        family.SmiFamilyId.Should().Be(7);
        family.MemberUserIds.Should().BeEmpty();
        family.Id.Value.Should().NotBe(Guid.Empty);
    }

    [Fact]
    public void Create_WithBlankName_ShouldThrow()
    {
        var act = () => AccessFamily.Create("   ");
        act.Should().Throw<ArgumentException>();
    }

    [Fact]
    public void ReplaceMembers_ShouldOverwritePreviousSetAndDeduplicate()
    {
        var family = AccessFamily.Create("Generales");
        var user = Guid.NewGuid();

        family.ReplaceMembers([user, Guid.NewGuid()]);
        family.ReplaceMembers([user, user]);

        family.MemberUserIds.Should().ContainSingle().Which.Should().Be(user);
    }

    [Fact]
    public void ReplaceMembers_WithEmpty_ShouldClearMembership()
    {
        var family = AccessFamily.Create("Generales");
        family.ReplaceMembers([Guid.NewGuid()]);

        family.ReplaceMembers([]);

        family.MemberUserIds.Should().BeEmpty();
    }
}
