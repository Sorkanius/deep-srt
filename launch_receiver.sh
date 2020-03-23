#!/bin/bash
./build_receiver.sh
docker rm receiver-srt
docker run --network SRT-network --volume="$(pwd)/logs":/logs --name receiver-srt receiver-srt:v2
