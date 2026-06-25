namespace Sica.Domain.AccessControl;

/// <summary>Persistence port for the <see cref="TerminalAccessPolicy"/> aggregate.</summary>
public interface ITerminalAccessPolicyRepository
{
    Task<TerminalAccessPolicy?> GetByTerminalIdAsync(
        int terminalId,
        CancellationToken cancellationToken = default);

    void Add(TerminalAccessPolicy policy);
}
