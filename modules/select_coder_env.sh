#!/bin/bash

CODER_USER=""

KEYS=()

declare -A CODER_SSH_LIST=(
	# [KEYS[i]]="Connection String"
	# add others
)

select_environment() {
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

	export SSH_HOST="$ssh_host"
}
