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
   1. GKE
   ```shell
    gcloud container clusters create demo-cluster-ab-test \
      --zone=europe-west3-a \
      --disk-size=30GB \
      --cluster-version=1.24.12-gke.1000 \
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
docker build -t streamlit-app:v1.0.0 -f Dockerfile.streamlit .
```

#### Cloud Submit
```shell
sh build-modela.sh
sh build-modelb.sh
sh build-streamlit.sh
```

### Deploy required components
* emissary-ingress
```bash
make emissary
```

* Prometheus
```bash
make prometheus
```

* Grafana
```bash
make grafana
```

* seldon-core
```bash
make seldon-core
```

### Deployment
```bash
make abtest
```

### Port-forward Grafana
```bash
make port-grafana
```

## Start Streamlit App
```shell
make streamlit
```

## Contact

Sadik Bakiu (sadik [at] data-max.io)

Developed with ❤ at [Data Max](https://www.data-max.io/)

## References

* Model Training: https://github.com/SeldonIO/seldon-core/tree/master/examples/models/sklearn_spacy_text
* Seldon-core installation: 
  * Install Ambassador: https://docs.seldon.io/projects/seldon-core/en/latest/ingress/ambassador.html
  * Install seldon-core operator: https://docs.seldon.io/projects/seldon-core/en/latest/workflow/install.html
* Seldon-core-analytics installation: https://docs.seldon.io/projects/seldon-core/en/latest/charts/seldon-core-analytics.html
* Custom metrics: https://docs.seldon.io/projects/seldon-core/en/latest/examples/runtime_metrics_tags.html
* Streamlit: https://docs.streamlit.io/library/cheatsheet
