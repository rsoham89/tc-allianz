# Application Solution - Devops Assessment - Soham Roy 

### Requirement Gathering and Analysis

This document guide is for the MVP solution of three micro-services ( all private ). The cloud chosen is AWS. As of now the architecture needed is for only one environment with code to be built in a way that this can be used to create the infrastructure for production as well. The apps are deployed on EKS cluster.

For code reusability [**Terraform**](https://www.terraform.io) has been chosen as IaC.


### Tech Stack and Installation Guide

For the MVP the below tools are selected

**AWS CLI** | v1.2 | [Click here to install](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html)

**Terraform** | >v0.13 | [Click here to install](https://learn.hashicorp.com/tutorials/terraform/install-cli)

**Kubectl** | v1.22 | [Click here to install](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/)

**Helm** | v3.8 | [Click here to install](https://helm.sh/docs/intro/install/)

**Hiccup**

Please note not to use Helm version 3.9 as that has some potential bugs with the api version (https://github.com/helm/helm/issues/10975).


## Application Architecture 

Please refer to the  architecture diagram

![diagram](allianz_application_architecture.png)

### Detailed analysis:

**1. Network ( VPC, Subnets, Internet Gateway, NAT Gateway, NACL and Route Table ) :** The entire platform is hosted in 1 VPC ( region: eu-central-1 ). For *high-availability*, 1 public and 1 private subnet has been made per availability zone (eu-central-1a, eu-central-1b).

All the objects in the private subnet are routed via the *NAT gateway* (1 per public subnet) and for generic internet routing the Internet gateway is used. 2 *Elastic IPs* have been created for the 2 NAT gateways.

The public subnets have auto-assign of public ip enables for its object.

To **ssh** to the private servers you need to traverse via the **bastion server** (or jump server)

**2. Compute Objects (EKS ) :** EKS is deployed on private cluster with endpoint_public_access= true. This will allow the kubectl client to be run from locally. As this is a tech challenge there is one 1 node which has been used. The instance type used is t2.large as the lower models were going **out of memory**.

There are two main namespaces that has been used for this POC.

1. istio-system : To deploy the istio based k8 objects.
2. interview: Which contains the app, service and the network components.

The **istio-system** namespace contains the component of the istio service mesh ( istio-base and istiod). The **interview** namespace contains the deployment of hello-word.

All the apps are exposed on port **8000** and the service is exposed on port **80**.

![diagram](namespaces.png)

## Deployment Guide

You need to ensure that the above mentioned tools are installed successfully. The best way is to check for the versions of the tool.

```bash

# for terraform version
terraform version
# for kubectl version
kubectl version short
# for aws-cli version
aws --version

```

Next step is to ensure that you have configured your aws profile so that can run terraform and packer

```bash

# aws configure
  <provide your access id>
  <provide your secret id>
  <provide your regionl ( eu-central-1)>
  <provide default type as json>
```

Download the code from github: 
```bash
git clone https://github.com/rsoham89/tc-allianz.git
```

```bash

cd tc-allianz/scripts

# To create the backend, aws network and eks cluster run the init.sh

bash init.sh

```
This will take 10-12 minutes of time. Once the terraform completes creating the infrastructure you can run 

```
cd ../terraform/infrastructure/
terraform state list
```
To list all the aws objects you just created via terraform.

Once this is ready run the istio-setup.sh command to create all the kubernetes components

```bash
cd -
bash istio-setup.sh

```

**Lets discuss in details what components are created**

```bash
$ cat istio-setup.sh

aws eks update-kubeconfig --name app_cluster
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system
helm install istiod istio/istiod -n istio-system --wait




cd ../kubernetes/crp2-tech-challenge/1-helm-debug/helm/namespace
helm upgrade --install --values values.yaml namespace-builder .

cd ../app/


helm upgrade --install --values values.yaml --values de/values.yaml app-de  .
helm upgrade --install --values values.yaml --values es/values.yaml app-es .
helm upgrade --install --values values.yaml --values fr/values.yaml app-fr .

cd ../service
helm upgrade --install --values values.yaml service-app .


cd ../ingress
helm upgrade --install --values values.yaml ingress-app .
```

The ```aws eks update-kubeconfig --name app_cluster``` configures the kubernetes config file with the eks cluster which is recently created.
Once the cluster is configured the next step is to create the istio components. We are using Helm to create the istio components. There are two major components to be installed 

- istio-base
- istiod

The below section takes care of that - 

```
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system
helm install istiod istio/istiod -n istio-system --wait
```

Now the helm components are added we need to deploy the application. We have seggregated the entire setup into four components -

1. Namespace-Builder : To create the ```interview``` namespace.
   ```cd ../kubernetes/crp2-tech-challenge/1-helm-debug/helm/namespace
helm upgrade --install --values values.yaml namespace-builder .```

2. App-Builder : To deploy the de/fr/es as separate deployments 

```
cd ../app/

helm upgrade --install --values values.yaml --values de/values.yaml app-de  .
helm upgrade --install --values values.yaml --values es/values.yaml app-es .
helm upgrade --install --values values.yaml --values fr/values.yaml app-fr .
```

3. service-app: To deploy the service that will send the requests to the corresponding pods.

```
cd ../service
helm upgrade --install --values values.yaml service-app .
```
4. Ingress-app: To deploy all the network components for the rerouting. 
```
cd ../ingress
helm upgrade --install --values values.yaml ingress-app .
```
This contains four major parts

  - The virtual service: To configure the routing policy. We are using one service, so one virtual service is enough.
  - Destination rule: To define the subsets (define the pod labels).
  - Istio Ingress - To accept traffic from outside the cluster.
  - Gateway: To connect the ingress to the virtual service.

