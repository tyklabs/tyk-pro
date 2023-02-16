local:
	docker compose -f docker-compose.yml -p ${COMPOSE_PROJECT_NAME}_local up -d

clean-local:
	docker compose -f docker-compose.yml -p ${COMPOSE_PROJECT_NAME}_local down

remote:
	docker compose -f docker-compose.yml -f docker-compose-ecs.yml -p ${COMPOSE_PROJECT_NAME}_remote up -d

clean-remote:
	docker compose -f docker-compose.yml -f docker-compose-ecs.yml -p ${COMPOSE_PROJECT_NAME}_remote down
	
init:
	docker network create internal-components || true
	docker network create external-components || true

convert:
	docker compose -f docker-compose.yml -f docker-compose-ecs.yml convert > docker-ecs-cft.yml

login:
	aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 754489498669.dkr.ecr.eu-central-1.amazonaws.com

context: login
#acp devacc
#docker context create ecs myecs
	docker context use myecs
	unset AWS_PROFILE
	export AWS_REGION=eu-central-1

extras:
	aws ecs update-service --cluster test --task-definition compose-simple-gateway:3 --service compose-simple-GatewayService-xwFrZgcUxPMA --enable-execute-command
.PHONY: remote local clean-local clean-remote