# Defaults (can be overridden by args, .secret, or env)
LOCAL_FILE_DEFAULT="./ConfigsLive/Sources/ConfigsLive.swift"
S3_URI_DEFAULT="s3://fixsy-secrets/ConfigsLive.swift"

LOCAL_FILE="${1:-${LOCAL_FILE:-$LOCAL_FILE_DEFAULT}}"
S3_URI="${2:-${S3_URI:-$S3_URI_DEFAULT}}"

# Optional: encryption (choose one)
#   - leave KMS_KEY_ALIAS empty to use SSE-S3 (AES256)
#   - set KMS_KEY_ALIAS (e.g., alias/fixsy-secrets) for SSE-KMS
KMS_KEY_ALIAS="${KMS_KEY_ALIAS:-}"

if [[ -z "$LOCAL_FILE" || -z "$S3_URI" ]]; then
  echo "Usage: $0 [LOCAL_FILE] [S3_URI]" >&2
  exit 1
fi

[[ -f "$LOCAL_FILE" ]] || {
  echo "❌ Not found: $LOCAL_FILE" >&2
  exit 1
}

SSE_OPTS=(--sse AES256)
if [[ -n "$KMS_KEY_ALIAS" ]]; then
  SSE_OPTS=(--sse aws:kms --sse-kms-key-id "$KMS_KEY_ALIAS")
fi

# Optional: set a content-type for nicer reads in consoles/tools
CONTENT_TYPE_OPTS=(--content-type text/plain)

aws s3 cp "$LOCAL_FILE" "$S3_URI" \
  --no-progress \
  "${SSE_OPTS[@]}" \
  "${CONTENT_TYPE_OPTS[@]}"

echo "✅ Uploaded: $LOCAL_FILE → $S3_URI"
