#!/bin/bash

# Path to the json.hpp file (now confirmed)
JSON_HPP="./linux/flutter/ephemeral/.plugin_symlinks/flutter_secure_storage_linux/linux/include/json.hpp"

# Check existence
if [[ ! -f "$JSON_HPP" ]]; then
  echo "❌ File not found: $JSON_HPP"
  exit 1
fi

# Backup
cp "$JSON_HPP" "${JSON_HPP}.bak"
echo "✅ Backup created: ${JSON_HPP}.bak"

# Apply fix using sed
sed -i -E 's/operator\s+""\s+_json\b/operator ""_json/g' "$JSON_HPP"
sed -i -E 's/operator\s+""\s+_json_pointer\b/operator ""_json_pointer/g' "$JSON_HPP"

echo "✅ Fixed deprecated literal operators in: $JSON_HPP"