# start minikube
minikube start --memory 10000 --cpus 4 \
--insecure-registry "10.0.0.0/24" \
--driver=docker --kubernetes-version=v1.21.6 \
--mount

# Install ambassador inside ambassador namesace
helm repo add datawire https://www.getambassador.io
helm upgrade --install ambassador datawire/ambassador \
  --set image.repository=docker.io/datawire/ambassador \
  --values values.ambassador.local.yaml \
  --create-namespace \
  --namespace ambassador

helm upgrade --install seldon-core seldon-core-operator \
    --repo https://storage.googleapis.com/seldon-charts \
    --set usageMetrics.enabled=true \
    --set ambassador.enabled=true \
    --create-namespace \
    --namespace seldon-system

helm upgrade --install seldon-core-analytics seldon-core-analytics \
   --repo https://storage.googleapis.com/seldon-charts \
   --create-namespace \
   --namespace seldon-system

kubectl port-forward svc/ambassador-admin -n ambassador 8877:8877

http://localhost:8877/ambassador/v0/diag/

helm upgrade --install abtest ./abtest --create-namespace --namespace seldon
