package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the example in examples/one-db using Terratest.
func TestBackupModule(t *testing.T) {
	// Random generate a string for naming resources
	uniqueID := strings.ToLower(random.UniqueId())
	resourceName := fmt.Sprintf("test%s", uniqueID)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Path to where our Terraform code is
		TerraformDir: "../examples/vault",
		Upgrade:      true,

		// Variables to pass using -var-file option
		Vars: map[string]interface{}{
			"name_prefix": resourceName,
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// Run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables
	backupPlanArn := terraform.Output(t, terraformOptions, "backup_plan_arn")
	backupVaultID := terraform.Output(t, terraformOptions, "backup_vault_id")

	// Verify we're getting back the outputs we expect
	assert.Contains(t, backupPlanArn, "arn:aws:backup:eu-west-1:")
	assert.Equal(t, backupVaultID, "test"+uniqueID+"-vault")
}
