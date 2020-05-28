#!/usr/bin/env bash

# JWT Encoder Bash Script
#
# A lightly modified version of the original by Will Haley:
# https://willhaley.com/blog/generate-jwt-with-bash/
#
# With stdin handling from Filipe Fortes:
# https://fortes.com/2019/bash-script-args-and-stdin/

# Copy command-line arguments over to new array
ARGS=( $@ )

# Don't split on spaces
IFS='
'

# Read in from piped input, if present, and append to newly-created array
if [ ! -t 0 ]; then
  readarray STDIN_ARGS < /dev/stdin
  ARGS=( $@ ${STDIN_ARGS[@]} )
fi

# Takes two parameters: the shared secret, and the JSON string to encode
secret=${ARGS[0]}

# Take the payload from the arguments, or fall back to stdin
payload=${ARGS[1]}

# Show an error if neither are defined
if [ -z "$secret" ] || [ -z "$payload" ]; then
  >&2 echo "Usage: $0 <secret> <json>"
  exit 1
fi

# Static header fields.
header='{
    "typ": "JWT",
    "alg": "HS256",
    "kid": "0001",
    "iss": "jwt-generator"
}'

# Use jq to set the dynamic `iat` and `exp`
# fields on the header using the current time.
# `iat` is set to now, and `exp` is now + 1 hour.
header=$(
    echo "${header}" | jq --arg time_str "$(date +%s)" \
    '
    ($time_str | tonumber) as $time_num
    | .iat=$time_num
    | .exp=($time_num + 3600)
    '
)

base64_encode() {
    # Use `tr` to URL encode the output from base64.
    base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n'
}

json() {
    jq -c .
}

hmacsha256_sign() {
    openssl dgst -binary -sha256 -hmac "${secret}"
}

header_base64=$(echo "${header}" | json | base64_encode)
payload_base64=$(echo "${payload}" | json | base64_encode)

header_payload=$(echo "${header_base64}.${payload_base64}")
signature=$(echo -n "${header_payload}" | hmacsha256_sign | base64_encode)

echo "${header_payload}.${signature}"
