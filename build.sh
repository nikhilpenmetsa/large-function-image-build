#!/bin/bash

# Get stack outputs
stack_name="rag-eval-stack"
codebuild_project=$(aws cloudformation describe-stacks \
    --stack-name $stack_name \
    --query 'Stacks[0].Outputs[?OutputKey==`CodeBuildProjectName`].OutputValue' \
    --output text)

# Start build
build_id=$(aws codebuild start-build \
    --project-name $codebuild_project \
    --output text \
    --query 'build.id')

echo "Build started with ID: $build_id"

# Wait for build to complete
aws codebuild wait build-completion --id $build_id

# Get build status
build_status=$(aws codebuild batch-get-builds \
    --ids $build_id \
    --query 'builds[0].buildStatus' \
    --output text)

echo "Build completed with status: $build_status"