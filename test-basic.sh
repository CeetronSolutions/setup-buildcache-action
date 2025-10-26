#!/bin/bash

# Basic local validation script for setup-buildcache-action
# Tests syntax, structure, and logic without requiring external dependencies

set -e

echo "🧪 Running basic validation tests for setup-buildcache-action"
echo "============================================================="

# Test 1: Check required files exist
echo "📋 Test 1: Checking required files..."
REQUIRED_FILES=("action.yml" "README.md" "CLAUDE.md" ".github/workflows/test.yml")
for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file exists"
    else
        echo "❌ $file is missing"
        exit 1
    fi
done

# Test 2: Validate action.yml structure
echo "📋 Test 2: Validating action.yml structure..."
if grep -q "name:" action.yml && \
   grep -q "description:" action.yml && \
   grep -q "inputs:" action.yml && \
   grep -q "runs:" action.yml; then
    echo "✅ action.yml has required sections"
else
    echo "❌ action.yml is missing required sections"
    exit 1
fi

# Test 3: Check for security best practices
echo "📋 Test 3: Checking security best practices..."
if grep -q "https://" action.yml && \
   ! grep -q "http[^s]://" action.yml; then
    echo "✅ Using HTTPS for downloads"
else
    echo "❌ Not using HTTPS for all downloads"
    exit 1
fi

# Test 4: Validate version format regex logic
echo "📋 Test 4: Testing version format validation..."
VERSION_REGEX='^v[0-9]+\.[0-9]+\.[0-9]+$'
TEST_VERSIONS=("v0.31.5" "v0.30.0" "v0.28.5" "v1.0.0")
INVALID_VERSIONS=("0.31.5" "v0.31" "invalid" "v0.31.5.1")

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

# Test 5: Test URL format logic
echo "📋 Test 5: Testing URL format logic..."

