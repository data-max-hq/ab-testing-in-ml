install-all: emissary seldon-core prometheus grafana streamlit
uninstall-all: uninstall-streamlit uninstall-abtest uninstall-grafana uninstall-prometheus uninstall-seldon-core uninstall-emissary

train:
	#python -m spacy download en_core_web_sm
	python train_models.py

helm-emissary:
	helm repo add datawire https://app.getambassador.io
	helm repo update

emissary:
	kubectl apply -f https://app.getambassador.io/yaml/emissary/3.6.0/emissary-crds.yaml
	kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system
	helm upgrade --install --namespace emissary --create-namespace \
         emissary-ingress datawire/emissary-ingress \
         --values ./charts/emissary/values.emissary.local.yaml && \
	kubectl rollout status  -n emissary deployment/emissary-ingress -w

#ambassador:
#	helm repo add  datawire https://www.getambassador.io
#	helm upgrade --install ambassador datawire/ambassador \
#      --set image.repository=docker.io/datawire/ambassador \
#      --values ./charts/ambassador/values.ambassador.local.yaml \
#      --create-namespace \
#      --namespace ambassador
#
#port:
#	kubectl port-forward svc/ambassador -n ambassador 8080:80
#
#port-admin:
#	kubectl port-forward svc/ambassador-admin -n ambassador 8877:8877

port-streamlit:
	kubectl port-forward svc/streamlit-app -n app 8501:8501

seldon-core:
	helm upgrade --install seldon-core seldon-core-operator \
		--repo https://storage.googleapis.com/seldon-charts \
		--values ./charts/seldon-core/values.local.yaml \
		--create-namespace \
		--version 1.15.0 \
		--namespace seldon-system

# Deprecated
#seldon-core-analytics:
#	# helm repo add seldonio https://storage.googleapis.com/seldon-charts
#	helm upgrade --install seldon-core-analytics seldonio/seldon-core-analytics \
#       --values ./charts/seldon-core-analytics/values.local.yaml \
#       --create-namespace \
#       --version 1.15.0 \
#       --namespace seldon-system

prometheus:
	# helm repo add bitnami https://charts.bitnami.com/bitnami
	helm upgrade --install prometheus-seldon-monitoring bitnami/kube-prometheus \
		--version 8.9.1 \
		--values ./charts/prometheus/values.prometheus.local.yaml \
		--namespace seldon-monitoring \
		--create-namespace

grafana:
	# helm repo add grafana https://grafana.github.io/helm-charts
	helm upgrade --install grafana-seldon-monitoring grafana/grafana \
		--version 6.56.1 \
		--values ./charts/grafana/values.grafana.local.yaml \
		--values ./charts/grafana/values.grafana.secret.yaml \
		--namespace seldon-monitoring \
		--create-namespace

podmonitor:
	kubectl apply -f seldon-podmonitor.yaml

port-grafana:
	kubectl port-forward svc/grafana-seldon-monitoring -n seldon-monitoring 3000:80

#build:  # gcloud builds
#	docker build -t ab-test:a -f Dockerfile.a .
#	docker build -t ab-test:b -f Dockerfile.b .
#	docker build -t streamlit-app:v1.1 -f Dockerfile.streamlit .

#load:
#	minikube image load ab-test:a
#	minikube image load ab-test:b
#	minikube image load streamlit-app:v1.1

#streamlit-load:
#	minikube image load streamlit-app:v1.1

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
#
#uninstall-seldon-core-analytics:
#	helm uninstall seldon-core-analytics --namespace seldon-system

uninstall-seldon-core:
	helm uninstall seldon-core --namespace seldon-system

#uninstall-ambassador:
#	helm uninstall ambassador --namespace ambassador

uninstall-emissary:
	helm uninstall emissary-ingress --namespace emissary

uninstall-prometheus:
	helm uninstall prometheus-seldon-monitoring --namespace seldon-monitoring

uninstall-grafana:
	helm uninstall grafana-seldon-monitoring --namespace seldon-monitoring

delete:
	minikube delete

helm-diff:
	helm plugin install https://github.com/databus23/helm-diff

helm-file:
	helmfile apply --concurrency 1

submit-images:
	sh build-modela.sh
	sh build-modelb.sh
	sh build-streamlit.sh
