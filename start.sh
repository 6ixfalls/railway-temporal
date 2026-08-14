#!/bin/sh
export TEMPORAL_BROADCAST_ADDRESS="$(getent hosts "$(hostname)" | awk '{print $1;}')"
exec "$@"
