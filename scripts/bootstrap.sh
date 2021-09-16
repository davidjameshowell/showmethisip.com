#!/bin/bash

REPOSITORY_NAME="showmethisip"

FIND_ECR_REPOSITORY="$(aws --region=us-east-1 ecr describe-repositories --repository-name ${REPOSITORY_NAME})"

if [[ $FIND_ECR_REPOSITORY == *"RepositoryNotFoundException"* ]]; then
    CREATE_ECR_RESPONSE="$(aws --region=us-east-1 ecr create-repository --repository-name ${REPOSITORY_NAME} --image-scanning-configuration scanOnPush=true)"
    REPOSITORY_ID="$(echo ${CREATE_ECR_RESPONSE} | jq --raw-output '.repository.registryId')"
    echo "Not exist"
else
    REPOSITORY_ID="$(echo ${FIND_ECR_REPOSITORY} | jq --raw-output '.repositories[].registryId')"
fi

aws --region=us-east-1 ecr get-login-password | docker login --username AWS --password-stdin "${REPOSITORY_ID}".dkr.ecr.us-east-1.amazonaws.com
