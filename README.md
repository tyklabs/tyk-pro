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
