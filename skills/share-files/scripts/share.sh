#!/usr/bin/env bash
# Serve files over Tailscale so any device on the tailnet can download them.
set -euo pipefail

ROOT="${SHARE_ROOT:-$HOME/share-work}"
PORT="${SHARE_PORT:-8450}"
TTL="${SHARE_TTL:-30m}"
SELF="$(readlink -f "${BASH_SOURCE[0]}")"

die() { echo "share: $*" >&2; exit 1; }

serve_paths() {
  tailscale serve status --json | jq -r --arg p ":$PORT" '
    .Web // {} | to_entries[]
    | select(.key | endswith($p))
    | .value.Handlers // {} | keys[]'
}

stop() {
  local token="$1"
  systemctl --user stop "share-$token.timer" >/dev/null 2>&1 || true
  tailscale serve --https="$PORT" --set-path="/$token/" off >/dev/null 2>&1 || true
  rm -rf "${ROOT:?}/$token"
  if [ -z "$(serve_paths)" ]; then
    tailscale serve --https="$PORT" off >/dev/null 2>&1 || true
  fi
}

list_shares() {
  local paths
  paths=$(serve_paths)
  if [ -z "$paths" ]; then
    echo "no active shares"
    return
  fi
  local host token
  host=$(tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//')
  while read -r p; do
    token="${p#/}"; token="${token%/}"
    echo "https://$host:$PORT/$token/"
    find "$ROOT/$token" -mindepth 1 -maxdepth 1 -printf '  %f\n' 2>/dev/null | sort
  done <<<"$paths"
}

share() {
  local ttl="$TTL"
  local paths=()
  while [ $# -gt 0 ]; do
    case "$1" in
      --ttl) ttl="$2"; shift 2 ;;
      --) shift; paths+=("$@"); break ;;
      -*) die "unknown flag: $1" ;;
      *) paths+=("$1"); shift ;;
    esac
  done
  [ "${#paths[@]}" -gt 0 ] || die "usage: share <path>... [--ttl 30m]"

  local token dir src name base ext n
  for src in "${paths[@]}"; do
    [ -e "$src" ] || die "not found: $src"
  done

  token=$(openssl rand -hex 4)
  dir="$ROOT/$token"
  mkdir -p "$dir"

  local names=()
  for src in "${paths[@]}"; do
    name=$(basename "$src")
    if [ -e "$dir/$name" ]; then
      base="${name%.*}"; ext=""
      [ "$base" != "$name" ] && ext=".${name##*.}"
      n=2
      while [ -e "$dir/$name" ]; do name="$base-$n$ext"; n=$((n + 1)); done
    fi
    ln -s "$(readlink -f "$src")" "$dir/$name"
    names+=("$name")
  done

  tailscale serve --bg --https="$PORT" --set-path="/$token" "$dir" >/dev/null

  if ! systemd-run --user --quiet --unit="share-$token" --on-active="$ttl" \
       --setenv=PATH="/usr/local/bin:/usr/bin:/bin" "$SELF" --stop "$token" >/dev/null 2>&1; then
    echo "share: warning: could not schedule auto-expiry, stop manually with --stop $token" >&2
  fi

  echo "https://$(tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//'):$PORT/$token/"
  printf 'files: %s\n' "${names[*]}"
  echo "expires in: $ttl"
  echo "stop now: $SELF --stop $token"
}

case "${1:-}" in
  --stop) stop "${2:?token required}" ;;
  --list) list_shares ;;
  -h|--help|"")
    echo "usage: share <path>... [--ttl 30m]"
    echo "       share --list"
    echo "       share --stop <token>"
    ;;
  *)
    command -v tailscale >/dev/null || die "tailscale is not installed"
    tailscale status >/dev/null 2>&1 || die "tailscale is not running"
    share "$@"
    ;;
esac
