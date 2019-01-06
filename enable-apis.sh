#!/usr/bin/env bash

# Stop immediately if something goes wrong
set -euo pipefail

# Validate the user would like to proceed
echo
echo "The following APIs will be enabled in your Google Cloud account:"
echo "- compute.googleapis.com"
echo "- container.googleapis.com"
echo "- cloudbuild.googleapis.com"
echo
read -p "Would you like to proceed? [y/n]: " -n 1 -r
echo

if [[ ! "$REPLY" =~ ^[Yy]$ ]]
then
  echo "Exiting without making changes."
  exit 1
fi

echo "Enabling the Compute API"
gcloud services enable compute.googleapis.com
echo "Enabling the Container API."
gcloud services enable container.googleapis.com
echo "Enabling the Cloud Build API."
gcloud services enable cloudbuild.googleapis.com
echo "APIs enabled successfully."
