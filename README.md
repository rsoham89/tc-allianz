# Application Solution - Devops Assessment - Soham Roy 

### Requirement Gathering and Analysis

This document guide is for the MVP solution of the microservice hello-world. The cloud chosen is AWS. As of now the architecture needed is for only one environment with code to be built in a way that this can be used to create the infrastructure for production as well. The apps are deployed on EKS cluster.

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

![diagram](images/(allianz_application_architecture.png)

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

![diagram](images/(namespaces.png)

## Deployment Guide

You need to ensure that the above mentioned tools are installed successfully. The best way is to check for the versions of the tool.

```bash

# for terraform version
terraform version
# for kubectl version
kubectl version short
# for aws-cli version
aws --version
# for helm version
helm version

```

Next step is to ensure that you have configured your aws profile so that can run terraform

```bash

# aws configure
  <provide your access id>
  <provide your secret id>
  <provide your region ( eu-central-1)>
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

The *init.sh* script first creates the backend s3 bucket and then creates the infrastructure for the kubernetes deployment. The code for the infrastructure has been modularized and can be used for various environments. As of now only the stage = dev is deployed.

This will take 10-12 minutes of time. Once the terraform completes creating the infrastructure we can run *terraform state list* to list all the aws objects just created via terraform.

```
cd ../terraform/infrastructure/
terraform state list

module.infra.aws_eip.nat1
module.infra.aws_eip.nat2
module.infra.aws_eks_cluster.eks
module.infra.aws_eks_node_group.nodes
module.infra.aws_iam_role.eks_cluster
module.infra.aws_iam_role.node_groups
module.infra.aws_iam_role_policy_attachment.eks_cluster_policy
module.infra.aws_iam_role_policy_attachment.eks_cni_policy
module.infra.aws_iam_role_policy_attachment.eks_ecr_policy
module.infra.aws_iam_role_policy_attachment.eks_node_policy
module.infra.aws_internet_gateway.main
module.infra.aws_nat_gateway.nat_gw1
module.infra.aws_nat_gateway.nat_gw2
module.infra.aws_network_acl.main_nacl
module.infra.aws_route_table.private1
module.infra.aws_route_table.private2
module.infra.aws_route_table.public
module.infra.aws_route_table_association.private1
module.infra.aws_route_table_association.private2
module.infra.aws_route_table_association.public1
module.infra.aws_route_table_association.public2
module.infra.aws_subnet.private_1
module.infra.aws_subnet.private_2
module.infra.aws_subnet.public_1
module.infra.aws_subnet.public_2
module.infra.aws_vpc.main
```

As of now the plan is to expose the application via Internet facing ALB hence I have not used any bastion server. However I have added the bastion server code as well if the requirement comes for internal-ALB. 

Once the infrastructure is ready run the istio-setup.sh command to create all the kubernetes components

```bash
cd -
bash istio-setup.sh
```

## Lets discuss in details what components are created

```bash
$ cat istio-setup.sh

aws eks update-kubeconfig --name app_cluster

curl -L https://istio.io/downloadIstio | sh -
cd istio-1.14.1/
kubectl create namespace istio-system
helm install istio-base manifests/charts/base -n istio-system
helm install istiod manifests/charts/istio-control/istio-discovery -n istio-system
helm install istio-ingress manifests/charts/gateways/istio-ingress -n istio-system

cd ../../k8/crp2-tech-challenge/1-helm-debug/helm/namespace
helm upgrade --install --values values.yaml namespace-builder .

cd ../app/


helm upgrade --install --values values.yaml --values de/values.yaml app-de  .
helm upgrade --install --values values.yaml --values es/values.yaml app-es .
helm upgrade --install --values values.yaml --values fr/values.yaml app-fr .

cd ../service
helm upgrade --install --values values.yaml service-app .


cd ../istio-network-elements
helm upgrade --install --values values.yaml ingress-app .
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

The ```aws eks update-kubeconfig --name app_cluster``` configures the kubernetes config file with the eks cluster which is recently created.
Once the cluster is configured the next step is to create the istio components. We are using Helm to create the istio components. There are two major components to be installed 

- istio-base
- istiod
- istio-ingress
The below section takes care of that - 

```
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.14.1/
kubectl create namespace istio-system
helm install istio-base manifests/charts/base -n istio-system
helm install istiod manifests/charts/istio-control/istio-discovery -n istio-system
helm install istio-ingress manifests/charts/gateways/istio-ingress -n istio-system
```

If we plan to create an **internal ALB** then we need to add the annotation **"service.beta.kubernetes.io/aws-load-balancer-internal": "true**" in *scripts/istio-1.14.1/manifests/charts/gateways/istio-ingress/templates/service.yaml* .

Now the helm components are added we need to deploy the application. We have seggregated the entire setup into four components -

1. Namespace-Builder : To create the ```interview``` namespace.
```
cd ../kubernetes/crp2-tech-challenge/1-helm-debug/helm/namespace
helm upgrade --install --values values.yaml namespace-builder .
```

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
This contains three major parts

  - The virtual service: To configure the routing policy. We are using one service, so one virtual service is enough.
  - Destination rule: To define the subsets (define the pod labels).
  - Gateway: To connect the ingress to the virtual service.

Last but not the least the custom metric api extension is installed for monitoring the metrices

```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

The reason why I seggregated this is because considering the scope of CI/CD is not here, the sequence of events should adhere to the CI/CD tasks. PFB the diagram for the same:
 
![diagram](images/(cicd.png)

## Application LLD Description

The namespace ```interview``` was created with the label ```istio-injection: enabled```. This helps istio to create an envoy-proxy sidecar on every pod for a deployment in that namespace.

Three different deployments were created with three configmaps, one each for the components de, es and fr.
All the pods were labeled with 

```svc-name: hello-world ``` which the selector of the service ```hello-world``` uses to route the traffic in a **round-robin** manner.

At this point of time if you hit the service then you can see the traffic getting routed to all three pods in a round robin fashion.

The next ask was path based routing. So the **virtual service** was introduced with http redirect based on uri.

```
http:
    - match:
        - uri:
            prefix: "/eu"
      rewrite:
        uri: "/"
      route:
        - destination:
            host: hello-world.interview.svc.cluster.local
            port:
              number: 80
    - match:
        - uri:
            prefix: "/de"
      rewrite:
        uri: "/"
      route:
        - destination:
            host: hello-world.interview.svc.cluster.local
            port:
              number: 80
            subset: de
    - match:
        - uri:
            prefix: "/fr"
      rewrite:
        uri: "/"
      route:
        - destination:
            host: hello-world.interview.svc.cluster.local
            port:
              number: 80
            subset: fr
    - match:
        - uri:
            prefix: "/es"
      rewrite:
        uri: "/"
      route:
        - destination:
            host: hello-world.interview.svc.cluster.local
            port:
              number: 80
            subset: es
```

And the subsets were defined as a part of the **destination rule**.
The pods were labels with ```version: de/es/fr``` and the destination subsets were created based on the same.

```
  subsets:
    - name: de
      labels:
        version: de
    - name: fr
      labels:
        version: fr
    - name: es
      labels:
        version: es
```

This ensured if the service is requested anywhere from the service mesh then it will distribute based on the uri.

The next step was to create the ingress and the gateway. We had to configure the virtual service to add the gateway 
```gateways: - hello-world-gateway``` and in the gateway the ingress controller was added as well as the virtual service.
The ingress controller is public facing one. If we plan to create an **internal ALB** then we need to add the annotation **"service.beta.kubernetes.io/aws-load-balancer-internal": "true**" in *scripts/istio-1.14.1/manifests/charts/gateways/istio-ingress/templates/service.yaml*.

**Hiccup**

1. In order to create an internal ALB even after annotation and the tag in the aws subnet, the tag ```kubernetes.io/cluster/app_cluster``` needed to be changed from **shared** to **owned**. Else the Load Balancder service was generating with External IP in the *pending* state.

2. The target of the service was changed from 80 to 8000 as the pods were running in port 8000 (As a part of technical challenge)

**de**

![diagram](images/(de.png)

**es**

![diagram](images/(es.png)

**fr**

![diagram](images/(fr.png)

**eu**

![diagram](images/(eu.png)

## Monitoring

I've kept the monitoring part pretty rudimentary. The ask was to get the performance parameters / status from the EKS cluster components without using kubectl. I've used module  **python-kubernetes** for the same.

As of now there are two checks that are happening 
- Listing node and its status
- Listing pod in the ```interview```  namespace and its utilization.

and printing the corresponding values.

All the functions of the CoreV1Api is listed here https://raw.githubusercontent.com/kubernetes-client/python/master/kubernetes/docs/CoreV1Api.md.

As of now I have used only two **list_node()** and **CustomObjectsApi()**. In the future this can be written in a Flask app and can be made API based to retrieve the data.








