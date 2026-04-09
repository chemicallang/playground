#!/bin/bash

#
# Copyright (c) Chemical Language Foundation 2026.
#

# Load variables from the .env file
if [ -f deploy.env ]; then
    export $(grep -v '^#' deploy.env | xargs)
else
    echo "Error: deploy.env file not found."
    exit 1
fi

# SSH and execute the command
sshpass -p "$DEPLOY_PASSWORD" ssh -o StrictHostKeyChecking=no "$DEPLOY_USER@$DEPLOY_HOST" \
    "sudo systemctl restart playground.service"

if [ $? -eq 0 ]; then
    echo "Success"
else
    echo "Deployment failed"
    exit 1
fi