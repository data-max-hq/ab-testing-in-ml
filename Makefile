all: minikube seldon-core seldon-core-analytics ambassador build load abtest port

minikube:
	minikube start --driver=docker --kubernetes-version=v1.21.6

train:
	python train_models.py

ambassador:
	helm repo add datawire https://www.getambassador.io
	helm upgrade --install ambassador datawire/ambassador \
      --set image.repository=docker.io/datawire/ambassador \
      --values ./charts/ambassador/values.ambassador.local.yaml \
      --create-namespace \
      --namespace ambassador

port:
	kubectl port-forward svc/ambassador -n ambassador 8080:80

seldon-core:
	helm upgrade --install seldon-core seldon-core-operator \
      --repo https://storage.googleapis.com/seldon-charts \
	  --set usageMetrics.enabled=false \
	  --set ambassador.enabled=true \
	  --create-namespace \
	  --namespace seldon-system

seldon-core-analytics:
	helm upgrade --install seldon-core-analytics seldon-core-analytics \
       --repo https://storage.googleapis.com/seldon-charts \
       --set grafana.adminPassword="admin" \
       --create-namespace \
       --namespace seldon-system

port-grafana:
	kubectl port-forward svc/seldon-core-analytics-grafana -n seldon-system 3000:80

build:
	docker build -t ab-test:a -f Dockerfile.a .
	docker build -t ab-test:b -f Dockerfile.b .

load:
	minikube image load ab-test:a
	minikube image load ab-test:b

abtest:
	helm upgrade --install abtest ./charts/abtest \
		--create-namespace --namespace seldon

curl:
	curl -X POST -H 'Content-Type: application/json' \
		-d '{"data": { "ndarray": ["This is a nice comment."]}}' \
		http://localhost:8080/seldon/seldon/abtest/api/v1.0/predictions

run:
	python seldon_client/client.py

run-streamlit:
	streamlit run streamlit-app/App.py

uninstall:
	helm uninstall abtest --namespace seldon

delete:
	minikube delete
