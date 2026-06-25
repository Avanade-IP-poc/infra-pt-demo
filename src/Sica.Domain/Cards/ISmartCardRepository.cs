namespace Sica.Domain.Cards;

/// <summary>Persistence abstraction for the <see cref="SmartCard"/> aggregate.</summary>
public interface ISmartCardRepository
{
    Task<SmartCard?> GetByIdAsync(CardId id, CancellationToken cancellationToken = default);

    Task<SmartCard?> GetByCodeAsync(CardCode code, CancellationToken cancellationToken = default);

    Task<IReadOnlyList<SmartCard>> ListByTypeAsync(CardType type, CancellationToken cancellationToken = default);

    void Add(SmartCard card);
}
