# Overview

This folder contains a `docker-compose.yml` file which represents a simple oss LOCAL deployment, it also contains a `docker-compose-ecs.yml` that add the necesary overrides to have the same deployment successfully deployed over ECS.
This examples have been adjusted (overrides) to work on top of the current infra-prod deployment.

----


# Local Deployment
## Create
``` 
task login
task local
```
## Test
```
task test
```
## Destroy
``` 
task clean
```


# Remote Deployment over ECS
## Create
``` 
acp devacc
unset AWS_PROFILE
task login
task remote
```
## Test
```
task test-remote
```

## Destroy
``` 
task clean-remote
```

# List commands
```
task --list-all
```

#TO-DO
- Explain how to bundle certificates. Document how to generate
- 