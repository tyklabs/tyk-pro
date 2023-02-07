external:
	docker compose -f external-components.yml -p external up -d

internal:
	docker compose -f internal-components.yml -p internal up -d

clean-external:
	docker compose -f external-components.yml -p external down

clean-internal:
	docker compose -f internal-components.yml -p internal down
	
login:
	aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 754489498669.dkr.ecr.eu-central-1.amazonaws.com

init:
	docker network create tyk-network || true
# 	docker network create internal-components || true
# 	docker network create external-components || true

all: login init external internal 
clean-all: clean-internal clean-external


.PHONY: env preflight clean init login clean-internal clean-external internal external