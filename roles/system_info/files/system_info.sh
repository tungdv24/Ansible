#!/bin/bash

# Gather system information
hostname_info=$(hostname)
ip_info=$(hostname -I | awk '{print $1}')
ram_info=$(free -h | grep Mem | awk '{print "RAM: " $2}')
cpu_cores=$(nproc)
cpu_info="CPU cores: $cpu_cores"
disk_info=$(df -h | grep '/dev/sda2')

# Format the message to be sent to Telegram
message="System Information:
Hostname: $hostname_info
IP Address: $ip_info
$ram_info
$cpu_info
Disk Usage:
$disk_info"

# Telegram bot API URL
token=""
chat_id=""

# Send the message to Telegram
curl -s -X POST https://api.telegram.org/bot$token/sendMessage \
    -d chat_id=$chat_id \
    -d text="$message"
