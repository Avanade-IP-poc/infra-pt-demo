using FluentAssertions;
using Sica.Domain.Iam;
using Xunit;

namespace Sica.UnitTests.Domain.Iam;

public sealed class TerminalTests
{
    [Fact]
    public void Register_ShouldNormalizeHostnameToUpperCase()
    {
        var terminal = Terminal.Register(new TerminalId(1), "term01", "192.168.1.100");

        terminal.Hostname.Should().Be("TERM01");
        terminal.IpAddress.Should().Be("192.168.1.100");
        terminal.IsActive.Should().BeTrue();
    }

    [Theory]
    [InlineData("term01")]
    [InlineData("TERM01")]
    [InlineData("  Term01 ")]
    public void Matches_ByHostname_ShouldBeCaseInsensitive(string requestedHostname)
    {
        var terminal = Terminal.Register(new TerminalId(1), "TERM01", "192.168.1.100");

        terminal.Matches(requestedHostname, ipAddress: null).Should().BeTrue();
    }

    [Fact]
    public void Matches_ByIpAddress_WhenHostnameUnknown_ShouldBeTrue()
    {
        var terminal = Terminal.Register(new TerminalId(2), "TERM02", "192.168.1.101");

        terminal.Matches("UNKNOWN", "192.168.1.101").Should().BeTrue();
    }

    [Fact]
    public void Matches_WhenNeitherHostnameNorIpMatch_ShouldBeFalse()
    {
        var terminal = Terminal.Register(new TerminalId(1), "TERM01", "192.168.1.100");

        terminal.Matches("TERM99", "192.168.1.999").Should().BeFalse();
    }

    [Fact]
    public void Matches_WithoutRegisteredIp_ShouldNotMatchByIp()
    {
        var terminal = Terminal.Register(new TerminalId(1), "TERM01", ipAddress: null);

        terminal.Matches("OTHER", "192.168.1.100").Should().BeFalse();
    }

    [Fact]
    public void Deactivate_ShouldSetInactive()
    {
        var terminal = Terminal.Register(new TerminalId(1), "TERM01");

        terminal.Deactivate();

        terminal.IsActive.Should().BeFalse();
    }

    [Fact]
    public void Register_WithBlankHostname_ShouldThrow()
    {
        var act = () => Terminal.Register(new TerminalId(1), "   ");

        act.Should().Throw<ArgumentException>();
    }
}
