#!/bin/bash

STAGE="${STAGE-development}"
TAG="${TAG-v0.0.1}"
REGION="${AWS_REGION:-us-east-1}"
REPOSITORY_NAME="showmethisip"
CI_JOB="${CI_JOB:-true}"
PYENV_EXEC="pyenv exec"

if [[ $CI_JOB == *"true"* ]]; then
    POETRY_VIRTUALENVS_CREATE=false && poetry install --no-root

fi

FIND_ECR_REPOSITORY=$(aws --region=us-east-1 ecr describe-repositories --repository-name ${REPOSITORY_NAME})
REPOSITORY_ID=$(echo ${FIND_ECR_REPOSITORY} | jq --raw-output '.repositories[].registryId')

if ZAPPA_STATUS=$(zappa status ${STAGE} 2>&1); then
    "${PYENV_EXEC}" zappa update "${STAGE}" -d "${REPOSITORY_ID}".dkr.ecr."${REGION}".amazonaws.com/"${REPOSITORY_NAME}":"${STAGE}"-${TAG}
else
    bash ./scripts/bootstrap.sh
    "${PYENV_EXEC}" zappa deploy "${STAGE}" -d "${REPOSITORY_ID}".dkr.ecr."${REGION}".amazonaws.com/"${REPOSITORY_NAME}":"${STAGE}"-${TAG}
fi