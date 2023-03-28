package e2e

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"

	test_helper "github.com/Azure/terraform-module-test-helper"
)

func TestExamplesComplete(t *testing.T) {
	vars := make(map[string]interface{})

	test_helper.RunE2ETest(t, "../../", "examples/startup", terraform.Options{
		Upgrade: true,
		Vars:    vars,
	}, func(t *testing.T, output test_helper.TerraformOutput) {})
}
