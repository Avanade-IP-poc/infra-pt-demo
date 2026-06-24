using FluentAssertions;
using Xunit;

namespace Sica.CharacterizationTests;

/// <summary>
/// Golden-master scaffolding to pin the observable behaviour of the legacy
/// SICAWeb system before it is rewritten (Strangler Fig). Each rule extracted
/// in <c>.boltf/analysis/SICAWeb/BUSINESS_RULES.md</c> gets a characterization
/// fixture here as its corresponding Bolt is implemented.
/// </summary>
public sealed class LegacyParityBaselineTests
{
    /// <summary>
    /// RULE-003 documented defect: the legacy whitelist check uses
    /// <c>IndexOf</c> (substring match), which lets a code that is a substring
    /// of an authorized code pass. Pinned here so the modern implementation can
    /// prove it intentionally fixes the behaviour.
    /// </summary>
    [Theory(Skip = "Pending Bolt 2 (IAM) — replace with real legacy parity harness.")]
    [InlineData("E007", "E007234", true)]
    [InlineData("E999", "E007234", false)]
    public void Rule003_LegacyWhitelistSubstringBehaviour_IsPinned(
        string requestedCode,
        string authorizedCode,
        bool legacyAllows)
    {
        var legacyResult = authorizedCode.IndexOf(requestedCode, StringComparison.Ordinal) >= 0;

        legacyResult.Should().Be(legacyAllows);
    }
}
