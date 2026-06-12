#!/usr/bin/env bash
# Backend Brain — One-line remote installer
# Usage: curl -fsSL <url>/bootstrap.sh | bash
set -eu

REPO="https://github.com/YOUR_USER/backend-brain.git"
BRANCH="main"
TMP=$(mktemp -d)
PROJECT="${1:-$(pwd)}"

cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

echo "⚡ Backend Brain — Remote Install"
echo "→ Downloading..."
git clone --depth 1 --branch "$BRANCH" "$REPO" "$TMP" 2>/dev/null || {
    echo "❌ Failed to clone $REPO"
    echo "   Update REPO= in bootstrap.sh to your actual repo URL."
    exit 1
}
echo "→ Installing..."
cd "$TMP"; bash scripts/install.sh "$PROJECT"
echo "✅ Installed. Next session, say 'continue'."
