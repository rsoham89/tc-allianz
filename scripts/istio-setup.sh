#--------------------------------------------------------------------------------------------
#| Script: istio-setup.sh                                                                 						   
#| Author: Soham Roy                                                       					           
#| Version: 1.0                                                                             						
#| Date: 14.06.2022                                                                        						   
#| Schedule run: On demand                                                                  					   
#| Dependent file: None                                                          						   
#| Purpose: This script creates kubernetes components for the application 	   
#| Example Run: bash init.sh
#| Dependencies: curl should be present, aws cli should be present, helm should be present ( v3.8), kubectl should be present                                                           					   
#--------------------------------------------------------------------------------------------

# Code description in README.md

# Update kubeconfig
aws eks update-kubeconfig --name app_cluster
# Install Istio and its core components
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.14.1/
kubectl create namespace istio-system
helm install istio-base manifests/charts/base -n istio-system
helm install istiod manifests/charts/istio-control/istio-discovery -n istio-system
helm install istio-ingress manifests/charts/gateways/istio-ingress -n istio-system

# Create namespace interview
cd ../../k8/crp2-tech-challenge/1-helm-debug/helm/namespace
helm upgrade --install --values values.yaml namespace-builder .

# Deploy the app
cd ../app/
helm upgrade --install --values values.yaml --values de/values.yaml app-de  .
helm upgrade --install --values values.yaml --values es/values.yaml app-es .
helm upgrade --install --values values.yaml --values fr/values.yaml app-fr .

# Deploy the service
cd ../service
helm upgrade --install --values values.yaml service-app .

# Deploy the network components
cd ../istio-network-elements
helm upgrade --install --values values.yaml ingress-app .

#Install Custom metric api extension
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
