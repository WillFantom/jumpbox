#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
  set -o xtrace
fi

#####################
## STATIC SETTINGS ##
#####################

AUTH_CONFIG_PATH=/etc/ssh/keys.d/auth.json


###############
## UTILITIES ##
###############

## Validate a linux username, sanitizing lookups
function validate_username() {
  regex="^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$"
  if [[ ! $1 =~ ${regex} ]]; then
    exit 1
  fi
  return 0
}


##############
## GRABBERS ##
##############

## Grab the settings from the JSON
function get_settings_json() {
  jq -r -c '.settings?' "${AUTH_CONFIG_PATH}" 2> /dev/null
}

## Get the json object for the username given by the first argument to the script
## (this will cause an exit if the user is not found)
function get_user_json() {
  jq -r -c -e --arg u "${1}" '.users?.[]? | select(.username? == $u)' "${AUTH_CONFIG_PATH}" 2>/dev/null
}


######################
## DYNAMIC SETTINGS ##
######################

SETTINGS_JSON=$(get_settings_json)
GITHUB_ENABLED=$(echo "${SETTINGS_JSON}" | jq -r -c '.github_enable // false')
GITHUB_REQUIRED_ORG=$( (echo "${SETTINGS_JSON}" | jq -r -c '.github_required_org // empty'))


#############
## DUMPERS ##
#############

## Dump the raw keys for a user to stdout if given the user json as the first positional arg
function dump_keys_raw() {
  user_keys=$(echo "${1}" | jq -r -c .keys?.[]?)
  printf '%s\n' "$user_keys" | while IFS= read -r k; do
    echo "$k"
  done
}

## Dump the GitHub keys for a user to stdout if given the user json as the first positional arg and the settings allow for this
function dump_keys_github() {
  if [ "${GITHUB_ENABLED}" != 'true' ]; then
    return 1
  fi
  github_username=$(echo "${1}" | jq -r -c .github 2>/dev/null)
  if [ "${github_username}" = "" ]; then
    return 1
  fi
  if [ -n "${GITHUB_REQUIRED_ORG}" ]; then
    if ! (curl -fsSL "https://api.github.com/users/${github_username}/orgs" | jq  -r -c -e --arg o "${GITHUB_REQUIRED_ORG}" '.[]? | select(.login? == $o)' ) &>/dev/null; then
      return 1
    fi
  fi 
  github_keys=$( (curl -fsSL "https://github.com/${github_username}.keys" ) 2>/dev/null )
  printf '%s\n' "$github_keys" | while IFS= read -r k; do
    echo "$k"
  done
}


##########
## MAIN ##
##########

function main() {
  validate_username "${1}"
  user_json=$(get_user_json "${1}")
  dump_keys_raw "$user_json"
  dump_keys_github "$user_json"
}

main "$@"
