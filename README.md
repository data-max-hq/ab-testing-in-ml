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
## Testing
```bash
curl -X POST -H 'Content-Type: application/json' \
    -d '{"data": { "ndarray": ["This is a nice comment."]}}' \
    http://localhost:8080/seldon/seldon/abtest/api/v1.0/predictions
```

## References

* Trainig: https://github.com/SeldonIO/seldon-core/tree/master/examples/models/sklearn_spacy_text
* ABTest helm: https://github.com/SeldonIO/seldon-core/tree/master/helm-charts/seldon-abtest
* Seldon Installation: https://docs.seldon.io/projects/seldon-core/en/latest/ingress/ambassador.html
  * https://docs.seldon.io/projects/seldon-core/en/latest/examples/seldon_core_setup.html
  * https://docs.seldon.io/projects/seldon-core/en/latest/ingress/ambassador.html
* Metrics: https://docs.seldon.io/projects/seldon-core/en/latest/examples/metrics.html
  * https://github.com/SeldonIO/seldon-core/tree/master/examples/models/custom_metrics
* 