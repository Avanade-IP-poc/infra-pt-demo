using FluentAssertions;
using Sica.Domain.AccessControl;
using Xunit;

namespace Sica.UnitTests.Domain.AccessControl;

public sealed class TerminalAccessPolicyTests
{
    [Fact]
    public void Create_ShouldStartWithEmptyProfile()
    {
        var policy = TerminalAccessPolicy.Create(terminalId: 1);

        policy.TerminalId.Should().Be(1);
        policy.FamilyIds.Should().BeEmpty();
        policy.CircuitIds.Should().BeEmpty();
    }

    [Fact]
    public void Create_WithNonPositiveTerminalId_ShouldThrow()
    {
        var act = () => TerminalAccessPolicy.Create(terminalId: 0);
        act.Should().Throw<ArgumentException>();
    }

    [Fact]
    public void ReplaceRules_ShouldReplacePreviousProfileEntirely()
    {
        var policy = TerminalAccessPolicy.Create(1);
        var familyA = Guid.NewGuid();
        policy.ReplaceRules([familyA], [10]);

        var familyB = Guid.NewGuid();
        policy.ReplaceRules([familyB], [11, 12]);

        policy.FamilyIds.Should().ContainSingle().Which.Should().Be(familyB);
        policy.CircuitIds.Should().BeEquivalentTo([11, 12]);
    }

    [Fact]
    public void ReplaceRules_WithEmptyCollections_ShouldLockTerminalDown()
    {
        var policy = TerminalAccessPolicy.Create(1);
        policy.ReplaceRules([Guid.NewGuid()], [10]);

        policy.ReplaceRules([], []);

        policy.FamilyIds.Should().BeEmpty();
        policy.CircuitIds.Should().BeEmpty();
    }

    [Fact]
    public void ReplaceRules_ShouldDeduplicate()
    {
        var policy = TerminalAccessPolicy.Create(1);
        var family = Guid.NewGuid();

        policy.ReplaceRules([family, family], [10, 10, 11]);

        policy.FamilyIds.Should().ContainSingle().Which.Should().Be(family);
        policy.CircuitIds.Should().BeEquivalentTo([10, 11]);
    }
}
