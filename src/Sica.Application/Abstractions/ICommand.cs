using Sica.Shared;

namespace Sica.Application.Abstractions;

/// <summary>Marker for a command that does not return a value.</summary>
public interface ICommand;

/// <summary>Marker for a command that returns a value of type <typeparamref name="TResponse"/>.</summary>
public interface ICommand<TResponse>;

/// <summary>Handles a command that does not return a value.</summary>
public interface ICommandHandler<in TCommand>
    where TCommand : ICommand
{
    Task<Result> HandleAsync(TCommand command, CancellationToken cancellationToken = default);
}

/// <summary>Handles a command that returns a value.</summary>
public interface ICommandHandler<in TCommand, TResponse>
    where TCommand : ICommand<TResponse>
{
    Task<Result<TResponse>> HandleAsync(TCommand command, CancellationToken cancellationToken = default);
}
