#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# CIBERSORTx Docker Launcher
# ============================================================

# Project directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
RESULTS_DIR="$SCRIPT_DIR/results"
CONFIG_FILE="$SCRIPT_DIR/.env"

IMAGE="cibersortx/fractions"

# ------------------------------------------------------------
# 1. Check configuration
# ------------------------------------------------------------

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: Configuration file .env not found."
    echo "Create it with: cp .env.example .env"
    exit 1
fi

# Load local configuration
source "$CONFIG_FILE"

# Check required variables
: "${CIBERSORTX_EMAIL:?Missing CIBERSORTX_EMAIL in .env}"
: "${CIBERSORTX_TOKEN:?Missing CIBERSORTX_TOKEN in .env}"
: "${MIXTURE_FILE:?Missing MIXTURE_FILE in .env}"
: "${SIGMATRIX_FILE:?Missing SIGMATRIX_FILE in .env}"

PERM="${PERM:-100}"
QN="${QN:-FALSE}"

# ------------------------------------------------------------
# 2. Check Docker
# ------------------------------------------------------------

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker is not installed or is not in PATH."
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Cannot access Docker."
    echo "Check Docker permissions or contact your administrator."
    exit 1
fi

# ------------------------------------------------------------
# 3. Check input files
# ------------------------------------------------------------

MIXTURE_PATH="$DATA_DIR/$MIXTURE_FILE"
SIGMATRIX_PATH="$DATA_DIR/$SIGMATRIX_FILE"

if [[ ! -f "$MIXTURE_PATH" ]]; then
    echo "ERROR: Mixture file not found:"
    echo "  $MIXTURE_PATH"
    exit 1
fi

if [[ ! -f "$SIGMATRIX_PATH" ]]; then
    echo "ERROR: Signature matrix not found:"
    echo "  $SIGMATRIX_PATH"
    exit 1
fi

# ------------------------------------------------------------
# 4. Prepare output directory
# ------------------------------------------------------------

mkdir -p "$RESULTS_DIR"

# ------------------------------------------------------------
# 5. Download Docker image if necessary
# ------------------------------------------------------------

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    echo "Downloading CIBERSORTx Docker image..."
    docker pull "$IMAGE"
fi

# ------------------------------------------------------------
# 6. Display configuration
# ------------------------------------------------------------

echo
echo "========================================"
echo "       CIBERSORTx Fractions"
echo "========================================"
echo "Input mixture:       $MIXTURE_FILE"
echo "Signature matrix:    $SIGMATRIX_FILE"
echo "Permutations:        $PERM"
echo "Quantile norm.:      $QN"
echo "Output directory:    $RESULTS_DIR"
echo "========================================"
echo

# ------------------------------------------------------------
# ------------------------------------------------------------
````bash
# ------------------------------------------------------------
# 7. Run CIBERSORTx
# ------------------------------------------------------------

set +e
docker run --rm \
    -v "$DATA_DIR:/src/data:ro" \
    -v "$RESULTS_DIR:/src/outdir" \
    "$IMAGE" \
    --username "$CIBERSORTX_EMAIL" \
    --token "$CIBERSORTX_TOKEN" \
    --mixture "$MIXTURE_FILE" \
    --sigmatrix "$SIGMATRIX_FILE" \
    --perm "$PERM" \
    --QN "$QN" 2>&1 | sed -E \
        -e 's/(token: )[[:graph:]]+/\1[REDACTED]/Ig' \
        -e 's/(--token[[:space:]]+)[^[:space:]]+/\1[REDACTED]/Ig'

status=${PIPESTATUS[0]}
set -e

if [[ "$status" -eq 0 ]]; then
    echo
    echo "CIBERSORTx finished."
    echo "Check your results in: $RESULTS_DIR"
else
    echo "ERROR: CIBERSORTx failed with exit code $status."
    exit "$status"
fi
