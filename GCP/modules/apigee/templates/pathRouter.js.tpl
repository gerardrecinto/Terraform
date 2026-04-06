// JS policy: path-based routing
// Inspects the request path suffix and sets target.url to the matching backend.
// Falls through to the default TargetEndpoint URL if no route matches.
//
// Routes are compiled from the path_routes variable in Terraform:
// %{ for path, backend in path_routes }
//   ${path} -> ${backend}
// %{ endfor }

var pathSuffix = context.getVariable("proxy.pathsuffix") || "/";
var targetUrl = null;

var routes = [
  %{ for path, backend in path_routes ~}
  { prefix: "${path}", backend: "${backend}" },
  %{ endfor ~}
];

for (var i = 0; i < routes.length; i++) {
  if (pathSuffix.indexOf(routes[i].prefix) === 0) {
    targetUrl = routes[i].backend;
    break;
  }
}

if (targetUrl) {
  // Overrides the TargetEndpoint URL for this transaction only
  context.setVariable("target.url", targetUrl + pathSuffix.substring(routes[i].prefix.length));
}

// Log the routing decision for Apigee Analytics
context.setVariable("routing.matched_backend", targetUrl || "default");
context.setVariable("routing.path_suffix", pathSuffix);
