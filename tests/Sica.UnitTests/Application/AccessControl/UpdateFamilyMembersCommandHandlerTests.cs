using FluentAssertions;
using NSubstitute;
using Sica.Application.AccessControl.UpdateFamilyMembers;
using Sica.Application.Abstractions;
using Sica.Domain.AccessControl;
using Xunit;

namespace Sica.UnitTests.Application.AccessControl;

public sealed class UpdateFamilyMembersCommandHandlerTests
{
    private readonly IAccessFamilyRepository _families = Substitute.For<IAccessFamilyRepository>();
    private readonly IUnitOfWork _unitOfWork = Substitute.For<IUnitOfWork>();

    private UpdateFamilyMembersCommandHandler CreateHandler() => new(_families, _unitOfWork);

    [Fact]
    public async Task HandleAsync_OnExistingFamily_ShouldReplaceMembers()
    {
        var family = AccessFamily.Create("Generales");
        _families.GetByIdAsync(family.Id, Arg.Any<CancellationToken>()).Returns(family);
        var user = Guid.NewGuid();

        var result = await CreateHandler().HandleAsync(
            new UpdateFamilyMembersCommand(family.Id.Value, [user]));

        result.IsSuccess.Should().BeTrue();
        family.MemberUserIds.Should().ContainSingle().Which.Should().Be(user);
        await _unitOfWork.Received(1).SaveChangesAsync(Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task HandleAsync_WhenFamilyNotFound_ShouldFail()
    {
        _families.GetByIdAsync(Arg.Any<AccessFamilyId>(), Arg.Any<CancellationToken>())
            .Returns((AccessFamily?)null);

        var result = await CreateHandler().HandleAsync(
            new UpdateFamilyMembersCommand(Guid.NewGuid(), [Guid.NewGuid()]));

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("AccessControl.FamilyNotFound");
        await _unitOfWork.DidNotReceive().SaveChangesAsync(Arg.Any<CancellationToken>());
    }
}
