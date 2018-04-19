# The Ursa Project

## Introduction
The DSP team run Oracle RAT workload in Q-Labs to provide qualification service. The Oracle RAT replay process has three stages:
* Capture the Workload in the production system
* Set the RAT workload in a Q-Lab
* Run the RAT workload in the Q-Lab

Currently, most of the operations during the RAT workload setting stage are done manually. Those manual steps are time consuming and there is high risk that we cannot meet GDPR requirements as number of Q-Labs increases.

## Project Scope , Goal and Code Name

The Ursa Project scope is to automate manual operations during the RAT workload setting stage on the Oracle RAT replay process to reduce human hours and human errors. 


# Installation

This starter program is written in Go. After a success build, an executable binary (named ursa) is generated in the root of this repository.

## Build in a local Go development environment 
If you have a golang development environment on the build host, run this cmd to build a binary for Linux platform:

```
make go-build
```

To build a binary for OSX, run:

```
make build-darwin
```

## Build in a containerized Go development environment 

This build process needs to docker pull a docker image which contains golang dev environment from registry dva-registry.internal.salesforce.com. For docker pull to work, you need to log into the register as follows using your corporate username and password if you have not yet done so:

```
docker login dva-registry.internal.salesforce.com
```

Then, run cmd
```
make docker-build
```

# Usage

## Run the app 

From the root directory of this repository, run cmd

```
./ursa 
```

This will lauch a server listening on a TCP port 9090. 

Run this cmd to send a request to the server
```
curl localhost:9090
```

## Run the app in a docker container

This includes creating a docker image containing this app then starting up the app within a docker container. The new created docker image use ops0-artifactrepo1-0-prd.data.sfdc.net/docker-dev-base/tnrp/appbase:7 as its base image. 

To get the docker base image, you need to log into the register as follows using your corporate username and password if you have not yet done so:

```
docker login ops0-artifactrepo1-0-prd.data.sfdc.net
```

Then, run this cmd to build and run the app within a docker container:

```
make docker-run
```
If all is successful, you will get output as follows:
```
...
docker run -it -u 7447:7447 --name ursa -p 9090:9090 --rm -e "PORT=9090" ursa:0.0.1 /bin/ursa
Listening on http://127.0.0.1:9090/
```

Run this cmd to send a request to the server to test
```
curl localhost:9090
```