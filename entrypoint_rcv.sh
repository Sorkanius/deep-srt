#!/bin/bash
mkdir /logs/$ID
timeout 30 tshark -i eth0 -f "port 1234" -s 1500 -w /logs/$ID/rcv-vSRT.pcapng &
exec ./bin/srt-xtransmit --loglevel fatal receive "srt://1234?transtype=live&latency=$LATENCY" --msgsize 1316 --statsfile /dev/stdout --statsfreq $REPORT_FREQUENCY