test_url_logic() {
    local version=$1
    local expected_format=$2
    
    # Extract version numbers
    VERSION_NUM=${version#v}
    MAJOR=$(echo $VERSION_NUM | cut -d. -f1)
    MINOR=$(echo $VERSION_NUM | cut -d. -f2)
    PATCH=$(echo $VERSION_NUM | cut -d. -f3)
    
    # Apply same logic as action.yml
    if [[ $MAJOR -eq 0 && $MINOR -lt 30 ]]; then
        actual_format="package_registry"
    elif [[ $MAJOR -gt 0 ]] || [[ $MAJOR -eq 0 && $MINOR -gt 31 ]] || [[ $MAJOR -eq 0 && $MINOR -eq 31 && $PATCH -ge 4 ]]; then
        actual_format="new"
    else
        actual_format="legacy"
    fi
    
    if [[ "$actual_format" == "$expected_format" ]]; then
        echo "✅ $version correctly uses $expected_format format"
    else
        echo "❌ $version should use $expected_format format but got $actual_format"
        exit 1
    fi
}

# Test URL format detection
test_url_logic "v0.31.5" "new"
test_url_logic "v0.31.4" "new"
test_url_logic "v0.31.3" "legacy"
test_url_logic "v0.30.0" "legacy"
test_url_logic "v0.28.5" "package_registry"
test_url_logic "v1.0.0" "new"

# Test 6: Check test workflow syntax
echo "📋 Test 6: Validating test workflow structure..."
if grep -q "name: Test setup-buildcache-action" .github/workflows/test.yml && \
   grep -q "strategy:" .github/workflows/test.yml && \
   grep -q "matrix:" .github/workflows/test.yml; then
    echo "✅ test.yml has required workflow structure"
else
    echo "❌ test.yml missing required workflow structure"
    exit 1
fi

# Test 7: Check for version compatibility in tests
echo "📋 Test 7: Checking test version coverage..."
if grep -q "v0.31.5" .github/workflows/test.yml && \
   grep -q "v0.31.3" .github/workflows/test.yml && \
   grep -q "v0.28.5" .github/workflows/test.yml; then
    echo "✅ Test workflow covers multiple buildcache versions"
else
    echo "❌ Test workflow missing version coverage"
    exit 1
fi

# Test 8: Validate documentation completeness
echo "📋 Test 8: Checking documentation completeness..."
if grep -q "## Usage" README.md && \
   grep -q "## Inputs" README.md && \
   grep -q "## Testing" README.md; then
    echo "✅ README.md has required documentation sections"
else
    echo "❌ README.md missing required documentation"
    exit 1
fi

# Test 9: Check CLAUDE.md for development context
echo "📋 Test 9: Validating CLAUDE.md context..."
if grep -q "## Project Overview" CLAUDE.md && \
   grep -q "## Commit Guidelines" CLAUDE.md && \
   grep -q "buildcache" CLAUDE.md; then
    echo "✅ CLAUDE.md has required context sections"
else
    echo "❌ CLAUDE.md missing required context"
    exit 1
fi

# Test 10: Validate archive extraction and PATH logic
echo "📋 Test 10: Validating archive extraction and PATH logic..."

# Check Linux dependency installation
if grep -q "apt-get.*libssl" action.yml; then
    echo "✅ Linux installs required dependencies"
else
    echo "❌ Linux dependency installation missing"
    exit 1
fi

# Check Linux extraction to dedicated directory
if grep -q "tar -xzf buildcache.tar.gz -C" action.yml; then
    echo "✅ Linux extracts to dedicated directory"
else
    echo "❌ Linux extraction command incorrect"
    exit 1
fi

# Check Linux PATH setup
if grep -q 'echo.*GITHUB_PATH' action.yml && \
   grep -q 'export PATH.*BINARY_PATH' action.yml; then
    echo "✅ Linux sets up PATH correctly"
else
    echo "❌ Linux PATH setup missing"
    exit 1
fi

# Check Windows extraction to dedicated directory
if grep -q "Expand-Archive.*-DestinationPath.*InstallDir" action.yml; then
    echo "✅ Windows extracts to dedicated directory"
else
    echo "❌ Windows extraction destination incorrect"
    exit 1
fi

# Check Windows PATH setup
if grep -q 'Out-File.*GITHUB_PATH' action.yml && \
   grep -q 'env:PATH.*BinaryPath' action.yml; then
    echo "✅ Windows sets up PATH correctly"
else
    echo "❌ Windows PATH setup missing"
    exit 1
fi

# Check flexible binary detection for both platforms
if grep -q 'find.*buildcache.*executable' action.yml && \
   grep -q 'Get-ChildItem.*buildcache.exe' action.yml; then
    echo "✅ Both platforms use flexible binary detection"
else
    echo "❌ Flexible binary detection missing"
    exit 1
fi

# Check for debugging output
if grep -q "Extracted archive contents" action.yml; then
    echo "✅ Both platforms have debugging output"
else
    echo "❌ Debugging output missing"
    exit 1
fi

# Check no file copying (should not have mv/Move-Item to system locations)
if ! grep -q "sudo mv.*buildcache.*/usr/local/bin" action.yml && \
   ! grep -q "Move-Item.*buildcache.*C:" action.yml; then
    echo "✅ No file copying to system locations"
else
    echo "❌ Still copying files to system locations"
    exit 1
fi

echo ""
echo "🎉 All basic validation tests passed!"
echo ""
echo "📚 Local validation covers:"
echo "   - File structure and completeness"
echo "   - action.yml syntax and security"
echo "   - Version format validation logic"
echo "   - URL format detection logic"
echo "   - Flexible binary detection and PATH setup"
echo "   - Archive extraction with debugging output"
echo "   - Test workflow structure"
echo "   - Documentation completeness"
echo ""
echo "💡 For full testing, push to GitHub to run the complete test suite"
echo "   git push origin develop"