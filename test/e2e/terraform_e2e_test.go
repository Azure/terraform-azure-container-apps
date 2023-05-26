package e2e

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"

	test_helper "github.com/Azure/terraform-module-test-helper"
)

func TestExamplesStartup(t *testing.T) {
	// For dapr example
	var vars map[string]any
	managedIdentityId := os.Getenv("MSI_ID")
	if managedIdentityId != "" {
		vars = map[string]any{
			"managed_identity_principal_id": managedIdentityId,
		}
	}

	test_helper.RunE2ETest(t, "../../", "examples/startup", terraform.Options{
		Upgrade: true,
		Vars:    vars,
	}, func(t *testing.T, output test_helper.TerraformOutput) {})
}

// missing test
