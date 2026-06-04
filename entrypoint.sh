#!/bin/bash
set -e

echo "🚀 Starting Scale Secure API Testing..."

if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Error: Configuration file '$CONFIG_FILE' not found!"
  exit 1
fi

if [ -z "$SCALESECURE_API_KEY" ]; then
  echo "❌ Error: api-key input is required."
  exit 1
fi

echo "Sending configuration to Scale Secure..."
response=$(curl -s -w "\n%{http_code}" -X POST https://api.scalesecure.com/v1/ai-testing/run \
     -H "Content-Type: application/json" \
     -H "x-api-key: $SCALESECURE_API_KEY" \
     -d @"$CONFIG_FILE")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -ne 200 ]; then 
  echo "❌ Error from Scale Secure API: $body"
  exit 1
fi

failed_count=$(echo "$body" | jq '.summary.failed')

if [ "$failed_count" -gt 0 ]; then
  echo "❌ $failed_count Vulnerabilities found!"
  
  if [ -n "$GH_TOKEN" ] && [ -n "$PR_NUMBER" ]; then
    echo "### 🚨 Scale Secure API Testing: $failed_count Failures Found" > pr_comment.md
    echo "| Test Case | Expected | Actual | Reason |" >> pr_comment.md
    echo "|-----------|----------|--------|--------|" >> pr_comment.md
    
    echo "$body" | jq -r '.results[] | select(.status == "FAIL") | "| \(.name) | \(.expected) | \(.actual) | \(.fail_reason | gsub("\\\\|"; "-") | gsub("\\n"; " ")) |"' >> pr_comment.md
    
    echo "Posting comment to Pull Request #$PR_NUMBER..."
    gh pr comment "$PR_NUMBER" -F pr_comment.md || echo "⚠️ Failed to post PR comment. Ensure github-token has write permissions."
  else
    echo "ℹ️ GH_TOKEN or PR_NUMBER not provided (or not a PR event). Skipping PR comment."
  fi
  
  exit 1
fi

echo "✅ All tests passed! APIs are secure."
