package test

import (
	"testing"

	"github.com/Jeffail/gabs"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformDNSxample(t *testing.T, opts *terraform.Options) {

	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/dns",
	})

	expectedHostedZoneName := "exampledns.lucasvinals.com"

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// actualHostedZoneName := terraform.Output(t, terraformOptions, "module.dns.route53.hostedZone.name")

	jsonParsed, err := gabs.ParseJSON([]byte(terraform.OutputJson(t, opts, "")))

	if err != nil {
		panic(err)
	}

	actualRoute53Output, _ := jsonParsed.JSONPointer("/r/value")

	actualHostedZoneName := actualRoute53Output.Search("threat_intel_mode").Data().(string)

	assert.Equal(t, expectedHostedZoneName, actualHostedZoneName)
}
