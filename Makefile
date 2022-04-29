ENV ?= pump-master
CONFIG ?= pump-master

include envs/$(ENV).inc

tyk-pump: env
	@command -v mongoexport
	@scripts/pump.sh "http://localhost:8080"

tyk-analytics: env
	@scripts/dash-bootstrap.sh http://localhost:3000
	curl -s -XGET -H "Accept: application/json" "http://localhost:8080/smoke-test-api/get?arg=test"| jq -e '.args.arg == "test"'

env: preflight
	REGISTRY=$(REGISTRY) GWIMAGE=$(GWIMAGE) DBIMAGE=$(DBIMAGE) PUMPIMAGE=$(PUMPIMAGE) CONFIG=$(CONFIG) docker compose -f envs/$(ENV).yml up -d
	@sleep 5 # wait for a bit

preflight:
	@test -n "$(TYK_DB_LICENSE)"
	@command -v curl jq
ifeq ($(REGISTRY),754489498669.dkr.ecr.eu-central-1.amazonaws.com)
	aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 754489498669.dkr.ecr.eu-central-1.amazonaws.com
endif

cleanup:
	@echo "Tearing down docker compose.."
	REGISTRY=$(REGISTRY) GWIMAGE=$(GWIMAGE) DBIMAGE=$(DBIMAGE) PUMPIMAGE=$(PUMPIMAGE) CONFIG=$(CONFIG) docker compose -f envs/$(ENV).yml down

.PHONY: env preflight
