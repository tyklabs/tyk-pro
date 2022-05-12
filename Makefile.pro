# <-- Should we leave an entry for each component test?
tyk-gw: env
	curl -s -XGET -H "Accept: application/json" "http://localhost:8080/test/get?arg=test"| jq -e '.args.arg == "test"'

tyk-pump: env
	@command -v mongoexport
	@scripts/$(ENV)/pump.sh "http://localhost:8080"

tyk-analytics: env
	@scripts/$(ENV)/dash-bootstrap.sh http://localhost:3000
	@sleep 5
	curl -s -XGET -H "Accept: application/json" "http://localhost:8080/smoke-test-api/get?arg=test"| jq -e '.args.arg == "test"'
# -->

# <-- Should instead call pro to execute all tests?
pro: env
	@scripts/$(ENV)/dash-bootstrap.sh http://localhost:3000
	@sleep 5
	curl -s -XGET -H "Accept: application/json" "http://localhost:8080/smoke-test-api/get?arg=test"| jq -e '.args.arg == "test"'
  # GW   test for pro
  # PUMP test for pro
# -->

env: preflight
	docker compose -f envs/$(ENV).yml --env-file envs/$(ENV).env up -d

preflight:
	@command -v curl jq
	aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 754489498669.dkr.ecr.eu-central-1.amazonaws.com

clean:
	@echo "Tearing down docker compose.."
	docker compose -f envs/$(ENV).yml --env-file envs/$(ENV).env down

.PHONY: env preflight clean