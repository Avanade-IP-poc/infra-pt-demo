using Sica.Application.Abstractions;

namespace Sica.Application.Cards.RecordVisitorExit;

/// <summary>Records the exit of a visitor, freeing the card for reuse (RULE-008).</summary>
public sealed record RecordVisitorExitCommand(Guid AssignmentId) : ICommand;
