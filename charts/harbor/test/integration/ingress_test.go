package integration

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/suite"
)

type IngressTestSuite struct {
	BaseTestSuite
}

func (i *IngressTestSuite) TestIngress() {
	k8s.GetIngress(i.T(), i.Options.KubectlOptions, fmt.Sprintf("%s-ingress", i.ReleaseName))
	k8s.GetIngress(i.T(), i.Options.KubectlOptions, fmt.Sprintf("%s-ingress-notary", i.ReleaseName))
}

func TestIngressTestSuite(t *testing.T) {
	suite.Run(t, &IngressTestSuite{
		BaseTestSuite: NewBaseTestSuite(map[string]string{
			"expose.ingress.hosts.core":   "harbor.local",
			"expose.ingress.hosts.notary": "notary.harbor.local",
			"externalURL":                 "https://harbor.local",
		}),
	})
}
