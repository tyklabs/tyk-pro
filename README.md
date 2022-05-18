# System Testing

This repo is meant to host the system testing infrastructure and code. Within each repo there are CI tests which are meant to quickly give feedback on PRs. In this repo, we explore higher abstractions of testing, including but not limited to,
- interaction between various component versions
- multi-architecture support
- performance benchmarking

## How to login to AWS ECR
You need an access token and a functional AWS CLI with the subaccount to publish, install, and delete packages in AWS ECR. There is [a note in OneLogin](https://tyk.onelogin.com/notes/108502) with the AWS credentials which have just enough privileges to push and pull from the registry as well as access to logs. Once you have the CLI functional, you can login with:

``` shellsession
% aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 754489498669.dkr.ecr.eu-central-1.amazonaws.com
```

## Folder estructure (WIP)
```
tyk-pro-demo/
├─ confs/
│  ├─ oss/
│  │  ├─ tyk.conf
│  ├─ pro/
│  ├─ proha/
│  ├─ env n.../
├─ data/
│  ├─ oss/
│  │  ├─ api.json
│  │  ├─ org.json
│  ├─ pro/
│  ├─ proha/
│  ├─ env n.../
├─ envs/
│  ├─ oss/
│  │  ├─ compose.yml
│  ├─ pro/
│  ├─ proha/
│  ├─ env n.../
├─ scripts/
│  ├─ oss/
│  │  ├─ bootstrap.sh
│  ├─ pro/
│  ├─ proha/
│  ├─ env n.../
├─ Makefile
```

# PREREQUISITES
- docker compose v2 or above (not docker-compose)
- aws integration account credentials
- dashboard license (fill in envs/*.env files)
- mdcb license (fill in envs/*.env files)

# Example environments

## OSS: GW + PUMP + REDIS + MONGO

![image](envs/oss.png)

## PRO: GW + PUMP + DASH + REDIS + MONGO

![image](envs/pro.png)

## PROHA: GW + PUMP + DASH + REDIS + MONGO + MDCB + GW-SLAVE + REDIS-SLAVE

![image](envs/proha.png)
# How to execute (WIP can change)
## OSS
```
# gw test
make -f Makefile.oss oss
# pump test
make -f Makefile.oss tyk-pump
# destroy
make -f Makefile.oss clean
```

## PRO
```
# dashboard & gw test
make -f Makefile.pro pro
# clean
make -f Makefile.pro clean
```

## PRO + HA
```
# dashboard & gw & mdcb test
make -f Makefile.proha proha
make -f Makefile.proha clean
```
# Test Explanation
- OSS
	- gw:
		- Add keyless api definition into /app folder 
		- Query the endpoint
	- pump:
		- CSV TEST:
		  - set up two diferent pumps filters for two orgs (st and stmongo)
				- csv pump = st org
				- mongo pump = stmongo org
			- Add an auth enabled API to the gw by using API
			- Upload the key for that secured API
			- Query the API using a custom agent as header
			- Look for CSV file on pump data folder, grep the CSV in order to search for header presence (OK)
		- MONGO TEST:
			- Repeat above steps but now export the analytics for the stmongo org which will go to mongo.
			- Dump mongo db and grep over the dump to search for custom header presence (OK)
- PRO
	- dashboard & gw:
		- Create a org in dashboard
		- Create a user
		- Reset user password
		- Create a keyless API
		- Query new API
- PROHA
	- dashboard & gw & mdcb & gwslave:
		- Create a org in dashboard with hybrid enabled
		- Create a user
		- Reset user password
		- Create a keyless API
		- Spin slave datacente (gw & redis)
		- Set RPC & APIKEY for GW slave
		- Query new API from gw master
		- Query new API from gw slave



