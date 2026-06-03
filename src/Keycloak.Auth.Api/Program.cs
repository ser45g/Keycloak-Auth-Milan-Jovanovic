using System.Security.Claims;
using System.Text.Json;
using Keycloak.Auth.Api.Extensions;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.IdentityModel.Tokens;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGenWithAuthSupport(builder.Configuration);

builder.Services.AddAuthorization();
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.RequireHttpsMetadata = false;
        options.Audience = builder.Configuration["Authentication:Audience"];
        options.MetadataAddress = builder.Configuration["Authentication:MetadataAddress"]!;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidIssuer = builder.Configuration["Authentication:ValidIssuer"]
        };
    });

builder.Services
    .AddOpenTelemetry()
    .ConfigureResource(resource => resource.AddService("Keycloak.Auth.Api"))
    .WithTracing(tracing =>
    {
        tracing
            .AddAspNetCoreInstrumentation()
            .AddHttpClientInstrumentation();

        tracing.AddOtlpExporter();
    });

WebApplication app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapGet("users/me", ContentHttpResult (ClaimsPrincipal claimsPrincipal) =>
{
    return TypedResults.Content(JsonSerializer.Serialize(claimsPrincipal.Claims.Select(x=>x.ToString())));
})
.RequireAuthorization();

app.UseAuthentication();

app.UseAuthorization();

app.Run();
