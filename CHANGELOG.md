# Changelog

## [Unreleased](https://github.com/Azure/terraform-azure-container-apps/tree/HEAD)

**Merged pull requests:**

- Better Front Door and Private Link integration due to module outputs  [\#68](https://github.com/Azure/terraform-azure-container-apps/pull/68) ([lonegunmanb](https://github.com/lonegunmanb))
- Add support for secrets from KV [\#67](https://github.com/Azure/terraform-azure-container-apps/pull/67) ([lonegunmanb](https://github.com/lonegunmanb))
- Add support for autoscale rules [\#66](https://github.com/Azure/terraform-azure-container-apps/pull/66) ([lonegunmanb](https://github.com/lonegunmanb))
- Bump github.com/Azure/terraform-module-test-helper in /test [\#65](https://github.com/Azure/terraform-azure-container-apps/pull/65) ([lonegunmanb](https://github.com/lonegunmanb))
- Bump github.com/Azure/terraform-module-test-helper in /test [\#62](https://github.com/Azure/terraform-azure-container-apps/pull/62) ([lonegunmanb](https://github.com/lonegunmanb))
- Use oidc as e2e test authentication method [\#60](https://github.com/Azure/terraform-azure-container-apps/pull/60) ([lonegunmanb](https://github.com/lonegunmanb))
- Add support for `container_app.ingress.ingress.ip_security_restriction` [\#50](https://github.com/Azure/terraform-azure-container-apps/pull/50) ([lonegunmanb](https://github.com/lonegunmanb))
- Better Front Door and Private Link integration due to module outputs [\#20](https://github.com/Azure/terraform-azure-container-apps/pull/20) ([icklsede](https://github.com/icklsede))

## [v0.4.0](https://github.com/Azure/terraform-azure-container-apps/tree/v0.4.0) (2023-12-26)

**Merged pull requests:**

- Add missing tracing tag variables [\#49](https://github.com/Azure/terraform-azure-container-apps/pull/49) ([lonegunmanb](https://github.com/lonegunmanb))
- Add module telemetry support [\#48](https://github.com/Azure/terraform-azure-container-apps/pull/48) ([lonegunmanb](https://github.com/lonegunmanb))
- Correct containers' `volume_mounts`'s type. [\#47](https://github.com/Azure/terraform-azure-container-apps/pull/47) ([lonegunmanb](https://github.com/lonegunmanb))
- Add support for `init_container` [\#46](https://github.com/Azure/terraform-azure-container-apps/pull/46) ([lonegunmanb](https://github.com/lonegunmanb))
- support workload profiles [\#45](https://github.com/Azure/terraform-azure-container-apps/pull/45) ([davidkarlsen](https://github.com/davidkarlsen))

## [v0.3.0](https://github.com/Azure/terraform-azure-container-apps/tree/v0.3.0) (2023-12-20)

**Merged pull requests:**

- Change `output identity_ids` to new `container_app_identities` [\#44](https://github.com/Azure/terraform-azure-container-apps/pull/44) ([lonegunmanb](https://github.com/lonegunmanb))
- Fix broken example `dapr` [\#42](https://github.com/Azure/terraform-azure-container-apps/pull/42) ([lonegunmanb](https://github.com/lonegunmanb))
- Update default value for container\_app\_environment\_internal\_load\_balancer\_enabled [\#39](https://github.com/Azure/terraform-azure-container-apps/pull/39) ([abossard](https://github.com/abossard))
- Support existing container apps environment [\#38](https://github.com/Azure/terraform-azure-container-apps/pull/38) ([davidkarlsen](https://github.com/davidkarlsen))
- Add `precondition` for `var.container_app_environment_internal_load_balancer_enabled` [\#33](https://github.com/Azure/terraform-azure-container-apps/pull/33) ([lonegunmanb](https://github.com/lonegunmanb))

## [v0.2.0](https://github.com/Azure/terraform-azure-container-apps/tree/v0.2.0) (2023-08-21)

**Merged pull requests:**

- Change exposed fqdn to ingress's fqdn [\#19](https://github.com/Azure/terraform-azure-container-apps/pull/19) ([lonegunmanb](https://github.com/lonegunmanb))
- Bump github.com/Azure/terraform-module-test-helper from 0.15.0 to 0.16.0 in /test [\#17](https://github.com/Azure/terraform-azure-container-apps/pull/17) ([dependabot[bot]](https://github.com/apps/dependabot))
- Provide static IP as part of the outputs for non-custom domain support when using private VNET [\#16](https://github.com/Azure/terraform-azure-container-apps/pull/16) ([daconstenla](https://github.com/daconstenla))
- Bump github.com/Azure/terraform-module-test-helper from 0.12.0 to 0.15.0 in /test [\#13](https://github.com/Azure/terraform-azure-container-apps/pull/13) ([dependabot[bot]](https://github.com/apps/dependabot))

## [v0.1.1](https://github.com/Azure/terraform-azure-container-apps/tree/v0.1.1) (2023-07-30)

**Merged pull requests:**

- Add registry block to the module to enable personal repos [\#11](https://github.com/Azure/terraform-azure-container-apps/pull/11) ([jiaweitao001](https://github.com/jiaweitao001))
- Add `azurerm_container_app_environment_storage` to container apps module [\#8](https://github.com/Azure/terraform-azure-container-apps/pull/8) ([jiaweitao001](https://github.com/jiaweitao001))
- Fix dapr e2e test [\#6](https://github.com/Azure/terraform-azure-container-apps/pull/6) ([jiaweitao001](https://github.com/jiaweitao001))
- Fix container app volume variable's type [\#5](https://github.com/Azure/terraform-azure-container-apps/pull/5) ([jiaweitao001](https://github.com/jiaweitao001))

## [v0.1.0](https://github.com/Azure/terraform-azure-container-apps/tree/v0.1.0) (2023-06-14)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
