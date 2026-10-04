#!/usr/bin/env bash
# Validate and pack theme/ into dist/<name>-<version>.vytheme (signed when
# VYASA_SIGNING_KEY is set). Needs the vyasa binary on PATH.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p dist
cd dist && vyasa theme pack ../theme ${VYASA_SIGNING_KEY:+--key "$VYASA_SIGNING_KEY"}
