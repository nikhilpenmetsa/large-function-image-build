#!/bin/bash

# Deploy CloudFormation stack
stack_name="rag-eval-build-stack"
template_file="template.yaml"

# Check if stack exists
if aws cloudformation describe-stacks --stack-name $stack_name 2>/dev/null; then
    # Update existing stack
    echo "Updating existing stack..."
    aws cloudformation update-stack \
        --stack-name $stack_name \
        --template-body file://$template_file \
        --capabilities CAPABILITY_IAM
else
    # Create new stack
    echo "Creating new stack..."
    aws cloudformation create-stack \
        --stack-name $stack_name \
        --template-body file://$template_file \
        --capabilities CAPABILITY_IAM
fi

# Wait for stack creation/update to complete
echo "Waiting for stack operation to complete..."
aws cloudformation wait stack-update-complete --stack-name $stack_name || \
aws cloudformation wait stack-create-complete --stack-name $stack_name

# Get outputs
echo "Stack outputs:"
aws cloudformation describe-stacks \
    --stack-name $stack_name \
    --query 'Stacks[0].Outputs[*].{Key:OutputKey,Value:OutputValue}' \
    --output table