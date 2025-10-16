#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$SCRIPT_DIR/modules/select_coder_env.sh"

env_index=""
port_arg=""
forward_port=""
skip_prompt="false"

while [[ $# -gt 0 ]]; do
	case "$1" in
	-e)
		shift
		env_index="$1"
		shift
		;;
	-p)
		shift
		if [[ $# -gt 0 && "$1" =~ ^[0-9]+$ ]]; then
			port_arg="$1"
			shift
		else
			port_arg=""
		fi
		forward_port="y"
		;;
	-np | --no-port)
		skip_prompt="true"
		forward_port="n"
		shift
		;;
	-*)
		echo "Invalid option: $1" >&2
		exit 1
		;;
	*)
		break
		;;
	esac
done

# echo "DEBUG: env_index=$env_index, forward_port=$forward_port, port_arg=$port_arg, skip_prompt=$skip_prompt"

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

if [[ "$skip_prompt" == "false" && -z "$forward_port" ]]; then
	read -p "Should forward port? [Y/N]: " forward_port
fi

if [[ "${forward_port,,}" == "y" ]]; then
	if [[ -z "$port_arg" ]]; then
		read -p "Enter port number: " port_arg
	fi
	if ! [[ "$port_arg" =~ ^[0-9]+$ ]]; then
		echo "Invalid port number: $port_arg"
		exit 1
	fi
	ssh -L "$port_arg:localhost:$port_arg" "$ssh_host"
else
	ssh "$ssh_host"
fi
