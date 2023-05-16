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

port-streamlit:
	kubectl port-forward svc/streamlit-app -n app 8501:8501

seldon-core:
	#	helm repo add seldonio https://storage.googleapis.com/seldon-charts
	#	helm repo update
	helm upgrade --install seldon-core seldonio/seldon-core-operator \
		--values ./charts/seldon-core/values.local.yaml \
		--create-namespace \
		--version 1.16.0 \
		--namespace seldon-system

seldon-core:

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

uninstall-seldon-core:
	helm uninstall seldon-core --namespace seldon-system

uninstall-emissary:
	helm uninstall emissary-ingress --namespace emissary

uninstall-prometheus:
	helm uninstall prometheus-seldon-monitoring --namespace seldon-monitoring

uninstall-podmonitor:
	kubectl delete -f seldon-podmonitor.yaml

uninstall-grafana:
	helm uninstall grafana-seldon-monitoring --namespace seldon-monitoring

helm-diff:
	helm plugin install https://github.com/databus23/helm-diff

helm-file:
	helmfile apply --concurrency 1

submit-images:
	sh build-modela.sh
	sh build-modelb.sh
	sh build-streamlit.sh
