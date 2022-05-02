ENV ?= master
CONFIG ?= master

tyk-analytics: analytics-preflight env
	@scripts/dash-bootstrap.sh http://localhost:3000
	curl -s -XGET -H "Accept: application/json" "http://localhost:8080/smoke-test-api/get?arg=test"| jq -e '.args.arg == "test"'

tyk-mdcb: mdcb-preflight env
	@scripts/mdcb-dash-bootstrap.sh http://localhost:3000
	curl -s -XGET -H "Accept: application/json" "http://localhost:8080/smoke-test-api/get?arg=test"| jq -e '.args.arg == "test"'
	curl -s -XGET -H "Accept: application/json" "http://localhost:8082/smoke-test-api/get?arg=test"| jq -e '.args.arg == "test"'

env: preflight
	CONFIG=$(CONFIG) docker compose -f envs/$(ENV).yml up -d
	sleep 8 # wait for a bit

mdcb-preflight: analytics-preflight
	@test -n "$(MDCB_LICENSE)"

analytics-preflight:
	@test -n "$(TYK_DB_LICENSE)"

preflight:
	@command -v curl jq
	aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 754489498669.dkr.ecr.eu-central-1.amazonaws.com

.PHONY: env preflight
