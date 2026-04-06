// JS policy: Bearer token validation
// Extracts the Authorization header, calls the token introspection endpoint,
// and raises a 401 fault if the token is missing or invalid.
// Attached to the PreFlow request of every proxy that has token_auth_enabled = true.

var authHeader = context.getVariable("request.header.Authorization");

if (!authHeader || authHeader.indexOf("Bearer ") !== 0) {
  context.setVariable("auth.error.message", "Missing or malformed Authorization header");
  context.setVariable("auth.error.code", "401");
  throw new Error("Unauthorized");
}

var token = authHeader.split("Bearer ")[1].trim();

// Call token introspection endpoint synchronously
var tokenValidationUrl = "${token_validation_url}";
var req = new Request(tokenValidationUrl, "POST", {
  "Content-Type": "application/x-www-form-urlencoded",
  "Accept": "application/json"
}, "token=" + token);

var exchange = httpClient.send(req);
exchange.waitForComplete();

if (!exchange.isSuccess()) {
  context.setVariable("auth.error.message", "Token validation service unavailable");
  context.setVariable("auth.error.code", "503");
  throw new Error("Service Unavailable");
}

var response = exchange.getResponse();
var body = JSON.parse(response.content);

if (!body.active) {
  context.setVariable("auth.error.message", "Token is inactive or expired");
  context.setVariable("auth.error.code", "401");
  throw new Error("Unauthorized");
}

// Propagate claims as flow variables for downstream use
context.setVariable("auth.client_id", body.client_id || "");
context.setVariable("auth.scope", body.scope || "");
context.setVariable("auth.sub", body.sub || "");
