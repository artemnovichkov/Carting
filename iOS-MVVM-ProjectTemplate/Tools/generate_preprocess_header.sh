#!/bin/sh

cd "$PROJECT_DIR"
COMMITS=`git rev-list HEAD --count`

echo "// Auto-generated" > "$ACK_ENV_PREPROCESS_HEADER"
echo "" >> "$ACK_ENV_PREPROCESS_HEADER"
echo "#define ACK_BUILD_NUMBER $COMMITS" >> "$ACK_ENV_PREPROCESS_HEADER"
cd -
