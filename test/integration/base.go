package integration

import (
	"crypto/tls"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/suite"
)

var (
	client = &http.Client{
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				InsecureSkipVerify: true,
			},
		},
	}
)

func NewBaseTestSuite(values map[string]string) BaseTestSuite {
	if values == nil {
		values = map[string]string{}
	}
	return BaseTestSuite{
		Options: &helm.Options{
			KubectlOptions: &k8s.KubectlOptions{
				Namespace: "default",
			},
			SetValues: values,
		},
		ReleaseName: "harbor",
		URL:         values["externalURL"],
	}
}

type BaseTestSuite struct {
	suite.Suite
	Options     *helm.Options
	ReleaseName string
	URL         string // the external URL of Harbor
}

func (b *BaseTestSuite) SetupSuite() {
	helm.Install(b.T(), b.Options, "../..", b.ReleaseName)
	b.waitUntilHealthy(b.URL)
}

type overallStatus struct {
	Status     string             `json:"status"`
	Components []*componentStatus `json:"components"`
}

type componentStatus struct {
	Name   string `json:"name"`
	Status string `json:"status"`
	Error  string `json:"error,omitempty"`
}

func (b *BaseTestSuite) waitUntilHealthy(url string) {
	url = fmt.Sprintf("%s/api/v2.0/health", url)
	log.Printf("wait until Harbor is healthy by calling health check API: %s ...", url)
	for i := 0; i < 60; i++ {
		time.Sleep(10 * time.Second)

		resp, err := client.Get(url)
		if err != nil {
			log.Printf("failed to call the health API: %v, retry 10 seconds later...", err)
			continue
		}

		if resp.StatusCode != http.StatusOK {
			log.Printf("the response status code %d != 200, retry 10 seconds later...", resp.StatusCode)
			continue
		}

		data, err := ioutil.ReadAll(resp.Body)
		b.Require().Nil(err)
		resp.Body.Close()
		status := &overallStatus{}
		err = json.Unmarshal(data, status)
		b.Require().Nil(err)
		if status.Status != "healthy" {
			for _, component := range status.Components {
				if component.Status == "healthy" {
					continue
				}
				log.Printf("the status of component %s isn't healthy: %s , retry 10 seconds later...",
					component.Name, component.Error)
				break
			}
			continue
		}

		log.Printf("the status is healthy")
		return
	}
	b.FailNow("the status still isn't healthy after several retries")
}

func (b *BaseTestSuite) TestPush() {
	addr := strings.TrimPrefix(b.URL, "http://")
	addr = strings.TrimPrefix(addr, "https://")

	// push image
	b.T().Log("pushing the image...")
	cmdStr := fmt.Sprintf("docker pull hello-world:latest;docker tag hello-world:latest %s/library/hello-world:latest; docker login %s -u admin -p Harbor12345;docker push %s/library/hello-world:latest",
		addr, addr, addr)
	cmd := exec.Command("/bin/sh", "-c", cmdStr)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	b.Require().Nil(err)

	// delete image in local
	b.T().Log("deleting the image in local")
	cmdStr = fmt.Sprintf("docker rmi %s/library/hello-world:latest", addr)
	cmd = exec.Command("/bin/sh", "-c", cmdStr)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err = cmd.Run()
	b.Require().Nil(err)

	// pull image
	b.T().Log("pull the image...")
	cmdStr = fmt.Sprintf("docker pull %s/library/hello-world:latest", addr)
	cmd = exec.Command("/bin/sh", "-c", cmdStr)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err = cmd.Run()
	b.Require().Nil(err)
}

func (b *BaseTestSuite) TearDownSuite() {
	helm.Delete(b.T(), &helm.Options{}, b.ReleaseName, true)
}
