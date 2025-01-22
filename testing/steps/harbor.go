package steps

import (
	"context"
	"time"

	"github.com/AlaudaDevops/bdd/asserts"
	"github.com/AlaudaDevops/bdd/logger"
	"github.com/AlaudaDevops/bdd/steps/kubernetes/resource"
	"github.com/cucumber/godog"
	"go.uber.org/zap"
)

// Steps provides Kubernetes resource management step definitions
type Steps struct {
}

// InitializeSteps registers resource assertion and import steps
func (cs Steps) InitializeSteps(ctx context.Context, scenarioCtx *godog.ScenarioContext) context.Context {
	scenarioCtx.Step(`^"([^"]*)" 组件检查通过$`, stepHarborResourceConditionCheck)
	scenarioCtx.Step(`^SSO 测试通过$`, checkSSo)
	return ctx
}

func stepHarborResourceConditionCheck(ctx context.Context, instanceName string) (context.Context, error) {
	log := logger.LoggerFromContext(ctx)
	checks := getInstanceChecks(ctx, instanceName)
	for _, check := range checks {
		_, err := resource.AssertResource(ctx, check)
		if err != nil {
			log.Error("check harbor component condition failed", zap.Error(err), zap.String("name", check.Name))
			return ctx, err
		}
		log.Info("check harbor component condition success", zap.String("name", check.Name))
	}

	return ctx, nil
}

func getComponentCheck(instanceName, componentName string) resource.Assert {
	return resource.Assert{
		AssertBase: resource.AssertBase{
			Resource: resource.Resource{
				Kind:       "Pod",
				APIVersion: "v1",
				Name:       instanceName + "-" + componentName,
			},
			PathValue: asserts.PathValue{
				Path:  "$.status.conditions[?(@.type == 'Ready')][0].status",
				Value: "True",
			},
		},
		CheckTime: resource.CheckTime{
			Interval: 10 * time.Second,
			Timeout:  10 * time.Minute,
		},
	}
}

func getInstanceChecks(_ context.Context, instanceName string) []resource.Assert {
	return []resource.Assert{
		getComponentCheck(instanceName, "registry"),
		getComponentCheck(instanceName, "trivy"),
		getComponentCheck(instanceName, "core"),
		getComponentCheck(instanceName, "jobservice"),
	}
}
