#!/bin/bash

# This script is designed to update the version number in a local JSON file (VERSION.json)
# with the latest version number of Plex for Linux, which it fetches from the Plex API.
# It uses the 'curl' command to fetch the latest version, 'jq' to parse and manipulate JSON data,
# and 'tee' to write the output back to VERSION.json.

# Fetch the latest Plex version for Linux from the Plex API
# The -fsSL flags mean:
# -f: Fail silently on server errors
# -s: Silent mode (don't show progress)
# -S: Show errors
# -L: Follow redirects
# version=$(curl -fsSL "https://api.github.com/repos/juanfont/headscale/releases/latest" | jq -re .name) || exit 1
version=$(curl -fsSL "https://api.github.com/repos/juanfont/headscale/releases" | jq -re .[0].name) || exit 1

# Read the current content of VERSION.json into the variable 'json'
json=$(cat VERSION.json)

# Update the 'version' field in VERSION.json with the latest Plex version
# The --sort-keys flag sorts the keys in the output JSON
# The --arg option allows setting a variable in jq
# The ${version//v/} expression removes any 'v' characters from the version string
# The 'tee' command writes the modified JSON content back to VERSION.json
jq --sort-keys \
    --arg version "${version//v/}" \
    '.version = $version' <<< "${json}" | tee VERSION.json
