ENV ?= custom

env: preflight
	docker compose -f envs/$(ENV).yml --env-file envs/$(ENV).env up -d

clean:
	@echo "Tearing down docker compose.."
	docker compose -f envs/$(ENV).yml --env-file envs/$(ENV).env down

.PHONY: env preflight clean