#!/usr/bin/env bash

set -e

# bin finds several matches, with `echo` we select the binary X
echo 1 | bin install -f https://github.com/sigstore/cosign
echo 1 | bin install -f https://github.com/sigstore/rekor
