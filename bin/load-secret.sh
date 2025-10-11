LOCAL_FILE_DEFAULT="./ConfigsLive/Sources/ConfigsLive.swift"
S3_URI_DEFAULT="s3://fixsy-secrets/ConfigsLive.swift"

LOCAL_FILE="${1:-${LOCAL_FILE:-$LOCAL_FILE_DEFAULT}}"
S3_URI="${2:-${S3_URI:-$S3_URI_DEFAULT}}"

if [[ -z "$S3_URI" || -z "$LOCAL_FILE" ]]; then
  echo "Usage: $0 [S3_URI] [LOCAL_FILE]" >&2
  exit 1
fi

mkdir -p "$(dirname "$LOCAL_FILE")"

aws s3 cp "$S3_URI" "$LOCAL_FILE"

echo "✅ Downloaded: $S3_URI → $LOCAL_FILE"
