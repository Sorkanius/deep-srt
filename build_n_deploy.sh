#!/bin/bash
docker build -f dockerfile-base -t base-srt:v2 .
docker build -f receiver/dockerfile-receiver -t olympia.azurecr.io/receiver-srt:v2 . &&  docker push olympia.azurecr.io/receiver-srt:v2
docker build -f transmitter/dockerfile-transmitter -t olympia.azurecr.io/transmitter-srt:v2 . &&  docker push olympia.azurecr.io/transmitter-srt:v2
