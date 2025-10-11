#!/usr/bin/env bash
set -euo pipefail

# ---------- Fixed local paths (do not override) ----------
LOCAL_CONFIGS_LIVE="./ConfigsLive/Sources/ConfigsLive.swift"
LOCAL_SETTINGS_SECRET="./Tuist/ProjectDescriptionHelpers/Settings.secret.swift"

# ---------- Fixed S3 destinations (adjust if needed) ----------
S3_CONFIGS_URI="s3://fixsy-secrets/ios/ConfigsLive.swift"
S3_SECRET_URI="s3://fixsy-secrets/ios/Settings.secret.swift"

# ---------- Command: put | get (default: put) ----------
CMD="${1:-put}"

# Optional AWS envs (keep simple; no CLI flags for paths)
AWS_PROFILE="${AWS_PROFILE:-}"
AWS_REGION="${AWS_REGION:-}"
KMS_KEY_ALIAS="${KMS_KEY_ALIAS:-}" # alias/fixsy-secrets (empty => SSE-S3)

usage() {
  cat >&2 <<-USAGE
  Usage: $(basename "$0") [put|get]

  Environment (optional):
    AWS_PROFILE    AWS CLI profile
    AWS_REGION     AWS region
    KMS_KEY_ALIAS  KMS key alias/ARN (uses SSE-KMS if set; default SSE-S3)

  Local files:
    ${LOCAL_CONFIGS_LIVE}
    ${LOCAL_SETTINGS_SECRET}

  Remote:
    ${S3_CONFIGS_URI}
    ${S3_SECRET_URI}
USAGE
}

command -v aws >/dev/null 2>&1 || {
  echo "❌ aws CLI not found"
  exit 127
}

AWS_OPTS=()
[[ -n "$AWS_PROFILE" ]] && AWS_OPTS+=(--profile "$AWS_PROFILE")
[[ -n "$AWS_REGION" ]] && AWS_OPTS+=(--region "$AWS_REGION")

# Server-side encryption
SSE_OPTS=(--sse AES256)
if [[ -n "$KMS_KEY_ALIAS" ]]; then
  SSE_OPTS=(--sse aws:kms --sse-kms-key-id "$KMS_KEY_ALIAS")
fi

put_one() {
  local src="$1" dst="$2"
  [[ -f "$src" ]] || {
    echo "❌ Not found: $src"
    exit 1
  }
  aws "${AWS_OPTS[@]}" s3 cp "$src" "$dst" --no-progress "${SSE_OPTS[@]}" --content-type text/plain
  echo "✅ Uploaded: $src → $dst"
}

get_one() {
  local dst="$1" src="$2"
  mkdir -p "$(dirname "$dst")"
  aws "${AWS_OPTS[@]}" s3 cp "$src" "$dst" --no-progress
  echo "✅ Downloaded: $src → $dst"
}

case "$CMD" in
put)
  put_one "$LOCAL_CONFIGS_LIVE" "$S3_CONFIGS_URI"
  # settings secret is optional locally; upload if present
  if [[ -f "$LOCAL_SETTINGS_SECRET" ]]; then
    put_one "$LOCAL_SETTINGS_SECRET" "$S3_SECRET_URI"
  else
    echo "ℹ️  Skipped (missing): $LOCAL_SETTINGS_SECRET"
  fi
  ;;
get)
  get_one "$LOCAL_CONFIGS_LIVE" "$S3_CONFIGS_URI"
  # download secret if it exists remotely
  if aws "${AWS_OPTS[@]}" s3 ls "$S3_SECRET_URI" >/dev/null 2>&1; then
    get_one "$LOCAL_SETTINGS_SECRET" "$S3_SECRET_URI"
  else
    echo "ℹ️  Skipped (not found in S3): $S3_SECRET_URI"
  fi
  ;;
-* | help | --help)
  usage
  exit 0
  ;;
*)
  echo "❌ Unknown command: $CMD"
  usage
  exit 2
  ;;
esac
