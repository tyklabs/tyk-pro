#Overview

This folder contains a `docker-compose.yml` file which represents a simple oss LOCAL deployment, it also contains a `docker-compose-ecs.yml` that add the necesary overrides to have the same deployment successfully deployed over ECS.
This examples have been adjusted (overrides) to work on top of the current infra-prod deployment.

#Local Deployment
``` 
make login
make local
```

#Remote Deployment
```
make context
make remote
```