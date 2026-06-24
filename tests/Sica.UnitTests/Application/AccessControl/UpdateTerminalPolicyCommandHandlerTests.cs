using FluentAssertions;
using NSubstitute;
using Sica.Application.AccessControl.UpdateTerminalPolicy;
using Sica.Application.Abstractions;
using Sica.Domain.AccessControl;
using Xunit;

namespace Sica.UnitTests.Application.AccessControl;

public sealed class UpdateTerminalPolicyCommandHandlerTests
{
    private readonly IAccessFamilyRepository _families = Substitute.For<IAccessFamilyRepository>();
    private readonly ICircuitRepository _circuits = Substitute.For<ICircuitRepository>();
    private readonly ITerminalAccessPolicyRepository _policies =
        Substitute.For<ITerminalAccessPolicyRepository>();
    private readonly IUnitOfWork _unitOfWork = Substitute.For<IUnitOfWork>();

    private UpdateTerminalPolicyCommandHandler CreateHandler()
        => new(_families, _circuits, _policies, _unitOfWork);

    private (AccessFamily family, Circuit circuit) SeedValidReferences()
    {
        var family = AccessFamily.Create("Generales");
        var circuit = Circuit.Register(new CircuitId(10), "Puerta Principal");
        _families.ListAsync(Arg.Any<CancellationToken>()).Returns(new[] { family });
        _circuits.ListAsync(Arg.Any<CancellationToken>()).Returns(new[] { circuit });
        return (family, circuit);
    }

    [Fact]
    public async Task HandleAsync_WhenNoPolicyExists_ShouldCreateAndReplaceRules()
    {
        var (family, circuit) = SeedValidReferences();
        _policies.GetByTerminalIdAsync(1, Arg.Any<CancellationToken>())
            .Returns((TerminalAccessPolicy?)null);
        TerminalAccessPolicy? added = null;
        _policies.When(p => p.Add(Arg.Any<TerminalAccessPolicy>()))
            .Do(ci => added = ci.Arg<TerminalAccessPolicy>());

        var result = await CreateHandler().HandleAsync(new UpdateTerminalPolicyCommand(
            1, [family.Id.Value], [circuit.Id.Value]));

        result.IsSuccess.Should().BeTrue();
        added.Should().NotBeNull();
        added!.FamilyIds.Should().ContainSingle().Which.Should().Be(family.Id.Value);
        added.CircuitIds.Should().ContainSingle().Which.Should().Be(circuit.Id.Value);
        await _unitOfWork.Received(1).SaveChangesAsync(Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task HandleAsync_WhenPolicyExists_ShouldReplaceRulesAtomically()
    {
        var (family, circuit) = SeedValidReferences();
        var policy = TerminalAccessPolicy.Create(1);
        policy.ReplaceRules([Guid.NewGuid()], [99]);
        _policies.GetByTerminalIdAsync(1, Arg.Any<CancellationToken>()).Returns(policy);

        var result = await CreateHandler().HandleAsync(new UpdateTerminalPolicyCommand(
            1, [family.Id.Value], [circuit.Id.Value]));

        result.IsSuccess.Should().BeTrue();
        policy.FamilyIds.Should().ContainSingle().Which.Should().Be(family.Id.Value);
        policy.CircuitIds.Should().ContainSingle().Which.Should().Be(circuit.Id.Value);
        _policies.DidNotReceive().Add(Arg.Any<TerminalAccessPolicy>());
        await _unitOfWork.Received(1).SaveChangesAsync(Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task HandleAsync_WithEmptyProfile_ShouldLockTerminalDown()
    {
        SeedValidReferences();
        var policy = TerminalAccessPolicy.Create(1);
        policy.ReplaceRules([Guid.NewGuid()], [10]);
        _policies.GetByTerminalIdAsync(1, Arg.Any<CancellationToken>()).Returns(policy);

        var result = await CreateHandler().HandleAsync(new UpdateTerminalPolicyCommand(1, [], []));

        result.IsSuccess.Should().BeTrue();
        policy.FamilyIds.Should().BeEmpty();
        policy.CircuitIds.Should().BeEmpty();
    }

    [Fact]
    public async Task HandleAsync_WithUnknownFamily_ShouldFailWithoutMutating()
    {
        SeedValidReferences();
        var policy = TerminalAccessPolicy.Create(1);
        policy.ReplaceRules([Guid.NewGuid()], [10]);
        _policies.GetByTerminalIdAsync(1, Arg.Any<CancellationToken>()).Returns(policy);

        var result = await CreateHandler().HandleAsync(new UpdateTerminalPolicyCommand(
            1, [Guid.NewGuid()], [10]));

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("AccessControl.FamilyNotFound");
        await _unitOfWork.DidNotReceive().SaveChangesAsync(Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task HandleAsync_WithUnknownCircuit_ShouldFailWithoutMutating()
    {
        var (family, _) = SeedValidReferences();

        var result = await CreateHandler().HandleAsync(new UpdateTerminalPolicyCommand(
            1, [family.Id.Value], [999]));

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("AccessControl.CircuitNotFound");
        await _unitOfWork.DidNotReceive().SaveChangesAsync(Arg.Any<CancellationToken>());
    }
}
