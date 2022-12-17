all: minikube seldon-core seldon-core-analytics ambassador build load abtest port
install-all: ambassador seldon-core seldon-core-analytics streamlit
uninstall-all: uninstall-streamlit uninstall-abtest uninstall-seldon-core-analytics uninstall-seldon-core uninstall-ambassador

minikube:
	minikube start --driver=docker --kubernetes-version=v1.21.6

train:
	python train_models.py

emissary:
	kubectl apply -f https://app.getambassador.io/yaml/emissary/3.3.1/emissary-crds.yaml
	kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system
	helm install -n emissary --create-namespace \
         emissary-ingress datawire/emissary-ingress \
         --values ./charts/emissary/values.emissary.local.yaml && \
	kubectl rollout status  -n emissary deployment/emissary-ingress -w

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
		--version 1.15.0 \
		--namespace seldon-system

seldon-core-analytics:
	# helm repo add seldonio https://storage.googleapis.com/seldon-charts
	helm upgrade --install seldon-core-analytics seldonio/seldon-core-analytics \
       --values ./charts/seldon-core-analytics/values.local.yaml \
       --create-namespace \
       --version 1.15.0 \
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
	minikube image load streamlit-app:v1.1

streamlit-load:
	minikube image load streamlit-app:v1.1

sleep:
	sleep 10

abtest:
	helm upgrade --install abtest ./charts/abtest \
		--create-namespace --namespace seldon

streamlit:
	helm upgrade --install streamlit-app ./charts/streamlit-app \
		--create-namespace --namespace app

curl:
	curl -X POST -H 'Content-Type: application/json' \
		-d '{"data": { "ndarray": ["This is a nice comment."]}}' \
		http://localhost:8080/seldon/seldon/abtest/api/v1.0/predictions

run:
	python seldon_client/client.py

uninstall-streamlit:
	helm uninstall streamlit-app --namespace app

uninstall-abtest:
	helm uninstall abtest --namespace seldon

uninstall-seldon-core-analytics:
	helm uninstall seldon-core-analytics --namespace seldon-system

uninstall-seldon-core:
	helm uninstall seldon-core --namespace seldon-system

uninstall-ambassador:
	helm uninstall ambassador --namespace ambassador

delete:
	minikube delete

helm-diff:
	helm plugin install https://github.com/databus23/helm-diff

helm-file:
	helmfile apply --concurrency 1

submit-images:
	gcloud builds submit --config cloudbuild-modela.yaml
	gcloud builds submit --config cloudbuild-modelb.yaml
	gcloud builds submit --config cloudbuild-streamlit.yaml

streamlit-image:
	gcloud builds submit --config cloudbuild-streamlit.yaml
