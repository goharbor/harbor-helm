REPORT ?= pretty
GODOG_ARGS ?= --godog.concurrency=2 --godog.format=$(REPORT)
E2E_CONFIG ?= ./config.yaml
TEST_COMMAND ?= go test -timeout=1h -v -count 1 .
ARCH ?= amd64
BIN ?= ./bin

build:
	GOOS=linux GOARCH=$(ARCH) go test -c -o "$(BIN)/gitlab.test" ./

generate:
	@bash hack/generate-values-snippet.sh

create-testing-ns:
	kubectl create ns bdd-testing || true

TAGS ?= gitlab-chart-deploy-ha
test: create-testing-ns
	$(TEST_COMMAND) $(GODOG_ARGS) --godog.tags=$(TAGS)

test-smoke: create-testing-ns
	$(TEST_COMMAND) $(GODOG_ARGS) --godog.tags="@test"

test-all: create-testing-ns
	$(TEST_COMMAND) $(GODOG_ARGS) --godog.tags="~@e2e"

test-e2e: create-testing-ns
	bash -x hack/run-e2e.sh $(E2E_CONFIG)

report:
	allure generate --clean
	allure open

help:
	go test -v . --godog.help
