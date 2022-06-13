aws eks update-kubeconfig --name app_cluster
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system
helm install istiod istio/istiod -n istio-system --wait




cd ../k8/crp2-tech-challenge/1-helm-debug/helm/namespace
helm upgrade --install --values values.yaml namespace-builder .

cd ../app/


helm upgrade --install --values values.yaml --values de/values.yaml app-de  .
helm upgrade --install --values values.yaml --values es/values.yaml app-es .
helm upgrade --install --values values.yaml --values fr/values.yaml app-fr .

cd ../service
helm upgrade --install --values values.yaml service-app .


cd ../istio-network-elements
helm upgrade --install --values values.yaml ingress-app .
