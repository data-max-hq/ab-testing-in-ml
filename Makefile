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

port-admin:
	kubectl port-forward svc/ambassador-admin -n ambassador 8877:8877

port-streamlit:
	kubectl port-forward svc/streamlit-app -n app 8501:8501

seldon-core:
	helm upgrade --install seldon-core seldon-core-operator \
      --repo https://storage.googleapis.com/seldon-charts \
	  --values ./charts/seldon-core/values.local.yaml \
	  --create-namespace \
	  --namespace seldon-system

seldon-core-analytics:
	helm upgrade --install seldon-core-analytics seldon-core-analytics \
       --repo https://storage.googleapis.com/seldon-charts \
       --values ./charts/seldon-core-analytics/values.local.yaml \
       --create-namespace \
       --namespace seldon-system

port-grafana:
	kubectl port-forward svc/seldon-core-analytics-grafana -n seldon-system 3000:80

build:  # gcloud builds
	docker build -t ab-test:a -f Dockerfile.a .
	docker build -t ab-test:b -f Dockerfile.b .
	docker build -t streamlit-app:v1.1 -f Dockerfile.streamlit .

load:
	minikube image load ab-test:a
	minikube image load ab-test:b

streamlit-load:
	minikube image load streamlit-app:v1.1

abtest:
	helm upgrade --install abtest ./charts/abtest \
		--create-namespace --namespace seldon

curl:
	curl -X POST -H 'Content-Type: application/json' \
		-d '{"data": { "ndarray": ["This is a nice comment."]}}' \
		http://localhost:8080/seldon/seldon/abtest/api/v1.0/predictions

run:
	python seldon_client/client.py

streamlit:
	streamlit run streamlit-app/App.py

uninstall:
	helm uninstall abtest --namespace seldon

delete:
	minikube delete

helm-diff:
	helm plugin install https://github.com/databus23/helm-diff

helm-file:
	helmfile apply --concurrency 1