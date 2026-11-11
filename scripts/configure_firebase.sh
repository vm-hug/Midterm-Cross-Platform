#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export PATH="$PWD/node_modules/.bin:$HOME/.pub-cache/bin:$PATH"
flutterfire configure --project=giuaki-13b9b --platforms=web,android,ios --android-package-name=vn.edu.midterm.midterm_cross_platform --ios-bundle-id=vn.edu.midterm.midtermCrossPlatform
