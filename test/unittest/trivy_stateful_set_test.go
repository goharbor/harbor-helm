package unittest

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/stretchr/testify/suite"
	appsV1 "k8s.io/api/apps/v1"
)

type TrivyStatefulSetTestSuite struct {
	suite.Suite
}

func (suite *TrivyStatefulSetTestSuite) render(values map[string]string) *appsV1.StatefulSet {
	helmChartPath := "../../"

	options := &helm.Options{
		SetValues: values,
	}

	debug := os.Getenv("debug")
	if debug != "true" {
		options.Logger = logger.Discard
	}

	output := helm.RenderTemplate(suite.T(), options, helmChartPath, "harbor", []string{"templates/trivy/trivy-sts.yaml"})

	var ss appsV1.StatefulSet
	helm.UnmarshalK8SYaml(suite.T(), output, &ss)

	return &ss
}

func (suite *TrivyStatefulSetTestSuite) TestPersistenceDisabled() {
	values := map[string]string{
		"persistence.enabled": "false",
		"persistence.persistentVolumeClaim.trivy.existingClaim": "trivy-data",
	}

	ss := suite.render(values)
	suite.Len(ss.Spec.Template.Spec.Volumes, 1)
	suite.NotNil(ss.Spec.Template.Spec.Volumes[0].EmptyDir)
	suite.Len(ss.Spec.VolumeClaimTemplates, 0)
}

func (suite *TrivyStatefulSetTestSuite) TestPersistenceEnabled() {
	values := map[string]string{
		"persistence.enabled": "true",
	}

	ss := suite.render(values)
	suite.Len(ss.Spec.Template.Spec.Volumes, 0)
	suite.Len(ss.Spec.VolumeClaimTemplates, 1)
}

func (suite *TrivyStatefulSetTestSuite) TestExistingClaim() {
	values := map[string]string{
		"persistence.enabled": "true",
		"persistence.persistentVolumeClaim.trivy.existingClaim": "trivy-data",
	}

	ss := suite.render(values)
	suite.Len(ss.Spec.Template.Spec.Volumes, 1)
	suite.NotNil(ss.Spec.Template.Spec.Volumes[0].PersistentVolumeClaim)
	suite.Equal("trivy-data", ss.Spec.Template.Spec.Volumes[0].PersistentVolumeClaim.ClaimName)
	suite.Len(ss.Spec.VolumeClaimTemplates, 0)
}

func (suite *TrivyStatefulSetTestSuite) TestInternalTLSEnabled() {
	{
		values := map[string]string{
			"internalTLS.enabled": "true",
			"persistence.enabled": "false",
		}

		ss := suite.render(values)
		suite.Len(ss.Spec.Template.Spec.Volumes, 2)
		suite.Len(ss.Spec.VolumeClaimTemplates, 0)
	}

	{
		values := map[string]string{
			"internalTLS.enabled": "true",
			"persistence.enabled": "true",
		}

		ss := suite.render(values)
		suite.Len(ss.Spec.Template.Spec.Volumes, 1)
		suite.Len(ss.Spec.VolumeClaimTemplates, 1)
	}

	{
		values := map[string]string{
			"internalTLS.enabled": "true",
			"persistence.enabled": "true",
			"persistence.persistentVolumeClaim.trivy.existingClaim": "trivy-data",
		}

		ss := suite.render(values)
		suite.Len(ss.Spec.Template.Spec.Volumes, 2)
		suite.Len(ss.Spec.VolumeClaimTemplates, 0)
	}
}

func (suite *TrivyStatefulSetTestSuite) TestCustomCA() {
	{
		values := map[string]string{
			"caBundleSecretName":  "ca-bundle-secret",
			"persistence.enabled": "false",
		}

		ss := suite.render(values)
		suite.Len(ss.Spec.Template.Spec.Volumes, 2)
		suite.Len(ss.Spec.VolumeClaimTemplates, 0)
	}

	{
		values := map[string]string{
			"caBundleSecretName":  "ca-bundle-secret",
			"internalTLS.enabled": "true",
			"persistence.enabled": "false",
		}

		ss := suite.render(values)
		suite.Len(ss.Spec.Template.Spec.Volumes, 3)
		suite.Len(ss.Spec.VolumeClaimTemplates, 0)
	}

	{
		values := map[string]string{
			"caBundleSecretName":  "ca-bundle-secret",
			"internalTLS.enabled": "true",
			"persistence.enabled": "true",
			"persistence.persistentVolumeClaim.trivy.existingClaim": "trivy-data",
		}

		ss := suite.render(values)
		suite.Len(ss.Spec.Template.Spec.Volumes, 3)
		suite.Len(ss.Spec.VolumeClaimTemplates, 0)
	}

	{
		values := map[string]string{
			"caBundleSecretName":  "ca-bundle-secret",
			"persistence.enabled": "true",
		}

		ss := suite.render(values)
		suite.Len(ss.Spec.Template.Spec.Volumes, 1)
		suite.Len(ss.Spec.VolumeClaimTemplates, 1)
	}

	{
		values := map[string]string{
			"caBundleSecretName":  "ca-bundle-secret",
			"persistence.enabled": "true",
			"persistence.persistentVolumeClaim.trivy.existingClaim": "trivy-data",
		}

		ss := suite.render(values)
		suite.Len(ss.Spec.Template.Spec.Volumes, 2)
		suite.Len(ss.Spec.VolumeClaimTemplates, 0)
	}
}

func TestTrivyStatefulSetTestSuite(t *testing.T) {
	suite.Run(t, &TrivyStatefulSetTestSuite{})
}
