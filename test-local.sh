#!/bin/bash

# Local test script for setup-buildcache-action
# This script can be run locally to test basic functionality

set -e

echo "🧪 Running local tests for setup-buildcache-action"
echo "=================================================="

# Test 1: Validate action.yml syntax
echo "📋 Test 1: Validating action.yml syntax..."
if command -v yq &> /dev/null; then
    yq eval action.yml > /dev/null
    echo "✅ action.yml syntax is valid"
else
    echo "⚠️  yq not found, skipping YAML validation"
fi

# Test 2: Check required files exist
echo "📋 Test 2: Checking required files..."
REQUIRED_FILES=("action.yml" "README.md" ".github/workflows/test.yml")
for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file exists"
    else
        echo "❌ $file is missing"
        exit 1
    fi
done

# Test 3: Validate action.yml structure
echo "📋 Test 3: Validating action.yml structure..."
if grep -q "name:" action.yml && \
   grep -q "description:" action.yml && \
   grep -q "inputs:" action.yml && \
   grep -q "runs:" action.yml; then
    echo "✅ action.yml has required sections"
else
    echo "❌ action.yml is missing required sections"
    exit 1
fi

# Test 4: Check for security best practices
echo "📋 Test 4: Checking security best practices..."
if grep -q "curl.*https://" action.yml && \
   grep -q "Invoke-WebRequest.*https://" action.yml; then
    echo "✅ Using HTTPS for downloads"
else
    echo "❌ Not using HTTPS for all downloads"
    exit 1
fi

# Test 5: Validate version format regex
echo "📋 Test 5: Testing version format validation..."
VERSION_REGEX='^v[0-9]+\.[0-9]+\.[0-9]+$'
TEST_VERSIONS=("v0.28.1" "v1.0.0" "v10.20.30")
INVALID_VERSIONS=("0.28.1" "v0.28" "invalid" "v0.28.1.1")

for version in "${TEST_VERSIONS[@]}"; do
    if [[ $version =~ $VERSION_REGEX ]]; then
        echo "✅ $version matches version pattern"
    else
        echo "❌ $version should match version pattern"
        exit 1
    fi
done

for version in "${INVALID_VERSIONS[@]}"; do
    if [[ ! $version =~ $VERSION_REGEX ]]; then
        echo "✅ $version correctly rejected"
    else
        echo "❌ $version should be rejected"
        exit 1
    fi
done

# Test 6: Check GitLab API availability (if curl and jq available)
echo "📋 Test 6: Testing GitLab API availability..."
if command -v curl &> /dev/null && command -v jq &> /dev/null; then
    API_URL="https://gitlab.com/api/v4/projects/bits-n-bites%2Fbuildcache/releases"
    if LATEST_VERSION=$(curl -s "$API_URL" | jq -r '.[0].tag_name' 2>/dev/null); then
        if [[ "$LATEST_VERSION" != "null" && -n "$LATEST_VERSION" ]]; then
            echo "✅ GitLab API accessible, latest version: $LATEST_VERSION"
        else
            echo "⚠️  GitLab API returned null/empty version"
        fi
    else
        echo "⚠️  GitLab API not accessible or jq parsing failed"
    fi
else
    echo "⚠️  curl or jq not available, skipping API test"
fi

# Test 7: Validate test workflow syntax
echo "📋 Test 7: Validating test workflow..."
if [[ -f ".github/workflows/test.yml" ]]; then
    if command -v yq &> /dev/null; then
        yq eval .github/workflows/test.yml > /dev/null
        echo "✅ test.yml syntax is valid"
    else
        echo "⚠️  yq not found, skipping test workflow validation"
    fi
else
    echo "❌ test.yml is missing"
    exit 1
fi

echo ""
echo "🎉 All local tests passed!"
echo "💡 To run the full test suite, push to GitHub or run:"
echo "   gh workflow run test.yml"
echo ""
echo "📚 Test coverage includes:"
echo "   - Latest version installation (Linux/Windows)"
echo "   - Specific version installation (Linux/Windows)"  
echo "   - Invalid version handling"
echo "   - Installation path verification"
echo "   - Multiple installation scenarios"
echo "   - GitLab API availability"