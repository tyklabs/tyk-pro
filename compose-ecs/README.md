# Overview

This folder contains an external and internal environment docker compose files which can be bring up separatelly, both uses external nextworks which need to be created beforehand. Services will be configured using the files located in `../confs/${CONFIG}` in this case `.env` file holds the ENV vars that will set the flavour (PRO in this current example).
As it is, the docker compose files won't be able to be deployed to ecs without taking care of cloud formation override, its usage is only intended for local deployment excersice of the networking and persistense layers.

To run it, make sure you have set your AWS credentials and then run

`make all`

Take a look at Makefile for more commands.