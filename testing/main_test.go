package harbor

import (
	"os"
	"testing"

	harbor "harbor/steps"

	"github.com/AlaudaDevops/bdd"
	"github.com/AlaudaDevops/bdd/steps"
	"k8s.io/apimachinery/pkg/runtime"
	utilruntime "k8s.io/apimachinery/pkg/util/runtime"
	clientgoscheme "k8s.io/client-go/kubernetes/scheme"

	// register built-in config generators
	_ "github.com/AlaudaDevops/bdd/steps/kubernetes/generators"
)

var (
	scheme = runtime.NewScheme()
)

func init() {
	utilruntime.Must(clientgoscheme.AddToScheme(scheme))
}

func TestMain(m *testing.M) {
	bdd.New().
		WithOption(bdd.WithFeaturePaths("./features")).
		WithExtensions(bdd.SharedClient(scheme)). // inject k8s client
		WithSteps(steps.BuiltinSteps...).
		WithSteps(harbor.Steps{}).
		Run()

	exitVal := m.Run()
	os.Exit(exitVal)
}
