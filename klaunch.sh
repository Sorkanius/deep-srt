#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'

function print_usage() {
        echo ""
        echo "Usage:"
        echo "${0} <release_name> <transmitter_context?> <receiver_context?><latency?>"
        echo "release_name: Unique name to use as this test (must be unique in both transmitter and receiver context). Mandatory"
        echo "transmitter_context: kubernetes context name of the transmitter cluster. If empty, current-context is used. Can be enforced as current with character '-'"
        echo "receiver_context: kubernetes context name of the receiver cluster. If empty, current-context is used. Can be enforced as current with character '-'"
        echo "latency: Latency for both receiver and transmitter. 120ms by default"
        echo "Examples"
        echo "Launches a test with name test1 internally in cluster eastusOlympia: ${0} test1 eastusOlympia"
        echo "Launches a test with name test1 from current cluster to easia cluster: ${0} test1 - easia"
        echo "Launches a test with name test1 from eastus to easia with latency 50ms: ${0} test1 eastus easia 50"
        echo "Launches a test with name test1 within current context with latency 50ms: ${0} test1 - - 50"
}

function show_message() {
  message="${1}"
  # Show message
  message_length=${#message}
  (( line=message_length+4 ))
  fill=$(printf '%*s' "$line" " " | sed 'y/ /═/')
  echo "╔${fill}╗"
  echo "╠═ ${message} ═╣"
  echo "╚${fill}╝"
}

if (( ${#} < 1 )); then
  echo -e "${RED}ERROR: Release name is mandatory! ${NC}"
  print_usage
  exit 1;
fi

RELEASE_NAME=${1}
TRANSMITTER_RN=${RELEASE_NAME}-t
RECEIVER_RN=${RELEASE_NAME}-r

CONTEXT_T=${2:-"-"}
if [ "$CONTEXT_T" != "-" ]; then
  CONTEXT_T_PARAM="--kube-context $CONTEXT_T"
else
  CONTEXT_T_PARAM=""
fi

CONTEXT_R=${3:-"-"}
if [ "$CONTEXT_R" != "-" ]; then
  CONTEXT_R_PARAM="--kube-context $CONTEXT_R"
else
  CONTEXT_R_PARAM=""
fi
LATENCY=${4:-120}

show_message "Test $RELEASE_NAME from $CONTEXT_T to $CONTEXT_R with latency $LATENCY"

if [ "$CONTEXT_R" == "$CONTEXT_T" ]; then
  RECEIVER_ADDRESS="${RECEIVER_RN}-deep-srt-receiver"
else
  UEAST_PORT="30666"
  UEAST_SERVICE_NAME="srt-ueast"
  FR_PORT="30635"
  FR_SERVICE_NAME="srt-fr"

  RECEIVER_ADDRESS="$UEAST_SERVICE_NAME"
  NODEPORT="$UEAST_PORT"
  if [ "$CONTEXT_R" == "olympiaFR" ]; then
    RECEIVER_ADDRESS="$FR_SERVICE_NAME"
    NODEPORT="$FR_PORT"
  fi
fi

TARGET_IP=$(kubectl --context "$CONTEXT_R" get nodes -o json | jq -r '.items[0].status.addresses[] | select(.type=="InternalIP") | .address')
echo "Target ip is $TARGET_IP"
helm install --name "$RECEIVER_RN" helmcharts/deep-srt-receiver $CONTEXT_R_PARAM --values helmcharts/azure_test.yaml --set "latency=${LATENCY}" --set service.nodePort=${NODEPORT}
helm install --name "$TRANSMITTER_RN" helmcharts/deep-srt-transmitter $CONTEXT_T_PARAM --values helmcharts/azure_test.yaml --set "latency=${LATENCY}" --set receiverAddress=${RECEIVER_ADDRESS}

