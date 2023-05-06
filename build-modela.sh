#!/bin/bash

gcloud builds submit --config=cloudbuild.yaml \
  --substitutions=_LOCATION="europe-west3",_REPOSITORY="ab-testing",_DOCKERFILE="Dockerfile.a",_IMAGE="model",_TAG="a1" \
  .