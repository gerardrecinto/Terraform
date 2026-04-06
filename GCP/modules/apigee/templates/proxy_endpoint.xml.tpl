<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<ProxyEndpoint name="default">
  <Description>Proxy endpoint for ${proxy_name}</Description>

  <PreFlow name="PreFlow">
    <Request>
      <!-- Validate Bearer token before any routing -->
      <Step><Name>JS-ValidateToken</Name></Step>
      <!-- Rate limiting -->
      <Step><Name>SpikeArrest</Name></Step>
      <!-- Determine target backend from request path -->
      <Step><Name>JS-PathRouter</Name></Step>
    </Request>
    <Response/>
  </PreFlow>

  <Flows>
    %{ for path, backend in path_routes ~}
    <Flow name="${replace(path, "/", "-")}">
      <Description>Route ${path} to ${backend}</Description>
      <Request/>
      <Response/>
      <Condition>(proxy.pathsuffix MatchesPath "${path}*")</Condition>
    </Flow>
    %{ endfor ~}
  </Flows>

  <PostFlow name="PostFlow">
    <Request/>
    <Response>
      <!-- Remove internal headers before returning to client -->
      <Step><Name>AM-RemoveInternalHeaders</Name></Step>
    </Response>
  </PostFlow>

  <HTTPProxyConnection>
    <BasePath>${base_path}</BasePath>
    <VirtualHost>secure</VirtualHost>
  </HTTPProxyConnection>

  <RouteRule name="default">
    <TargetEndpoint>${target_name}</TargetEndpoint>
  </RouteRule>
</ProxyEndpoint>
