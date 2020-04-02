#!/bin/bash
./build_transmitter.sh
docker rm transmitter-srt
docker run --privileged --network SRT-network --volume="$(pwd)/logs":/logs --name transmitter-srt transmitter-srt:v2
