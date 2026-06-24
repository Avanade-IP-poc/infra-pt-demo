using Sica.Application.Abstractions;
using Sica.Application.AccessControl.CreateAccessFamily;
using Sica.Application.AccessControl.GetTerminalPolicy;
using Sica.Application.AccessControl.ListAccessFamilies;
using Sica.Application.AccessControl.ListCircuits;
using Sica.Application.AccessControl.UpdateFamilyMembers;
using Sica.Application.AccessControl.UpdateTerminalPolicy;

namespace Sica.Api.Endpoints;

/// <summary>Minimal API endpoints for the Access Control bounded context (RULE-007).</summary>
public static class AccessControlEndpoints
{
    public static IEndpointRouteBuilder MapAccessControlEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/v1/access-control").WithTags("AccessControl");

        group.MapGet("/families", ListFamiliesAsync)
            .WithName("listAccessFamilies")
            .WithOpenApi();

        group.MapPost("/families", CreateFamilyAsync)
            .WithName("createAccessFamily")
            .WithOpenApi();

        group.MapPut("/families/{familyId:guid}/members", UpdateFamilyMembersAsync)
            .WithName("updateFamilyMembers")
            .WithOpenApi();

        group.MapGet("/circuits", ListCircuitsAsync)
            .WithName("listCircuits")
            .WithOpenApi();

        group.MapGet("/policies/terminal/{terminalId:int}", GetTerminalPolicyAsync)
            .WithName("getTerminalPolicy")
            .WithOpenApi();

        group.MapPut("/policies/terminal/{terminalId:int}", UpdateTerminalPolicyAsync)
            .WithName("updateTerminalPolicy")
            .WithOpenApi();

        return app;
    }

    private static async Task<IResult> ListFamiliesAsync(
        IQueryHandler<ListAccessFamiliesQuery, IReadOnlyList<AccessFamilyDto>> handler,
        CancellationToken cancellationToken)
    {
        var result = await handler.HandleAsync(new ListAccessFamiliesQuery(), cancellationToken);
        return Results.Ok(result.Value);
    }

    private static async Task<IResult> CreateFamilyAsync(
        CreateAccessFamilyCommand command,
        ICommandHandler<CreateAccessFamilyCommand, Guid> handler,
        CancellationToken cancellationToken)
    {
        var result = await handler.HandleAsync(command, cancellationToken);

        return result.IsSuccess
            ? Results.Created($"/api/v1/access-control/families/{result.Value}", new { id = result.Value })
            : Results.UnprocessableEntity(new { error = result.Error.Description, code = result.Error.Code });
    }

    private static async Task<IResult> UpdateFamilyMembersAsync(
        Guid familyId,
        UpdateFamilyMembersRequest request,
        ICommandHandler<UpdateFamilyMembersCommand> handler,
        CancellationToken cancellationToken)
    {
        var command = new UpdateFamilyMembersCommand(familyId, request.UserIds ?? []);
        var result = await handler.HandleAsync(command, cancellationToken);

        if (result.IsSuccess)
        {
            return Results.NoContent();
        }

        return result.Error.Code == "AccessControl.FamilyNotFound"
            ? Results.NotFound(new { error = result.Error.Description, code = result.Error.Code })
            : Results.UnprocessableEntity(new { error = result.Error.Description, code = result.Error.Code });
    }

    private static async Task<IResult> ListCircuitsAsync(
        IQueryHandler<ListCircuitsQuery, IReadOnlyList<CircuitDto>> handler,
        CancellationToken cancellationToken)
    {
        var result = await handler.HandleAsync(new ListCircuitsQuery(), cancellationToken);
        return Results.Ok(result.Value);
    }

    private static async Task<IResult> GetTerminalPolicyAsync(
        int terminalId,
        IQueryHandler<GetTerminalPolicyQuery, TerminalPolicyDto> handler,
        CancellationToken cancellationToken)
    {
        var result = await handler.HandleAsync(new GetTerminalPolicyQuery(terminalId), cancellationToken);
        return Results.Ok(result.Value);
    }

    private static async Task<IResult> UpdateTerminalPolicyAsync(
        int terminalId,
        UpdateTerminalPolicyRequest request,
        ICommandHandler<UpdateTerminalPolicyCommand> handler,
        CancellationToken cancellationToken)
    {
        var command = new UpdateTerminalPolicyCommand(
            terminalId,
            request.FamilyIds ?? [],
            request.CircuitIds ?? []);
        var result = await handler.HandleAsync(command, cancellationToken);

        return result.IsSuccess
            ? Results.NoContent()
            : Results.UnprocessableEntity(new { error = result.Error.Description, code = result.Error.Code });
    }
}

/// <summary>Request body for replacing an access family's membership.</summary>
public sealed record UpdateFamilyMembersRequest(IReadOnlyList<Guid>? UserIds);

/// <summary>Request body for replacing a terminal's access profile (RULE-007).</summary>
public sealed record UpdateTerminalPolicyRequest(
    IReadOnlyList<Guid>? FamilyIds,
    IReadOnlyList<int>? CircuitIds);
