ENVFILE?=envs/master.inc
include $(ENVFILE)

tyk-pump: env
	@command -v mongoexport
	@scripts/pump.sh "http://localhost:8080"

tyk-analytics: analytics-preflight env dash_bootstrap
	curl -s -XGET -H "Accept: application/json" "http://localhost:8080/smoke-test-api/get?arg=test"| jq -e '.args.arg == "test"'

tyk-mdcb: mdcb-preflight env dash_bootstrap
	curl -s -XGET -H "Accept: application/json" "http://localhost:8080/smoke-test-api/get?arg=test"| jq -e '.args.arg == "test"'
	curl -s -XGET -H "Accept: application/json" "http://localhost:8082/smoke-test-api/get?arg=test"| jq -e '.args.arg == "test"'

dash_bootstrap:
ifeq ($(DASH_BOOTSTRAP),NO)
	@scripts/dash-bootstrap.sh http://localhost:3000
	@sed -i "" 's/DASH_BOOTSTRAP ?= NO/DASH_BOOTSTRAP ?= YES/g' $(ENVFILE)
	@sleep 8
endif

env: preflight
	CONFIG=$(CONFIG) REGISTRY=$(REGISTRY) docker compose -f envs/$(ENV).yml --env-file envs/$(ENV).env up -d

mdcb-preflight: analytics-preflight
	@test -n "$(TYK_MDCB_LICENSE)"

analytics-preflight:
	@test -n "$(TYK_DB_LICENSE)"

preflight:
	@command -v curl jq
ifeq ($(REGISTRY),754489498669.dkr.ecr.eu-central-1.amazonaws.com)
	aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 754489498669.dkr.ecr.eu-central-1.amazonaws.com
endif
clean:
	@echo "Tearing down docker compose.."
	CONFIG=$(CONFIG) REGISTRY=$(REGISTRY) docker compose -f envs/$(ENV).yml --env-file envs/$(ENV).env down
	rm -rf data
	git checkout -f data
	@sed -i "" 's/DASH_BOOTSTRAP ?= YES/DASH_BOOTSTRAP ?= NO/g' $(ENVFILE)

.PHONY: env preflight clean
