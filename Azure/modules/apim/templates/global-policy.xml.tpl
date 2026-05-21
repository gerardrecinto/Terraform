<policies>
  <inbound>
    <base />
    <validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized">
      <openid-config url="https://login.microsoftonline.com/${tenant_id}/v2.0/.well-known/openid-configuration" />
      <audiences>
        <audience>${audience}</audience>
      </audiences>
      <issuers>
        <issuer>${issuer}</issuer>
      </issuers>
    </validate-jwt>
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
    <set-header name="X-Powered-By" exists-action="delete" />
    <set-header name="X-AspNet-Version" exists-action="delete" />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
