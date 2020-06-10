package integration

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/stretchr/testify/suite"
)

type IngressTestSuite struct {
	suite.Suite
}

func (suite *IngressTestSuite) TestDefaultValues() {
	t := suite.T()

	helmChartPath := "../../"

	kubectlOptions := k8s.NewKubectlOptions("", "", "default")

	options := &helm.Options{
		KubectlOptions: kubectlOptions,
	}

	releaseName := fmt.Sprintf("harbor-%s", strings.ToLower(random.UniqueId()))
	defer func() {
		helm.Delete(t, options, releaseName, true)
	}()

	helm.Install(t, options, helmChartPath, releaseName)
}

func TestIngressTestSuite(t *testing.T) {
	suite.Run(t, &IngressTestSuite{})
}
