package integration

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/suite"
)

type NodePortTestSuite struct {
	BaseTestSuite
}

func (n *NodePortTestSuite) TestNodePort() {
	service := k8s.GetService(n.T(), n.Options.KubectlOptions, "harbor")
	n.Equal("NodePort", string(service.Spec.Type))
}

func TestNodePortTestSuite(t *testing.T) {
	suite.Run(t, &NodePortTestSuite{
		BaseTestSuite: NewBaseTestSuite(map[string]string{
			"expose.type":                          "nodePort",
			"expose.tls.auto.commonName":           "127.0.0.1",
			"expose.nodePort.ports.https.nodePort": "30003",
			"externalURL":                          "https://127.0.0.1:30003",
		}),
	})
}
