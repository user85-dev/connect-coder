#!/bin/bash

CODER_USER=""
declare -A CODER_SSH_LIST=(
	# ["API"] = "main.api.$CODER_USER.coder"
	# Fill it with others
)

KEYS=("${!CODER_SSH_LIST[@]}")

echo "Environments:"
i=1
for key in "${!CODER_SSH_LIST[@]}"; do
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
ssh "$ssh_host"
