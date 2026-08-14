#!/bin/sh
export TEMPORAL_BROADCAST_ADDRESS="$(ip -6 addr | awk '{print $2}' | grep -v '^fe80' | grep -E '^[0-9a-fA-F:]+/64' | cut -d '/' -f1)"
echo "$(getent hosts "$(hostname)" | awk '{print $1;}')"
exec "$@"
