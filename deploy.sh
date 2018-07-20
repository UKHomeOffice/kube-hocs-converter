#!/bin/bash

export KUBE_NAMESPACE=${KUBE_NAMESPACE}
export KUBE_SERVER=${KUBE_SERVER}

if [[ -z ${VERSION} ]] ; then
    export VERSION=${IMAGE_VERSION}
fi

if [[ ${ENVIRONMENT} == "prod" ]] ; then
    echo "deploy ${VERSION} to pr namespace, using HOCS_CONVERTER_PROD drone secret"
    export KUBE_TOKEN=${HOCS_CONVERTER_PROD}
    export REPLICAS="1"
else
    if [[ ${ENVIRONMENT} == "qa" ]] ; then
        echo "deploy ${VERSION} to test namespace, using HOCS_CONVERTER_QA drone secret"
        export KUBE_TOKEN=${HOCS_CONVERTER_QA}
        export REPLICAS="1"
    else
        echo "deploy ${VERSION} to dev namespace, HOCS_CONVERTER_DEV drone secret"
        export KUBE_TOKEN=${HOCS_CONVERTER_DEV}
        export REPLICAS="1"
    fi
fi

if [[ -z ${KUBE_TOKEN} ]] ; then
    echo "Failed to find a value for KUBE_TOKEN - exiting"
    exit -1
fi

echo
echo "Deploying hocs-converter to ${ENVIRONMENT}"
echo

cd kd

kd --insecure-skip-tls-verify \
    -f deployment.yaml \
    -f service.yaml
