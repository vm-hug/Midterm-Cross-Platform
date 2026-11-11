#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter run -d "${1:-chrome}" --dart-define-from-file=config/app.example.json
