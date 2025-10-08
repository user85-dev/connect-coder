#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$SCRIPT_DIR/modules/select_coder_env.sh"

select_environment

read -p "Should forward port? [Y/N]: " foward_port

if [[ "${foward_port,,}" == "y" ]]; then
	read -p "Enter port number: " port
	ssh -L "$port:localhost:$port" "$ssh_host"
else
	ssh "$ssh_host"
fi
