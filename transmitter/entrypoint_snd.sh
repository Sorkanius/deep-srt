#!/bin/bash
mkdir /logs/$ID
timeout 30 tshark -i eth0 -f "port $RECEIVER_PORT" -s 1500 -w /logs/$ID/snd-vSRT.pcapng &
exec ./bin/srt-xtransmit --loglevel fatal generate "srt://$RECEIVER_ADDRESS:$RECEIVER_PORT?transtype=live&latency=$LATENCY" --msgsize 1316 --sendrate $SENDRATE --duration $DURATION  --statsfile /logs/$ID/snd-logs.csv --statsfreq $REPORT_FREQUENCY