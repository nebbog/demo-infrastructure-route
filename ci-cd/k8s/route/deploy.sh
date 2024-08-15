#!/usr/bin/env bash

usage() { echo "Usage: $0 -i <infrastructure>" 1>&2; exit 1; }

set -e
set -x

declare inf=""


# Initialize parameters specified from command line
while getopts ":i:" arg; do
	case "${arg}" in
		i)
			inf=${OPTARG}
			;;

		esac
done
shift $((OPTIND-1))


if [[ -z "$inf" ]]; then

    echo "infrastructure is required"
    usage
    exit 1
fi

ENV_CONFIG="env/${inf}/.env"

if [ ! -f "${ENV_CONFIG}" ] ; then

    echo "Environment config file ${ENV_CONFIG} not found"
    exit 1

fi

source "${ENV_CONFIG}"

HELM_ENV_CONFIG="helm/conf/env/${inf}/values.yaml"

if [ ! -f "${HELM_ENV_CONFIG}" ] ; then

    echo "Helm Environment config file ${HELM_ENV_CONFIG} not found"
    exit 1

fi

helm template ./helm \
    -f ${HELM_ENV_CONFIG} \
    --set inf=${inf} \
    | oc apply -f - --dry-run=client -o json

set +x
set +e

