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
    --set usageMetrics.enabled=false \
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


kubectl port-forward svc/ambassador -n ambassador 8080:80

curl -X http://localhost:8080/seldon/myabtest/api/v1.0/predictions

# not using single namespace
curl -v http://localhost:8080/seldon/seldon/abtest/api/v1.0/predictions -d '{"data":{"names":["a","b"],"tensor":{"shape":[2,2],"values":[0,0,1,1]}}}' -H "Content-Type: application/json"


docker build -t abtest:0.1 .
docker run --name "reddit_predictor" -d --rm -p 9001:9000 abtest:0.2

minikube image load abtest:0.2

curl -v -X POST -H 'Content-Type: application/json' \
   -d '{"data": { "ndarray": ["this is a terrible comment"], "names": ["tfidf"] } }' \
     http://localhost:8080/seldon/seldon/abtest/api/v1.0/predictions

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

kubectl create namespace istio-system
helm upgrade --install istio-base istio/base -n istio-system
helm upgrade --install istiod istio/istiod -n istio-system --wait

