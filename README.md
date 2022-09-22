# A/B Testing for ML applications
Deploy A/B testing infrastructure in a containerized microservice 
architecture for Machine Learning applications.

## Requirements

This repository uses Kubernetes, helm, ambassador, seldon-core, and seldon-core-analytics.

## Getting started

### Install prerequisites

1. Install helm
```
brew install helm
```

2. Create a Kubernetes cluster: AKS, EKS, GKE or local cluster. For local clusters, one can use `minikube`, `kind`, or `k3s`. For instance:
   1. Minikube
    ```bash
    make minikube
    ```
   2. GKE
   ```shell
    gcloud container clusters create demo-cluster-ab-test \
      --zone=europe-west3-a \
      --cluster-version=1.21.14-gke.5300 --no-enable-autoupgrade \
      --machine-type=e2-highcpu-4
   ```

### Train model
Prepare the model artifacts:
```
make train
```

### Build container images
One can build the images locally, or use Cloud Submit:
#### Locally
```
docker build -t ab-test:a -f Dockerfile.a .
docker build -t ab-test:b -f Dockerfile.b .
docker build -t streamlit-app:v1.1 -f Dockerfile.streamlit .
```

#### Cloud Submit
```shell
gcloud builds submit --config cloudbuild-modela.yaml
gcloud builds submit --config cloudbuild-modelb.yaml
gcloud builds submit --config cloudbuild-streamlit.yaml
```

### (minikube only) Load models on minikube's registry
```bash
make load
```

### Deploy required components
* ambassador
```bash
make ambassador
```

* seldon-core-analytics
```bash
make seldon-core-analytics
```

* seldon-core
```bash
make seldon-core
```

### Deployment
```bash
make abtest
```

### Port-forward ambassador
```bash
make port
```

### Port-forward Grafana
```bash
make port-grafana
```

## Start Streamlit App
```shell
make streamlit
```

## References

* Training: https://github.com/SeldonIO/seldon-core/tree/master/examples/models/sklearn_spacy_text
* Seldon-core installation: 
  * Install Ambassador: https://docs.seldon.io/projects/seldon-core/en/latest/ingress/ambassador.html
  * Install seldon-core operator: https://docs.seldon.io/projects/seldon-core/en/latest/workflow/install.html
* Seldon-core-analytics installation: https://docs.seldon.io/projects/seldon-core/en/latest/charts/seldon-core-analytics.html
* Custom metrics: https://docs.seldon.io/projects/seldon-core/en/latest/examples/runtime_metrics_tags.html
* Streamlit: https://docs.streamlit.io/library/cheatsheet
