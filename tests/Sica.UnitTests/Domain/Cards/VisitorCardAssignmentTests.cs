using FluentAssertions;
using Sica.Domain.Cards;
using Sica.Shared;
using Xunit;

namespace Sica.UnitTests.Domain.Cards;

public sealed class VisitorCardAssignmentTests
{
    private static readonly CardId Card = CardId.New();
    private static readonly Guid Visitor = Guid.NewGuid();
    private static readonly Guid Family = Guid.NewGuid();
    private static readonly DateTime From = new(2026, 06, 24, 8, 0, 0, DateTimeKind.Utc);
    private static readonly DateTime Until = new(2026, 06, 24, 18, 0, 0, DateTimeKind.Utc);

    private static Result<VisitorCardAssignment> AssignValid()
        => VisitorCardAssignment.Assign(
            Card, Visitor, "Empresa XYZ", "Departamento IT", null, [Family], From, Until, From);

    [Fact]
    public void Assign_WithCompleteData_ShouldSucceedAndRecordEntry()
    {
        var result = AssignValid();

        result.IsSuccess.Should().BeTrue();
        result.Value.EntryTime.Should().Be(From);
        result.Value.IsCompleted.Should().BeFalse();
        result.Value.AccessFamilyIds.Should().ContainSingle().Which.Should().Be(Family);
    }

    [Fact]
    public void Assign_WithoutFamily_ShouldFailRule009()
    {
        var result = VisitorCardAssignment.Assign(
            Card, Visitor, "Empresa XYZ", "IT", null, [], From, Until, From);

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("VisitorCard.NoFamily");
        result.Error.Description.Should().Be("Seleccione el acceso pretendido.");
    }

    [Fact]
    public void Assign_WithoutVisitorIdentification_ShouldFailRule009()
    {
        var result = VisitorCardAssignment.Assign(
            Card, Visitor, company: null, visitedEntity: null, null, [Family], From, Until, From);

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("VisitorCard.NoVisitorIdentification");
        result.Error.Description.Should().Be("Identifique el destinatario del cartão.");
    }

    [Fact]
    public void Assign_WithInvalidValidityWindow_ShouldFail()
    {
        var result = VisitorCardAssignment.Assign(
            Card, Visitor, "Empresa", "IT", null, [Family], Until, From, From);

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("VisitorCard.InvalidValidityWindow");
    }

    [Fact]
    public void RecordExit_OnOpenAssignment_ShouldComplete()
    {
        var assignment = AssignValid().Value;

        var result = assignment.RecordExit(Until);

        result.IsSuccess.Should().BeTrue();
        assignment.IsCompleted.Should().BeTrue();
        assignment.ExitTime.Should().Be(Until);
    }

    [Fact]
    public void RecordExit_Twice_ShouldFail()
    {
        var assignment = AssignValid().Value;
        assignment.RecordExit(Until);

        var second = assignment.RecordExit(Until);

        second.IsFailure.Should().BeTrue();
        second.Error.Code.Should().Be("VisitorCard.AlreadyExited");
    }

    [Fact]
    public void RecordExit_BeforeEntry_ShouldFail()
    {
        var assignment = AssignValid().Value;

        var result = assignment.RecordExit(From.AddHours(-1));

        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("VisitorCard.ExitBeforeEntry");
    }
}
