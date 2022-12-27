# Cloudformation templates for AWS Marketplace
This readme is going to show you how to deploy Tyk in AWS starting by deploying the suggested infraestructure stack.
If you are interested in knowing more about the architecture and a deeper explanation of the stacks please go through this link first in order to get an idea of what are you going to deploy:
* https://tyktech.atlassian.net/wiki/spaces/EN/pages/1433960499/AWS+Marketplace

# Contents
This folder contains all cloudformation templates required to deploy Tyk in AWS.
The folder **nested-stacks** contains all the cloudformation stacks that will be later called from the root templates (yaml) located in the root of the **cloudformation** folder.

The current suported paid models for deployment are:
>* byol (bring your own license)
>* payg (pay as you go)

The current suported architecture models for deployment are:
>* single gateway
>* unlimited gateway

Building a matrix between architecture and paid models will result on 4 diferent cloudformation templates:
>* tyk-single-byol.yaml
>* tyk-unlimited-byol.yaml
>* tyk-single-payg.yaml
>* tyk-unlimited-payg.yaml

## Templates
All yaml files are what we call the root cloudformation templates. This templates will deploy each one of the posible combinations. Their are called root templates because they will call the multiple stacks stored in the **nested-stacks** folder, think on them as building blocks. You will notice that they are reused across the root templates.

## JQ files
Along with the root cloudformation templates you will notice there is a **.jq** file that corresponds to each template:
```	
tyk-single-byol.yaml
tyk-single-byol.jq
```
These **.jq** are special template files that contain the values required to deploy their corresponding CFT, plus some parameters that will get replaced automatically when using the `makefile parse` command

## JSON file
Currently you won't see any JSON file in the repo except for `infra-stack-output.json` just ignore this file is a hack for Makefile avoid complaining. JSON files are the final rendered version of the **.jq** after all the parameters are substituted for real values (no parameters). This files will be used as inputs for the cloudformation deployment and they will be created after the `makefile parse` command is executed.
There's an extra JSON file `clean-vars.json` that will be generated also by `makefile parse` which is a placeholder for new or existent infra variables related to infrastructure layer, is basically a clean up of the `infra-stack-output.json` with just the variables we want.


# How to deploy
A makefile has been created in order to ease the process of deployment. The following instructions are based on the execution of the makefile targets.

## Prerequisites
* Login with AWS console
* Change region to sa-east-1 (*)
* Onboard an ssh_key into
* Go into the makefile and change the SSH_KEY variable to match your aws ssh key

```
Makefile
SSH_KEY ?= esteban
s3_bucket ?= nested-stacks-poc
stack_name ?= tyk-aws
...
```

>*Ami's were only generated for **sa-east-1** region for now, you can learn how to generate your own AMIs by going into each repo (tyk,tyk-analytics-tyk-pump) and following the instructions under the AWS folder.

---

## Build infra
This command will create the base infrastructure for you in aws, as output it will generate `infra-stack-output.json` which is the variable outputs for the AWS stack (vpc id, subnets, etc). Also there will be an implicit parse that will generate the `clean-vars.json`.
Is important to clarify that the infrastructure is the same for any template of the matrix.
```
➜ ✗ make infra                                                   
Deploying infra stack: tyk-aws-infra-esteban ...
aws cloudformation deploy --template-file nested-stacks/infra/infra.yaml --stack-name tyk-aws-infra-esteban

Waiting for changeset to be created..
Waiting for stack create/update to complete
Successfully created/updated stack - tyk-aws-infra-esteban
aws cloudformation describe-stacks --stack-name tyk-aws-infra-esteban > infra-stack-output.json
Parsing infra output file: infra-stack-output.json ....
Generating clean json variable file: clean-vars.json ....
clean-vars.json generated ... OK
```

---

## Retry parse infra output in case of failure (Optional)
Just in case the **clean-vars.json** was not generated correctly you can retry the parse by doing
```
➜ ✗ make parse
Parsing infra output file: infra-stack-output.json ....
Generating clean json variable file: clean-vars.json ....
clean-vars.json generated ... OK
```

---

## Generate json values file before deploy application
This step will simply replace the parameters on the desired **.jq** template using `clean-vars.json` values taken from the infra. This is the previous step where we prepare our values files for the final deployment of the application.
Here is important to know that at this point you need to decide which template you want to deploy since variables will differ. 

So you need to choose among any of the desired combinations:
* tyk-single-byol.jq
* tyk-unlimited-byol.jq
* tyk-single-payg.jq
* tyk-unlimited-payg.jq

>Syntax:
>
>      make <jq_template> 

```
➜ ✗ make tyk-single-payg.jq
Parsing infra output file: infra-stack-output.json ....
Generating clean json variable file: clean-vars.json ....
clean-vars.json generated ... OK
Generate json values file for tyk-single-payg.jq
tyk-single-payg.json generated ... OK
```

As result you can see this generated a json file called `tyk-single-payg.json` that contains all required variables.

> NOTE: If building a **byol** make sure you use a valid License replacing the dumy one on the template.

> NOTE: While building an **unlimited** make sure you change the AZ for the desired region on the **TYKGatewaySubnetAZs** variable.

---

## Deploy application
Last step to deploy the application, you just need to refer to a valid .yaml cloudformation template. If the previous step you generated a `tyk-single-payg.json` now you want to deploy `tyk-single-payg.yaml`

>Syntax:
>
>      make <yaml_template> 

```
➜ ✗ make tyk-single-payg.yaml
Packing tyk-single-payg.yaml ...
aws cloudformation package --template-file tyk-single-payg.yaml --output-template tyk-single-payg-packaged.yaml  --s3-bucket nested-stacks-poc

Successfully packaged artifacts and wrote output template to file tyk-single-payg-packaged.yaml.
Execute the following command to deploy the packaged template
aws cloudformation deploy --template-file /Users/kiki/Github/tyk-aws/cloudformation/tyk-single-payg-packaged.yaml --stack-name <YOUR STACK NAME>
Deploying tyk-stack: tyk-aws-12162021 ...
aws cloudformation deploy --template-file tyk-single-payg-packaged.yaml --parameter-overrides file://tyk-single-payg.json --capabilities CAPABILITY_IAM --stack-name tyk-aws-12162021

Waiting for changeset to be created..
Waiting for stack create/update to complete
Successfully created/updated stack - tyk-aws-12162021
```












