all: minikube seldon seldon-analytics ambassador load abtest port

minikube:
	minikube start --memory 10000 --cpus 4 \
		--insecure-registry "10.0.0.0/24" \
		--driver=docker --kubernetes-version=v1.21.6 \
		--mount

ambassador:
	helm upgrade --install ambassador datawire/ambassador \
      --set image.repository=docker.io/datawire/ambassador \
      --values ./charts/ambassador/values.ambassador.local.yaml \
      --create-namespace \
      --namespace ambassador

admin:
	kubectl port-forward svc/ambassador-admin -n ambassador 8877:8877

port:
	kubectl port-forward svc/ambassador -n ambassador 8080:80

port-grafana:
	kubectl port-forward svc/seldon-core-analytics-grafana -n seldon-system 3000:80

seldon:
	helm upgrade --install seldon-core seldon-core-operator \
    	--repo https://storage.googleapis.com/seldon-charts \
		--set usageMetrics.enabled=false \
		--set ambassador.enabled=true \
		--create-namespace \
		--namespace seldon-system

load:
	minikube image load abtest:0.1

seldon-analytics:
	helm upgrade --install seldon-core-analytics seldon-core-analytics \
       --repo https://storage.googleapis.com/seldon-charts \
       --set grafana.adminPassword="admin" \
       --create-namespace \
       --namespace seldon-system

abtest:
	helm upgrade --install abtest ./charts/abtest --create-namespace --namespace seldon

uninstall:
	helm uninstall abtest --namespace seldon
