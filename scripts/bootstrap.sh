#!/bin/bash

REPOSITORY_NAME="showmethisip"
REGION="${AWS_REGION:-us-east-1}"

if ECR_REPO=$(aws --region="${REGION}" --output json ecr describe-repositories --repository-name ${REPOSITORY_NAME} 2>&1); then
    REPOSITORY_ID="$(echo ${ECR_REPO} | jq --raw-output '.repositories[].registryId')"
    stdout=$result
else
    rc=$?
    stderr=$ECR_REPO
    CREATE_ECR_RESPONSE="$(aws --region="${REGION}" ecr create-repository --repository-name ${REPOSITORY_NAME} --image-scanning-configuration scanOnPush=true)"
    REPOSITORY_ID="$(echo ${CREATE_ECR_RESPONSE} | jq --raw-output '.repository.registryId')"
fi
