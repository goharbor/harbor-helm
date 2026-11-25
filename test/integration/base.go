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
	"path/filepath"
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
		Timeout: 30 * time.Second,
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
	CACertPath  string
}

func (b *BaseTestSuite) SetupSuite() {
	helm.Install(b.T(), b.Options, "../..", b.ReleaseName)
	b.loadRegistryCA()
	b.waitUntilHealthy(b.URL)
}

// loadRegistryCA saves the chart's generated CA for imgpkg's registry requests.
func (b *BaseTestSuite) loadRegistryCA() {
	secretName := b.ReleaseName + "-ingress"
	if b.Options.SetValues["expose.type"] != "" && b.Options.SetValues["expose.type"] != "ingress" {
		secretName = b.ReleaseName + "-nginx"
	}

	output, err := exec.Command("kubectl", "-n", b.Options.KubectlOptions.Namespace,
		"get", "secret", secretName, "-o", "json").CombinedOutput()
	b.Require().NoError(err, "get generated TLS secret %s: %s", secretName, output)

	var secret struct {
		Data map[string][]byte `json:"data"`
	}
	b.Require().NoError(json.Unmarshal(output, &secret))
	ca := secret.Data["ca.crt"]
	b.Require().NotEmpty(ca, "generated TLS secret %s has no ca.crt", secretName)

	file, err := ioutil.TempFile("", "harbor-registry-ca-*.crt")
	b.Require().NoError(err)
	b.CACertPath = file.Name()
	_, err = file.Write(ca)
	b.Require().NoError(err, "write generated registry CA")
	b.Require().NoError(file.Close())
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

	image := addr + "/library/hello-world:latest"
	log.Print("copying the image into Harbor...")
	cmd := exec.Command("imgpkg", "copy", "-i", "docker.io/library/hello-world:latest",
		"--to-repo", addr+"/library/hello-world", "--registry-ca-cert-path", b.CACertPath)
	cmd.Env = append(os.Environ(),
		"IMGPKG_REGISTRY_HOSTNAME_0="+addr,
		"IMGPKG_REGISTRY_USERNAME_0=admin",
		"IMGPKG_REGISTRY_PASSWORD_0=Harbor12345")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	b.Require().NoError(cmd.Run(), "copy image into Harbor")

	log.Print("copying the image back from Harbor...")
	archiveDir, err := ioutil.TempDir("", "harbor-image-*")
	b.Require().NoError(err)
	defer os.RemoveAll(archiveDir)
	archive := filepath.Join(archiveDir, "hello-world.tar")
	cmd = exec.Command("imgpkg", "copy", "-i", image,
		"--to-tar", archive, "--registry-ca-cert-path", b.CACertPath)
	cmd.Env = append(os.Environ(),
		"IMGPKG_REGISTRY_HOSTNAME_0="+addr,
		"IMGPKG_REGISTRY_USERNAME_0=admin",
		"IMGPKG_REGISTRY_PASSWORD_0=Harbor12345")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	b.Require().NoError(cmd.Run(), "copy image back from Harbor")
}

func (b *BaseTestSuite) TearDownSuite() {
	helm.Delete(b.T(), b.Options, b.ReleaseName, true)
	if b.CACertPath != "" {
		b.Require().NoError(os.Remove(b.CACertPath))
	}
}
