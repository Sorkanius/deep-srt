#!/bin/bash
docker build -f dockerfile-base -t base-srt:v2 .
docker build -f dockerfile-transmitter -t transmitter-srt:v2 .
