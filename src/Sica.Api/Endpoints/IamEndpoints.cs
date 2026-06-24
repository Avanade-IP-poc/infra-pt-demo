using Sica.Application.Abstractions;
using Sica.Application.Iam;
using Sica.Application.Iam.AuthorizeTerminal;

namespace Sica.Api.Endpoints;

/// <summary>Minimal API endpoints for the IAM bounded context.</summary>
public static class IamEndpoints
{
    public static IEndpointRouteBuilder MapIamEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/v1/iam").WithTags("IAM");

        group.MapPost("/terminals/authorize", AuthorizeTerminalAsync)
            .WithName("authorizeTerminal")
            .WithOpenApi();

        return app;
    }

    private static async Task<IResult> AuthorizeTerminalAsync(
        TerminalAuthorizationRequest request,
        HttpContext httpContext,
        IQueryHandler<AuthorizeTerminalQuery, AuthorizeTerminalResult> handler,
        CancellationToken cancellationToken)
    {
        var ipAddress = ResolveClientIp(httpContext, request.IpAddress);

        var result = await handler.HandleAsync(
            new AuthorizeTerminalQuery(request.Hostname, ipAddress),
            cancellationToken);

        if (result.IsSuccess)
        {
            return Results.Ok(new TerminalAuthorizationResponse(
                Authorized: true,
                TerminalId: result.Value.TerminalId,
                TerminalName: result.Value.TerminalName));
        }

        return Results.Json(
            new { authorized = false, error = result.Error.Description, code = result.Error.Code },
            statusCode: StatusCodes.Status403Forbidden);
    }

    /// <summary>
    /// Resolves the effective client IP. When the request comes through a proxy,
    /// the first address in <c>X-Forwarded-For</c> takes precedence (RULE-001 scenario).
    /// </summary>
    private static string? ResolveClientIp(HttpContext httpContext, string? bodyIpAddress)
    {
        var forwardedFor = httpContext.Request.Headers["X-Forwarded-For"].ToString();
        if (!string.IsNullOrWhiteSpace(forwardedFor))
        {
            return forwardedFor.Split(',')[0].Trim();
        }

        return string.IsNullOrWhiteSpace(bodyIpAddress)
            ? httpContext.Connection.RemoteIpAddress?.ToString()
            : bodyIpAddress;
    }
}

public sealed record TerminalAuthorizationRequest(string? Hostname, string? IpAddress);

public sealed record TerminalAuthorizationResponse(bool Authorized, int TerminalId, string TerminalName);
