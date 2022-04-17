all: minikube

hello:
	echo "hello world"

minikube:
		minikube start --memory 10000 --cpus 4 \
		--insecure-registry "10.0.0.0/24" \
		--driver=docker --kubernetes-version=v1.21.6 \
		--mountls

ambassador:
	helm upgrade --install ambassador datawire/ambassador \
      --set image.repository=docker.io/datawire/ambassador \
      --values values.ambassador.local.yaml \
      --create-namespace \
      --namespace ambassador

admin:
	kubectl port-forward svc/ambassador-admin -n ambassador 8877:8877

seldon:
	helm upgrade --install seldon-core seldon-core-operator \
    	--repo https://storage.googleapis.com/seldon-charts \
		--set usageMetrics.enabled=false \
		--set ambassador.enabled=true \
		--create-namespace \
		--namespace seldon-system

seldon-analytics:
	helm upgrade --install seldon-core-analytics seldon-core-analytics \
       --repo https://storage.googleapis.com/seldon-charts \
       --create-namespace \
       --namespace seldon-system

abtest:
	helm upgrade --install abtest ./abtest --create-namespace --namespace seldon