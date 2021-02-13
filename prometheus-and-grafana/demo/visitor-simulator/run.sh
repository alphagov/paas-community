#!/usr/bin/env bash

set -e

while true; do
    curl \
        -X POST \
        "https://${FRONTEND_DOMAIN}/submit" \
        -d message="Hi from simulated visitor at $(date)"
done
