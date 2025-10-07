#!/bin/bash

if [[ -z "$1" ]]; then
  echo "Usage: $0 <FeatureName>"
  exit 1
fi

FEATURE_NAME="$1"
ROOT_DIR="${FEATURE_NAME}Feature"
SOURCE_FILE="${FEATURE_NAME}View.swift"

mkdir -p "$ROOT_DIR/Sources"

echo "// ${SOURCE_FILE} - Generated File" >"$ROOT_DIR/Sources/$SOURCE_FILE"

echo "Folder and file structure created successfully:"
echo "$ROOT_DIR/"
echo "  └── Sources/"
echo "      └── $SOURCE_FILE"
