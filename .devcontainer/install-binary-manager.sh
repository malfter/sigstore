#!/usr/bin/env bash

# bin - Manages binary files downloaded from different sources
# https://github.com/marcosnils/bin
#
# - Download bin from the releases
# - Run ./bin install github.com/marcosnils/bin so bin is managed by bin itself
# - Run bin ls to make sure bin has been installed correctly.

set -e

GITHUB_MARCOSNILS_BIN_VERSION=0.19.1
GITHUB_MARCOSNILS_BIN_DOWNLOAD_URL="https://github.com/marcosnils/bin/releases/download/v${GITHUB_MARCOSNILS_BIN_VERSION}/bin_${GITHUB_MARCOSNILS_BIN_VERSION}_linux_amd64"

mkdir -p "${HOME}/.local/bin"

tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
# Set up trap to delete the directory on script exit
trap 'rm -rf "$tmp_dir"' EXIT

pushd "$tmp_dir"
wget -O bin-tmp "${GITHUB_MARCOSNILS_BIN_DOWNLOAD_URL}"

chmod +x bin-tmp

./bin-tmp install github.com/marcosnils/bin

bin ls && exit 0 || exit 1
