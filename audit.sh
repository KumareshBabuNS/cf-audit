#!/bin/sh

set -e

ORG=$1

if [ "" = "$ORG" ]; then
  echo "Usage: $0 ORG

ORG - the organization name in Cloud Foundry
"
  exit 1
fi

ORG_GUID=$(cf curl "/v2/organizations" | \
jq -r '.resources[] | select(.entity.name == "'$ORG'") | .metadata.guid')

# Get the ORG USERS
cf org-users $ORG

echo
echo

# Get the spaces
SPACES=$(cf curl "/v2/organizations/$ORG_GUID/spaces?results-per-page=100" | \
jq -r '.resources[].entity.name')

# For each space, get the Space users
for SPACE in $SPACES; do
  cf space-users $ORG $SPACE
  echo
  echo
done
