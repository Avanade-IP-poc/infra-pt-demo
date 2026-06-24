using Sica.Application.Abstractions;
using Sica.Application.Cards.AssignVisitorCard;
using Sica.Application.Cards.ListAvailableVisitorCards;
using Sica.Application.Cards.RecordVisitorExit;

namespace Sica.Api.Endpoints;

/// <summary>Minimal API endpoints for the Card Management bounded context.</summary>
public static class CardEndpoints
{
    public static IEndpointRouteBuilder MapCardEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/v1/cards").WithTags("Cards");

        group.MapGet("/visitors/available", ListAvailableVisitorCardsAsync)
            .WithName("listAvailableVisitorCards")
            .WithOpenApi();

        group.MapPost("/visitors/assign", AssignVisitorCardAsync)
            .WithName("assignVisitorCard")
            .WithOpenApi();

        group.MapPost("/visitors/assignments/{assignmentId:guid}/exit", RecordVisitorExitAsync)
            .WithName("recordVisitorExit")
            .WithOpenApi();

        return app;
    }

    private static async Task<IResult> ListAvailableVisitorCardsAsync(
        IQueryHandler<ListAvailableVisitorCardsQuery, IReadOnlyList<AvailableVisitorCard>> handler,
        CancellationToken cancellationToken)
    {
        var result = await handler.HandleAsync(new ListAvailableVisitorCardsQuery(), cancellationToken);
        return Results.Ok(result.Value);
    }

    private static async Task<IResult> AssignVisitorCardAsync(
        AssignVisitorCardCommand command,
        ICommandHandler<AssignVisitorCardCommand, AssignVisitorCardResult> handler,
        CancellationToken cancellationToken)
    {
        var result = await handler.HandleAsync(command, cancellationToken);

        return result.IsSuccess
            ? Results.Created($"/api/v1/cards/visitors/assignments/{result.Value.AssignmentId}", result.Value)
            : Results.UnprocessableEntity(new { error = result.Error.Description, code = result.Error.Code });
    }

    private static async Task<IResult> RecordVisitorExitAsync(
        Guid assignmentId,
        ICommandHandler<RecordVisitorExitCommand> handler,
        CancellationToken cancellationToken)
    {
        var result = await handler.HandleAsync(new RecordVisitorExitCommand(assignmentId), cancellationToken);

        if (result.IsSuccess)
        {
            return Results.NoContent();
        }

        return result.Error.Code == "VisitorCard.AssignmentNotFound"
            ? Results.NotFound(new { error = result.Error.Description, code = result.Error.Code })
            : Results.UnprocessableEntity(new { error = result.Error.Description, code = result.Error.Code });
    }
}
