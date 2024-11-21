#!/bin/bash
set -e

# Start the build
BUILD_ID=$(aws codebuild start-build \
    --project-name build-rag-eval-build \
    --output json \
    | jq -r '.build.id')

echo "Build started with ID: $BUILD_ID"

# Optional: Wait and watch the build progress
aws codebuild batch-get-builds --ids "$BUILD_ID" \
    --query 'builds[0].buildStatus' \
    --output text

# Optional: Stream the logs
while true; do
    STATUS=$(aws codebuild batch-get-builds --ids "$BUILD_ID" \
        --query 'builds[0].buildStatus' \
        --output text)
    
    echo "Build status: $STATUS"
    
    if [ "$STATUS" != "IN_PROGRESS" ]; then
        break
    fi
    
    sleep 10
done

# Check final status
FINAL_STATUS=$(aws codebuild batch-get-builds --ids "$BUILD_ID" \
    --query 'builds[0].buildStatus' \
    --output text)

if [ "$FINAL_STATUS" != "SUCCEEDED" ]; then
    echo "Build failed with status: $FINAL_STATUS"
    exit 1
fi

echo "Build completed successfully"
