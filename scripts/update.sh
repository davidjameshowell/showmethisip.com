#!/bin/bash

STAGE="${STAGE-development}"
TAG="${TAG-v0.0.1}"
REGION="${AWS_REGION:-us-east-1}"
REPOSITORY_NAME="showmethisip"

FIND_ECR_REPOSITORY=$(aws --region=us-east-1 ecr describe-repositories --repository-name ${REPOSITORY_NAME})
REPOSITORY_ID=$(echo ${FIND_ECR_REPOSITORY} | jq --raw-output '.repositories[].registryId')

#ZAPPA_STATUS=$(zappa status ${STAGE})

if ZAPPA_STATUS=$(zappa status ${STAGE} 2>&1); then
    zappa update "${STAGE}" -d "${REPOSITORY_ID}".dkr.ecr."${REGION}".amazonaws.com/"${REPOSITORY_NAME}":"${STAGE}"-${TAG}
else
    bash ./scripts/bootstrap.sh
    zappa deploy "${STAGE}" -d "${REPOSITORY_ID}".dkr.ecr."${REGION}".amazonaws.com/"${REPOSITORY_NAME}":"${STAGE}"-${TAG}
fi