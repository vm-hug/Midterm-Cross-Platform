#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export PATH="$PWD/node_modules/.bin:$HOME/.pub-cache/bin:$PATH"
firebase deploy --only firestore:rules --project=giuaki-13b9b
