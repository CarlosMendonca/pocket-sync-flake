#!/usr/bin/env bash
# Appends the newest pocket-sync release to data/pocket-sync.json.
#
# pocket-sync ships a prebuilt .deb, so a new entry needs just one content hash,
# read straight from the release asset with nix-prefetch-url -- no build required
# to resolve it (unlike the source-built cliamp flake's vendorHash).
#
# Run from the repo root (so `path:.` and $PWD/data resolve correctly).
#
# Env knobs (all optional):
#   POCKET_SYNC_DATA_DIR   where pocket-sync.json lives   (default: $PWD/data)
#   GITHUB_TOKEN           bearer token to raise the GitHub API rate limit

set -euo pipefail

DATA_DIR="${POCKET_SYNC_DATA_DIR:-$PWD/data}"
DATA="$DATA_DIR/pocket-sync.json"
REPO="neil-morrison44/pocket-sync"

log() { printf '[pocket-sync-update] %s\n' "$*" >&2; }

gh_get() {
  local url="$1"
  local -a auth=()
  [[ -n "${GITHUB_TOKEN:-}" ]] && auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
  curl -fsSL "${auth[@]}" -H "Accept: application/vnd.github+json" "$url"
}

resort() {
  local f="$1" tmp
  tmp="$(mktemp)"
  jq 'unique_by(.version) | sort_by(.version | split(".") | map(tonumber))' "$f" >"$tmp"
  mv "$tmp" "$f"
}

[[ -f "$DATA" ]] || {
  log "no data file at $DATA"
  exit 1
}

LATEST_TAG="$(gh_get "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.tag_name')"
VERSION="${LATEST_TAG#v}"
log "latest upstream release: $LATEST_TAG"

if jq -e --arg v "$VERSION" 'any(.[]; .version == $v)' "$DATA" >/dev/null; then
  log "$VERSION already present, nothing to do."
  exit 0
fi

log "computing srcHash for $LATEST_TAG"
URL="https://github.com/$REPO/releases/download/${LATEST_TAG}/Pocket.Sync_${VERSION}_amd64.deb"
RAW="$(nix-prefetch-url --type sha256 "$URL" 2>/dev/null)"
SRC_HASH="$(nix hash convert --hash-algo sha256 --to sri "$RAW")"
log "srcHash: $SRC_HASH"

tmp="$(mktemp)"
jq --arg v "$VERSION" --arg s "$SRC_HASH" \
  '. + [{version:$v, srcHash:$s}]' "$DATA" >"$tmp"
mv "$tmp" "$DATA"
resort "$DATA"

SAN="$(printf '%s' "$VERSION" | tr '.+-' '___')"
ATTR="pocket-sync_${SAN}"

log "verifying build of .#$ATTR"
nix build "path:.#${ATTR}"
if [[ ! -x ./result/bin/pocket-sync ]]; then
  log "ERROR: ./result/bin/pocket-sync not found or not executable"
  exit 1
fi

log "added $VERSION to $DATA ($(jq length "$DATA") entries)"
