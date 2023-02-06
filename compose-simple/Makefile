remote:
	ddocker compose -f docker-compose-ecs.yml -p remote up -d

local:
	docker compose -f docker-compose.yml -p local up -d

clean-local:
	docker compose -f docker-compose.yml -p local down

clean-remote:
	docker compose -f docker-compose-ecs.yml -p remote down
	
init:
	docker swarm init

convert:
	docker compose -f docker-compose.yml -f docker-compose-ecs.yml convert > docker-ecs-cft.yml

context:
	acp devacc
	docker context use myecs
	unset AWS_PROFILE
	aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 754489498669.dkr.ecr.eu-central-1.amazonaws.com
	export AWS_REGION=eu-central-1

extras:
	aws ecs update-service --cluster test --task-definition compose-simple-gateway:3 --service compose-simple-GatewayService-xwFrZgcUxPMA --enable-execute-command
.PHONY: remote local clean-local clean-remote