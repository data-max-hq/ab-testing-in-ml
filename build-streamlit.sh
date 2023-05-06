#!/bin/bash

gcloud builds submit --config=cloudbuild.yaml \
  --substitutions=_LOCATION="europe-west3",_REPOSITORY="ab-testing",_DOCKERFILE="Dockerfile.streamlit",_IMAGE="streamlit-app",_TAG="1.0.1" \
  .