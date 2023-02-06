# ENV ?= custom

# env: preflight
# 	docker compose -f envs/$(ENV).yml --env-file envs/$(ENV).env up -d

# clean:
# 	@echo "Tearing down docker compose.."
# 	docker compose -f envs/$(ENV).yml --env-file envs/$(ENV).env down

external:
	docker compose -f external-components.yml -p external up -d

internal:
	docker compose -f internal-components.yml -p internal up -d

clean-external:
	docker compose -f external-components.yml -p external down

clean-internal:
	docker compose -f internal-components.yml -p internal down
	
init:
	docker swarm init

.PHONY: env preflight clean