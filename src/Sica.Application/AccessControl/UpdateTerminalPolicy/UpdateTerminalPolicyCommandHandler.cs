using Sica.Application.Abstractions;
using Sica.Domain.AccessControl;
using Sica.Shared;

namespace Sica.Application.AccessControl.UpdateTerminalPolicy;

/// <summary>
/// RULE-007: validates referenced families and circuits, then replaces the terminal's
/// access profile in full. Validation precedes any mutation and the replacement is
/// committed as a single unit of work, so a failure leaves the previous profile intact
/// (unlike the legacy non-transactional DELETE+INSERT).
/// </summary>
public sealed class UpdateTerminalPolicyCommandHandler(
    IAccessFamilyRepository families,
    ICircuitRepository circuits,
    ITerminalAccessPolicyRepository policies,
    IUnitOfWork unitOfWork)
    : ICommandHandler<UpdateTerminalPolicyCommand>
{
    private readonly IAccessFamilyRepository _families = Guard.AgainstNull(families, nameof(families));
    private readonly ICircuitRepository _circuits = Guard.AgainstNull(circuits, nameof(circuits));
    private readonly ITerminalAccessPolicyRepository _policies =
        Guard.AgainstNull(policies, nameof(policies));
    private readonly IUnitOfWork _unitOfWork = Guard.AgainstNull(unitOfWork, nameof(unitOfWork));

    public async Task<Result> HandleAsync(
        UpdateTerminalPolicyCommand command,
        CancellationToken cancellationToken = default)
    {
        var familyIds = command.FamilyIds ?? [];
        var circuitIds = command.CircuitIds ?? [];

        var existingFamilies = await _families.ListAsync(cancellationToken);
        var existingFamilyIds = existingFamilies.Select(f => f.Id).ToHashSet();
        if (familyIds.Any(id => !existingFamilyIds.Contains(new AccessFamilyId(id))))
        {
            return Result.Failure(AccessControlErrors.FamilyNotFound);
        }

        var existingCircuits = await _circuits.ListAsync(cancellationToken);
        var existingCircuitIds = existingCircuits.Select(c => c.Id).ToHashSet();
        if (circuitIds.Any(id => !existingCircuitIds.Contains(new CircuitId(id))))
        {
            return Result.Failure(AccessControlErrors.CircuitNotFound);
        }

        var policy = await _policies.GetByTerminalIdAsync(command.TerminalId, cancellationToken);
        if (policy is null)
        {
            policy = TerminalAccessPolicy.Create(command.TerminalId);
            _policies.Add(policy);
        }

        policy.ReplaceRules(familyIds, circuitIds);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
