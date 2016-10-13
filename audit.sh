#!/bin/sh

set -e

ORG=$1

if [ "" = "$ORG" ]; then
  echo "Usage: $0 ORG

ORG - the organization name in Cloud Foundry
"
  exit 1
fi

command -v cf >/dev/null 2>&1 || {
  cat >&2 << EOM
I require cf (the Cloud Foundry CLI tool).

> brew cask install cf-cli will fix this on MacOS.

Aborting
EOM
  exit 1;
}

command -v cf >/dev/null 2>&1 || {
  cat >&2 << EOM
I require jq (JSON query CLI tool).

> brew cask install jq will fix this on MacOS.

Aborting
EOM
  exit 1;
}

ORG_GUID=$(cf curl "/v2/organizations" | \
jq -r '.resources[] | select(.entity.name == "'$ORG'") | .metadata.guid')

# Get the ORG USERS
if [ $(cf api | grep -c bluemix) -eq "1" ]; then
  # Bluemix is stupid and doesn't behave like any other Cloud Foundry we're using
  # See https://developer.ibm.com/answers/questions/191474/cf-org-users-and-users-name.html
  command -v bx >/dev/null 2>&1 || {
    cat >&2 << EOM
I require bx (Bluemix CLI tool)

> brew cask install bluemix-cli will fix this on MacOS.

Aborting
EOM
    exit 1;
  }
  ORG_USERS_CMD="bx iam org-users"
  SPACE_USERS_CMD="bx iam space-users"
else
  ORG_USERS_CMD="cf org-users"
  SPACE_USERS_CMD="cf space-users"
fi

${ORG_USERS_CMD} $ORG
echo
echo

# Get the spaces
SPACES=$(cf curl "/v2/organizations/$ORG_GUID/spaces?results-per-page=100" | \
jq -r '.resources[].entity.name')

# For each space, get the Space users
for SPACE in $SPACES; do
  ${SPACE_USERS_CMD} $ORG $SPACE
  echo
  echo
done
