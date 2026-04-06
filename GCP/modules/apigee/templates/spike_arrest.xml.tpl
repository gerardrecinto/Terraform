<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<!-- Spike arrest: smooths traffic bursts before they hit backends -->
<!-- 600pm = 10 requests per second sustained; bursts absorbed by Apigee -->
<SpikeArrest name="SpikeArrest">
  <DisplayName>SpikeArrest</DisplayName>
  <Rate>600pm</Rate>
  <Identifier ref="client.ip"/>
  <UseEffectiveCount>true</UseEffectiveCount>
</SpikeArrest>
