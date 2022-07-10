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

2. Create a Kubernetes cluster. For local clusters, one can use `minikube`, `kind`, or `k3s`. In case you are using `minikube`:
```bash
make minikube
```

### Train model
Prepare the model artifacts
```
make train
```

### Build container images
```
make build
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

## Testing
```bash
curl -X POST -H 'Content-Type: application/json' \
    -d '{"data": { "ndarray": ["This is a nice comment."]}}' \
    http://localhost:8080/seldon/seldon/abtest/api/v1.0/predictions
```

## Start Streamlit App
```shell
make run-streamlit
```

## References

* Training: https://github.com/SeldonIO/seldon-core/tree/master/examples/models/sklearn_spacy_text
* Seldon-core installation: 
  * Install Ambassador: https://docs.seldon.io/projects/seldon-core/en/latest/ingress/ambassador.html
  * Install seldon-core operator: https://docs.seldon.io/projects/seldon-core/en/latest/workflow/install.html
* Seldon-core-analytics installation: https://docs.seldon.io/projects/seldon-core/en/latest/charts/seldon-core-analytics.html
* Custom metrics: https://docs.seldon.io/projects/seldon-core/en/latest/examples/runtime_metrics_tags.html
