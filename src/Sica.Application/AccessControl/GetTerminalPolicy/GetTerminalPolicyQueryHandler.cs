using Sica.Application.Abstractions;
using Sica.Domain.AccessControl;
using Sica.Shared;

namespace Sica.Application.AccessControl.GetTerminalPolicy;

/// <summary>
/// Returns a terminal's access profile. A terminal with no configured policy yields
/// an empty profile (no families, no circuits).
/// </summary>
public sealed class GetTerminalPolicyQueryHandler(ITerminalAccessPolicyRepository policies)
    : IQueryHandler<GetTerminalPolicyQuery, TerminalPolicyDto>
{
    private readonly ITerminalAccessPolicyRepository _policies =
        Guard.AgainstNull(policies, nameof(policies));

    public async Task<Result<TerminalPolicyDto>> HandleAsync(
        GetTerminalPolicyQuery query,
        CancellationToken cancellationToken = default)
    {
        var policy = await _policies.GetByTerminalIdAsync(query.TerminalId, cancellationToken);

        if (policy is null)
        {
            return Result.Success(new TerminalPolicyDto(query.TerminalId, [], []));
        }

        return Result.Success(new TerminalPolicyDto(
            policy.TerminalId,
            policy.FamilyIds.ToList(),
            policy.CircuitIds.ToList()));
    }
}
