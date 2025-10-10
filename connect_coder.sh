#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$SCRIPT_DIR/modules/select_coder_env.sh"

env_index=""
port_arg=""
forward_port=""

while getopts ":e:p:" opt; do
	case ${opt} in
	e)
		env_index="$OPTARG"
		;;
	p)
		port_arg="$OPTARG"
		;;
	\?)
		echo "Invalid option: -$OPTARG" >&2
		exit 1
		;;
	:)
		echo "Option -$OPTARG requires an argument." >&2
		exit 1
		;;
	esac
done

if [[ -n "$env_index" ]]; then
	if ! [[ "$env_index" =~ ^[0-9]+$ ]]; then
		echo "Environment (-e) must be a number between 1 and ${#KEYS[@]}"
		exit 1
	fi

	if ((env_index < 1 || env_index > ${#KEYS[@]})); then
		echo "Invalid environment index: $env_index"
		echo "Valid range: 1 to ${#KEYS[@]}"
		echo "${KEYS[*]}"
		exit 1
	fi

	selected_key="${KEYS[$((env_index - 1))]}"
	ssh_host="${CODER_SSH_LIST[$selected_key]}"
else
	select_environment
fi

if [[ -n "$port_arg" ]]; then
	if ! [[ "$port_arg" =~ ^[0-9]+$ ]]; then
		echo "Invalid port number: $port_arg"
		exit 1
	fi
	forward_port="y"
else
	read -p "Should forward port? [Y/N]: " forward_port
fi

if [[ "${forward_port,,}" == "y" ]]; then
	if [[ -z "$port_arg" ]]; then
		read -p "Enter port number: " port_arg
	fi
	ssh -L "$port_arg:localhost:$port_arg" "$ssh_host"
else
	ssh "$ssh_host"
fi
