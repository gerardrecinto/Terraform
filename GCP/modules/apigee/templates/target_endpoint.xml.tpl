<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<TargetEndpoint name="default">
  <PreFlow name="PreFlow">
    <Request/>
    <Response/>
  </PreFlow>

  <PostFlow name="PostFlow">
    <Request/>
    <Response/>
  </PostFlow>

  <HTTPTargetConnection>
    <URL>${target_url}</URL>
    <Properties>
      <Property name="connect.timeout.millis">5000</Property>
      <Property name="io.timeout.millis">30000</Property>
    </Properties>
  </HTTPTargetConnection>
</TargetEndpoint>
