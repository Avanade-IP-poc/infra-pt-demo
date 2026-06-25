using Sica.Shared;

namespace Sica.Application.Abstractions;

/// <summary>Marker for a query that returns a value of type <typeparamref name="TResponse"/>.</summary>
public interface IQuery<TResponse>;

/// <summary>Handles a query that returns a value.</summary>
public interface IQueryHandler<in TQuery, TResponse>
    where TQuery : IQuery<TResponse>
{
    Task<Result<TResponse>> HandleAsync(TQuery query, CancellationToken cancellationToken = default);
}
