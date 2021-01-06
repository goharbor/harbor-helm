package integration

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/suite"
)

type IngressTestSuite struct {
	BaseTestSuite
}

func (i *IngressTestSuite) TestIngress() {
	k8s.GetIngress(i.T(), i.Options.KubectlOptions, "harbor-ingress")
	k8s.GetIngress(i.T(), i.Options.KubectlOptions, "harbor-ingress-notary")
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
