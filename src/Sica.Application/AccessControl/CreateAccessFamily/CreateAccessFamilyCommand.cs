using Sica.Application.Abstractions;

namespace Sica.Application.AccessControl.CreateAccessFamily;

/// <summary>Creates a new access family.</summary>
public sealed record CreateAccessFamilyCommand(string Name, int? SmiFamilyId) : ICommand<Guid>;
