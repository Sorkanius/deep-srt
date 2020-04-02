#!/bin/bash
docker build -f ../dockerfile-base -t base-srt:v2 .
docker build -f dockerfile-receiver -t receiver-srt:v2 .
