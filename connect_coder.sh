#!/bin/bash

CODER_USER=""

KEYS=()
declare -A CODER_SSH_LIST=(
	# [KEYS[i]]="Connection String"
	# add others
)

echo "Environments:"
i=1
for key in "${KEYS[@]}"; do
	echo "$i. $key"
	((i++))
done

read -p "Choose the environment: " user_choice

if ! [[ "$user_choice" =~ ^[0-9]+$ ]]; then
	echo "Input must be a number."
	exit 1
fi

if ((user_choice < 1 || user_choice > ${#KEYS[@]})); then
	echo "Input must be between 1 and ${#KEYS[@]}"
	exit 1
fi

selected_key="${KEYS[$((user_choice - 1))]}"
ssh_host="${CODER_SSH_LIST[$selected_key]}"

read -p "Should forward port? [Y/N]: " foward_port

if [[ "${foward_port,,}" == "y" ]]; then
	read -p "Enter port number: " port
	ssh -L "$port:localhost:$port" "$ssh_host"
else
	ssh "$ssh_host"
fi
