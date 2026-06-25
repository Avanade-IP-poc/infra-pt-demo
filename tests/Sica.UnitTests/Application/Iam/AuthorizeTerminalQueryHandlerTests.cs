using FluentAssertions;
using NSubstitute;
using Sica.Application.Iam;
using Sica.Application.Iam.AuthorizeTerminal;
using Sica.Domain.Iam;
using Xunit;

namespace Sica.UnitTests.Application.Iam;

public sealed class AuthorizeTerminalQueryHandlerTests
{
    private readonly ITerminalRepository _terminals = Substitute.For<ITerminalRepository>();

    private AuthorizeTerminalQueryHandler CreateHandler() => new(_terminals);

    [Fact]
    public async Task Handle_WhenTerminalRegisteredAndActive_ShouldAuthorize()
    {
        var terminal = Terminal.Register(new TerminalId(1), "TERM01", "192.168.1.100");
        _terminals.FindByHostnameOrIpAsync("TERM01", "192.168.1.100", Arg.Any<CancellationToken>())
            .Returns(terminal);

        var result = await CreateHandler().HandleAsync(
            new AuthorizeTerminalQuery("TERM01", "192.168.1.100"));

        result.IsSuccess.Should().BeTrue();
        result.Value.TerminalId.Should().Be(1);
        result.Value.TerminalName.Should().Be("TERM01");
    }

    [Fact]
    public async Task Handle_WhenTerminalNotRegistered_ShouldReturnNotRegistered()
    {
        _terminals.FindByHostnameOrIpAsync(Arg.Any<string?>(), Arg.Any<string?>(), Arg.Any<CancellationToken>())
            .Returns((Terminal?)null);

        var result = await CreateHandler().HandleAsync(
            new AuthorizeTerminalQuery("TERM99", "192.168.1.999"));

        result.IsFailure.Should().BeTrue();
        result.Error.Should().Be(IamErrors.TerminalNotRegistered);
    }

    [Fact]
    public async Task Handle_WhenTerminalInactive_ShouldReturnInactive()
    {
        var terminal = Terminal.Register(new TerminalId(3), "TERM03", "192.168.1.102", isActive: false);
        _terminals.FindByHostnameOrIpAsync("TERM03", "192.168.1.102", Arg.Any<CancellationToken>())
            .Returns(terminal);

        var result = await CreateHandler().HandleAsync(
            new AuthorizeTerminalQuery("TERM03", "192.168.1.102"));

        result.IsFailure.Should().BeTrue();
        result.Error.Should().Be(IamErrors.TerminalInactive);
    }
}
