#!/bin/bash

gcloud builds submit --config=cloudbuild.yaml \
  --substitutions=_LOCATION="europe-west3",_REPOSITORY="ab-testing",_DOCKERFILE="Dockerfile.b",_IMAGE="model",_TAG="b" \
  .