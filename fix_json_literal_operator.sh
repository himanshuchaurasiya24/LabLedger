#!/bin/bash

JSON_HEADER="./linux/flutter/ephemeral/.plugin_symlinks/flutter_secure_storage_linux/linux/include/json.hpp"

if [ ! -f "$JSON_HEADER" ]; then
    echo "❌ json.hpp not found at $JSON_HEADER"
    exit 1
fi

echo "🔧 Patching deprecated literal operators in: $JSON_HEADER"

sed -i 's/operator "" _json/operator""_json/g' "$JSON_HEADER"
sed -i 's/operator "" _json_pointer/operator""_json_pointer/g' "$JSON_HEADER"

echo "✅ Patch applied successfully."
