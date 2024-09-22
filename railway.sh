#!/bin/bash

set -eu -o pipefail
# https://superuser.com/a/1403037
export TEMPORAL_BROADCAST_ADDRESS="$(ip -6 addr|awk '{print $2}'|ack -o '^(?!fe80)[[:alnum:]]{4}:.*/64'|cut -d '/' -f1)"
echo "Broadcasting address $TEMPORAL_BROADCAST_ADDRESS"
echo "Starting Temporal server"
echo "Args: $@"
/etc/temporal/entrypoint.sh "$@"
