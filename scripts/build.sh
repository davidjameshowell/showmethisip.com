#!/bin/bash

STAGE="${STAGE-development}"
TAG="${TAG-v0.0.1}"
REGION="${AWS_REGION:-us-east-1}"
REPOSITORY_NAME="showmethisip"
GITHUB_ENABLE_CACHE="${ENABLE_CACHE:-false}"
DOCKER_CACHE_FROM_PARAMETER=""
DOCKER_CACHE_TO_PARAMETER=""

if ECR_REPO=$(aws --region="${REGION}" --output json ecr describe-repositories --repository-name ${REPOSITORY_NAME} 2>&1); then
    echo "Repo exists, moving on..."
else
    bash ./scripts/bootstrap.sh
fi

FIND_ECR_REPOSITORY="$(aws --region=us-east-1 ecr describe-repositories --repository-name ${REPOSITORY_NAME})"
REPOSITORY_ID="$(echo ${FIND_ECR_REPOSITORY} | jq --raw-output '.repositories[].registryId')"

rm zappa_settings.py
zappa save-python-settings-file "${STAGE}" -o zappa_settings.py
aws --region="${REGION}" ecr get-login-password | docker login --username AWS --password-stdin "${REPOSITORY_ID}".dkr.ecr."${REGION}".amazonaws.com

if [[ $GITHUB_ENABLE_CACHE == *"true"* ]]; then
    DOCKER_CACHE_FROM_PARAMETER=" --cache-from /tmp/.buildx-cache"
    DOCKER_CACHE_TO_PARAMETER=" --cache-to /tmp/.buildx-cache-new"
    docker buildx build "${DOCKER_CACHE_FROM_PARAMETER}" "${DOCKER_CACHE_TO_PARAMETER}" --tag "${REPOSITORY_ID}".dkr.ecr."${REGION}".amazonaws.com/"${REPOSITORY_NAME}":"${STAGE}"-"${TAG}" --output=type=registry .
fi
docker buildx build --tag "${REPOSITORY_ID}".dkr.ecr."${REGION}".amazonaws.com/"${REPOSITORY_NAME}":"${STAGE}"-"${TAG}" --output=type=registry .
