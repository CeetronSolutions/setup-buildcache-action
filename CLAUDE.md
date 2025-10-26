# Claude Context: setup-buildcache-action

This is a GitHub Action that installs [buildcache](https://gitlab.com/bits-n-bites/buildcache) and adds it to PATH for both Linux and Windows runners.

## Project Overview

**Purpose**: Automated installation of buildcache (a compilation caching tool) in GitHub Actions workflows
**Platforms**: Linux (Ubuntu) and Windows
**Language**: GitHub Actions YAML with Bash and PowerShell scripts

## Key Architecture

### Download URL Handling
The action intelligently handles different download URL formats based on buildcache version:

**Linux:**
- **v0.31.4+**: Uses `buildcache-linux-amd64.tar.gz` 
- **≤v0.31.3**: Uses `buildcache-linux.tar.gz`

**Windows:**
- **All versions**: Uses `buildcache-windows.zip`

### Version Support
- **No minimum version requirement** - supports any valid semantic version
- **Smart URL detection** based on version comparison
- **Comprehensive error handling** for download failures and invalid versions

## File Structure

```
├── action.yml              # Main GitHub Action definition
├── README.md               # Documentation and usage examples
├── example-workflow.yml    # Example usage workflows
├── .github/workflows/
│   └── test.yml           # Comprehensive test suite
└── CLAUDE.md              # This file
```

## Testing Strategy

### Test Coverage
- **Cross-platform**: Ubuntu and Windows runners
- **Version compatibility**: Tests v0.31.5, v0.31.3, v0.30.0, v0.28.5
- **URL format compatibility**: Both legacy and new download formats
- **Error handling**: Invalid versions, non-existent versions
- **Installation verification**: Path setup and binary functionality
- **Upgrade scenarios**: Installing multiple versions sequentially

### Test Matrix
- **Latest version installation** on Linux/Windows
- **Specific version installation** with multiple versions
- **Invalid version handling** with proper error messages
- **Installation path verification** for both platforms
- **Multiple installations** (upgrade testing)
- **URL format compatibility** testing
- **GitLab API availability** testing

## Development Workflow

1. **Make changes** to action.yml or documentation
2. **Run local validation**: `./test-basic.sh`
3. **Push to GitHub** - triggers automated test suite
4. **Review test results** in Actions tab
5. **Manual testing** available via workflow dispatch
6. **Create PR** when ready for review

## Common Tasks

### Adding New Version Support
If buildcache changes URL formats again:
1. Update version comparison logic in Linux installation section
2. Add new URL format handling
3. Update tests to include new version
4. Update documentation

### Debugging Installation Issues
1. Check GitLab releases page for URL format changes
2. Verify version exists at expected download URL
3. Test with manual workflow dispatch
4. Check error messages in action logs

### Updating Tests
- Add new test versions to the matrix in `.github/workflows/test.yml`
- Update version format tests in URL compatibility section
- Ensure upgrade tests use appropriate version ranges

## Key Implementation Details

### Error Handling
- Download failures with clear error messages
- Invalid version format validation
- Missing binary detection after extraction
- Installation verification with version check

### Cross-Platform Considerations
- Linux uses `sudo` for `/usr/local/bin` installation
- Windows uses `C:\buildcache` with PATH modification
- Different archive formats (tar.gz vs zip)
- Platform-specific shell syntax (bash vs PowerShell)

### Version Comparison Logic
```bash
VERSION_NUM=${VERSION#v}
MAJOR=$(echo $VERSION_NUM | cut -d. -f1)
MINOR=$(echo $VERSION_NUM | cut -d. -f2)
PATCH=$(echo $VERSION_NUM | cut -d. -f3)
```

Used to determine appropriate download URL format.

## Maintenance Notes

- **Monitor buildcache releases** for URL format changes
- **Test new versions** when buildcache updates
- **Keep documentation current** with supported versions
- **Review test matrix** periodically for relevance

## Development Context

This action was developed to support CeetronSolutions' build processes. It started in personal repo `magnesj/setup-buildcache-action` for development and testing before moving to the organization.

The action emphasizes reliability and comprehensive testing to ensure consistent buildcache installation across different CI environments and buildcache versions.

## Commit Guidelines

- **No AI attribution**: Do not include "Generated with Claude Code" or similar AI generation attribution in commit messages
- **No co-author lines**: Do not include "Co-Authored-By: Claude" in commit messages
- **Standard format**: Use conventional commit message format without AI-related additions