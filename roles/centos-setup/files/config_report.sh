#!/bin/bash

TELEGRAM_TOKEN="${TELEGRAM_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"

if [[ -z "$TELEGRAM_TOKEN" || -z "$TELEGRAM_CHAT_ID" ]]; then
    echo "Error: TELEGRAM_TOKEN or TELEGRAM_CHAT_ID is not set."
    exit 1
fi

# Function to get all IPs assigned to 'ens' interfaces
function get_all_ips() {
    echo "All IP addresses on 'ens' interfaces:"
    ip -o -4 addr show | awk '/ens/ {print $2, $4}'
    echo
}

# Function to list all open firewalld ports
function list_firewalld_ports() {
    echo "All open firewall ports:"
    firewall-cmd --list-all | grep ports | sed 's/ports: //g'
    echo
}

# Function to echo the server configured in zabbix_agent.conf
function get_zabbix_server() {
    echo "Zabbix server configured in /etc/zabbix/zabbix_agentd.conf:"
    grep '^Server=' /etc/zabbix/zabbix_agentd.conf
    echo
}

# Function to list block devices
function get_block_devices() {
    echo "Block devices information:"
    lsblk
    echo
}

# Function to get the status of services
function get_service_status() {
    local service="$1"
    echo "Service status for $service:"
    systemctl is-active "$service" &>/dev/null && echo "$service is active" || echo "$service is inactive"
    echo
}

# Function to send a message to Telegram
function send_to_telegram() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
         -d chat_id="${TELEGRAM_CHAT_ID}" \
         -d text="${message}" > /dev/null
}

# Function to remove the script itself
function self_remove() {
    echo "Removing script: $0"
    rm -f "$0"
}

# Collect information
report=$(cat <<EOF
Server Configuration Report:

1. All IP addresses on 'ens' interfaces:
$(ip -o -4 addr show | awk '/ens/ {print $2, $4}')

2. All open firewall ports:
$(firewall-cmd --list-all | grep ports | sed 's/ports: //g')

3. Zabbix server configured in /etc/zabbix/zabbix_agentd.conf:
$(grep '^Server=' /etc/zabbix/zabbix_agentd.conf)

4. Block devices:
$(lsblk)

5. Service statuses:
- firewalld: $(systemctl is-active firewalld &>/dev/null && echo "active" || echo "inactive")
- zabbix-agent: $(systemctl is-active zabbix-agent &>/dev/null && echo "active" || echo "inactive")
- sshd: $(systemctl is-active sshd &>/dev/null && echo "active" || echo "inactive")

EOF
)

# Send the report to Telegram
send_to_telegram "$report"

# Delete the script after sending the report
self_remove
