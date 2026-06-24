using FluentAssertions;
using NSubstitute;
using Sica.Application.AccessControl.CreateAccessFamily;
using Sica.Application.Abstractions;
using Sica.Domain.AccessControl;
using Xunit;

namespace Sica.UnitTests.Application.AccessControl;

public sealed class CreateAccessFamilyCommandHandlerTests
{
    private readonly IAccessFamilyRepository _families = Substitute.For<IAccessFamilyRepository>();
    private readonly IUnitOfWork _unitOfWork = Substitute.For<IUnitOfWork>();

    private CreateAccessFamilyCommandHandler CreateHandler() => new(_families, _unitOfWork);

    [Fact]
    public async Task HandleAsync_WithUniqueName_ShouldCreateFamily()
    {
        _families.GetByNameAsync("Visitantes VIP", Arg.Any<CancellationToken>())
            .Returns((AccessFamily?)null);

        var result = await CreateHandler().HandleAsync(
            new CreateAccessFamilyCommand("Visitantes VIP", null));

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().NotBe(Guid.Empty);
        _families.Received(1).Add(Arg.Any<AccessFamily>());
        await _unitOfWork.Received(1).SaveChangesAsync(Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task HandleAsync_WithBlankName_ShouldFailValidation()
    {
        var result = await CreateHandler().HandleAsync(new CreateAccessFamilyCommand("  ", null));

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("General.Validation");
        await _unitOfWork.DidNotReceive().SaveChangesAsync(Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task HandleAsync_WithDuplicateName_ShouldFailConflict()
    {
        _families.GetByNameAsync("Generales", Arg.Any<CancellationToken>())
            .Returns(AccessFamily.Create("Generales"));

        var result = await CreateHandler().HandleAsync(new CreateAccessFamilyCommand("Generales", null));

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("AccessControl.FamilyNameConflict");
    }
}
