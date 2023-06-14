package e2e

import (
	"os"
	"testing"

	test_helper "github.com/Azure/terraform-module-test-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExamplesDapr(t *testing.T) {
	// For dapr example
	var vars map[string]any
	managedIdentityId := os.Getenv("MSI_ID")
	if managedIdentityId != "" {
		vars = map[string]interface{}{
			"managed_identity_principal_id": managedIdentityId,
		}
	}

	test_helper.RunE2ETest(t, "../../", "examples/dapr", terraform.Options{
		Upgrade: true,
		Vars:    vars,
	}, func(t *testing.T, output test_helper.TerraformOutput) {})
}

func TestExamplesStartup(t *testing.T) {
	vars := make(map[string]interface{})

	test_helper.RunE2ETest(t, "../../", "examples/startup", terraform.Options{
		Upgrade: true,
		Vars:    vars,
	}, func(t *testing.T, output test_helper.TerraformOutput) {})
}
