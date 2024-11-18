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
	t.Parallel()
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
	t.Parallel()
	vars := make(map[string]interface{})

	test_helper.RunE2ETest(t, "../../", "examples/startup", terraform.Options{
		Upgrade: true,
		Vars:    vars,
	}, func(t *testing.T, output test_helper.TerraformOutput) {})
}

func TestExampleAcr(t *testing.T) {
	t.Parallel()
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

func TestInitContainer(t *testing.T) {
	t.Parallel()
	test_helper.RunE2ETest(t, "../..", "examples/init-container", terraform.Options{
		Upgrade: true,
	}, func(t *testing.T, output test_helper.TerraformOutput) {
		url, ok := output["url"].(string)
		require.True(t, ok)
		html, err := getHTML(url)
		require.NoError(t, err)
		assert.Contains(t, html, "Hello from the debian container")
	})
}

func getHTML(url string) (string, error) {
	resp, err := http.Get(url) // #nosec G107
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
