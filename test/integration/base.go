package integration

import (
	"crypto/tls"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"math/rand"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"sync"
	"time"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/testing"
	"github.com/stretchr/testify/suite"
)

func init() {
	// override the default logger to make the log in the same style
	logger.Default = logger.New(&Logger{})
}

var (
	client = &http.Client{
		Timeout: 30*time.Second,
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				InsecureSkipVerify: true,
			},
		},
	}
)

type Logger struct{}

func (l *Logger) Logf(t testing.TestingT, format string, args ...interface{}) {
	log.Printf(format, args...)
}

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
		ReleaseName: fmt.Sprintf("harbor-%d", rand.Int()),
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
	var (
		timeout bool
		done    = make(chan struct{})
		lock    = sync.RWMutex{}
	)
	go func() {
		log.Printf("wait until Harbor is healthy by calling the health check API ...")
		stop := false
		for !stop {
			if err := healthy(url); err != nil {
				log.Printf("the status of Harbor isn't healthy: %v, will retry 10 seconds later...", err)
				time.Sleep(10 * time.Second)
				lock.RLock()
				stop = timeout
				lock.RUnlock()
				continue
			}
			log.Printf("the status of Harbor is healthy")
			done <- struct{}{}
			return
		}
	}()

	select {
	case <-done:
		return
	case <-time.After(10 * time.Minute):
		lock.Lock()
		timeout = true
		lock.Unlock()
		log.Print("timeout when checking the status")
		b.FailNow("timeout when checking the status")
	}
}

func healthy(url string) error {
	resp, err := client.Get(fmt.Sprintf("%s/api/v2.0/health", url))
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	data, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("the response status code %d != 200, response body: %s", resp.StatusCode, string(data))
	}

	status := &overallStatus{}
	if err = json.Unmarshal(data, status); err != nil {
		return err
	}
	if status.Status != "healthy" {
		for _, component := range status.Components {
			if component.Status == "healthy" {
				continue
			}
			return fmt.Errorf("the status of component %s isn't healthy: %s ", component.Name, component.Error)
		}
		return fmt.Errorf("the overall status is unhealthy, but all components are healthy")
	}
	return nil
}

func (b *BaseTestSuite) TestPush() {
	addr := strings.TrimPrefix(b.URL, "http://")
	addr = strings.TrimPrefix(addr, "https://")

	// push image
	log.Print("pushing the image...")
	cmdStr := fmt.Sprintf("docker pull hello-world:latest;docker tag hello-world:latest %s/library/hello-world:latest; docker login %s -u admin -p Harbor12345;docker push %s/library/hello-world:latest",
		addr, addr, addr)
	cmd := exec.Command("/bin/sh", "-c", cmdStr)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	b.Require().Nil(err)

	// delete image in local
	log.Print("deleting the image in local")
	cmdStr = fmt.Sprintf("docker rmi %s/library/hello-world:latest", addr)
	cmd = exec.Command("/bin/sh", "-c", cmdStr)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err = cmd.Run()
	b.Require().Nil(err)

	// pull image
	log.Print("pull the image...")
	cmdStr = fmt.Sprintf("docker pull %s/library/hello-world:latest", addr)
	cmd = exec.Command("/bin/sh", "-c", cmdStr)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err = cmd.Run()
	b.Require().Nil(err)
}

func (b *BaseTestSuite) TearDownSuite() {
	helm.Delete(b.T(), b.Options, b.ReleaseName, true)
}
