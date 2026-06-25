using FluentAssertions;
using NSubstitute;
using Sica.Application.AccessControl.GetTerminalPolicy;
using Sica.Domain.AccessControl;
using Xunit;

namespace Sica.UnitTests.Application.AccessControl;

public sealed class GetTerminalPolicyQueryHandlerTests
{
    private readonly ITerminalAccessPolicyRepository _policies =
        Substitute.For<ITerminalAccessPolicyRepository>();

    private GetTerminalPolicyQueryHandler CreateHandler() => new(_policies);

    [Fact]
    public async Task HandleAsync_WhenPolicyExists_ShouldProjectProfile()
    {
        var policy = TerminalAccessPolicy.Create(1);
        var family = Guid.NewGuid();
        policy.ReplaceRules([family], [10, 11]);
        _policies.GetByTerminalIdAsync(1, Arg.Any<CancellationToken>()).Returns(policy);

        var result = await CreateHandler().HandleAsync(new GetTerminalPolicyQuery(1));

        result.IsSuccess.Should().BeTrue();
        result.Value.TerminalId.Should().Be(1);
        result.Value.FamilyIds.Should().ContainSingle().Which.Should().Be(family);
        result.Value.CircuitIds.Should().BeEquivalentTo([10, 11]);
    }

    [Fact]
    public async Task HandleAsync_WhenNoPolicy_ShouldReturnEmptyProfile()
    {
        _policies.GetByTerminalIdAsync(99, Arg.Any<CancellationToken>())
            .Returns((TerminalAccessPolicy?)null);

        var result = await CreateHandler().HandleAsync(new GetTerminalPolicyQuery(99));

        result.IsSuccess.Should().BeTrue();
        result.Value.TerminalId.Should().Be(99);
        result.Value.FamilyIds.Should().BeEmpty();
        result.Value.CircuitIds.Should().BeEmpty();
    }
}
