FROM base-srt:v1
RUN DEBIAN_FRONTEND=noninteractive apt install -y tshark
CMD ["tshark", "-i", "eth0", "-f", "port 4200", "-s", "1500", "-w", "./rc-vSRT.pcapng"]
