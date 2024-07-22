#!/bin/bash

set -eu -o pipefail
ip -6 addr
ip addr show dev railnet0 | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d'
# https://superuser.com/a/1403037
export TEMPORAL_BROADCAST_ADDRESS="$(ip -6 addr|awk '{print $2}'|ack -o '^(?!fe80)[[:alnum:]]{4}:.*/64'|cut -d '/' -f1)"
echo "$TEMPORAL_BROADCAST_ADDRESS"

echo "Starting Temporal server"

/etc/temporal/entrypoint.sh "$@"
