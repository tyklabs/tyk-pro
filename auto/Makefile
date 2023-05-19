REGISTRY := 754489498669.dkr.ecr.eu-central-1.amazonaws.com

login:
ifdef $(AWS_ACCESS_KEY_ID)
	aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 754489498669.dkr.ecr.eu-central-1.amazonaws.com
else
	$(error login to AWS first)
endif

master.env:
	docker compose -f tyk.yml -f deps.yml -p $(@:.env=) --env-file $@ up -d

.PHONY: master.env
