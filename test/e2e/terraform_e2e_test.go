package e2e

import (
	"io"
	"net/http"
	"os"
	"testing"

	test_helper "github.com/Azure/terraform-module-test-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
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

func TestExampleAcr(t *testing.T) {
	test_helper.RunE2ETest(t, "../..", "examples/acr", terraform.Options{
		Upgrade: true,
	}, func(t *testing.T, output test_helper.TerraformOutput) {
		urls, ok := output["app_url"].(map[string]any)
		require.True(t, ok)
		url := urls["nginx"].(string)
		html, err := getHTML(url)
		require.NoError(t, err)
		assert.Contains(t, html, "nginx")
	})
}

func getHTML(url string) (string, error) {
	resp, err := http.Get(url)
	if err != nil {
		return "", err
	}
	defer func() {
		_ = resp.Body.Close()
	}()

	bytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	return string(bytes), nil
}
