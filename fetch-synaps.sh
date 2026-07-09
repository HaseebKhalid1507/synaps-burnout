#!/usr/bin/env bash
# fetch-synaps.sh — pull the static musl Synaps release binary into the build context.
#
# SynapsCLI is a PRIVATE repo, so this runs on a host that has `gh` authenticated.
# The binary lands next to the Dockerfile as ./synaps and gets COPY'd into the image
# at build time — no GH token ever touches the image or its layers.
#
#   ./fetch-synaps.sh            # default pinned version
#   ./fetch-synaps.sh v0.5.1     # explicit version
#
set -euo pipefail

SYNAPS_VERSION="${1:-v0.5.1}"
REPO="HaseebKhalid1507/SynapsCLI"
ASSET="synaps-x86_64-unknown-linux-musl.tar.gz"   # static, base-agnostic, glibc-proof

echo ">> fetching Synaps ${SYNAPS_VERSION} (${ASSET}) from ${REPO}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

gh release download "$SYNAPS_VERSION" -R "$REPO" -p "$ASSET" -D "$tmp"
tar xzf "$tmp/${ASSET}" -C "$tmp"

bin="$(find "$tmp" -name synaps -type f | head -1)"
[ -n "$bin" ] || { echo "!! synaps binary not found in asset" >&2; exit 1; }

cp "$bin" ./synaps
chmod 755 ./synaps
echo -n ">> ready: "; ./synaps --version
