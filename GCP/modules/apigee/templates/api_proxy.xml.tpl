<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<APIProxy revision="1" name="${proxy_name}">
  <DisplayName>${display_name}</DisplayName>
  <Description>${description}</Description>
  <BasePaths>${base_path}</BasePaths>
  <Policies>
    <Policy>JS-ValidateToken</Policy>
    <Policy>JS-PathRouter</Policy>
    <Policy>SpikeArrest</Policy>
    <Policy>AM-RemoveInternalHeaders</Policy>
  </Policies>
  <ProxyEndpoints>
    <ProxyEndpoint>default</ProxyEndpoint>
  </ProxyEndpoints>
  <TargetEndpoints>
    <TargetEndpoint>default</TargetEndpoint>
  </TargetEndpoints>
</APIProxy>
