# Setup buildcache GitHub Action

This GitHub Action installs [buildcache](https://gitlab.com/bits-n-bites/buildcache) and adds it to the PATH for both Windows and Linux runners.

## Features

- 🚀 Supports both Linux and Windows runners
- 🔧 Optional version specification (uses latest by default)
- ✅ Automatically adds buildcache to PATH
- 🧹 Cleans up temporary files after installation

## Usage

### Basic Usage (Latest Version)

```yaml
steps:
  - uses: actions/checkout@v4
  
  - name: Setup buildcache
    uses: CeetronSolutions/setup-buildcache-action@v1
  
  - name: Build your project
    run: |
      # Your build commands here
      # buildcache will be available in PATH
```

### Specify Version

```yaml
steps:
  - name: Setup buildcache
    uses: CeetronSolutions/setup-buildcache-action@v1
    with:
      version: v0.31.5
```

### Multi-Platform Build

```yaml
jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup buildcache
        uses: CeetronSolutions/setup-buildcache-action@v1
      
      - name: Configure buildcache
        run: |
          buildcache -s  # Show statistics
          buildcache -z  # Zero statistics
      
      - name: Build
        run: |
          # Your build commands
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `version` | buildcache version to install (e.g., `v0.31.5`, `v0.28.5`). If not specified, uses latest release. | No | `latest` |

## Supported Platforms

- ✅ Linux (ubuntu-latest, ubuntu-22.04, ubuntu-20.04)
- ✅ Windows (windows-latest, windows-2022, windows-2019)

## Download URL Compatibility

The action automatically handles different download URL formats based on the buildcache version:

**Linux:**
- **v0.31.4 and later**: Uses `buildcache-linux-amd64.tar.gz` format
- **v0.31.3 and earlier**: Uses `buildcache-linux.tar.gz` format

**Windows:**
- **All versions**: Uses `buildcache-windows.zip` format

This ensures compatibility across all buildcache versions without manual intervention. If a specific version fails to download, the action will provide clear error messages with links to check available releases.

## Installation Location

- **Linux**: `/usr/local/bin/buildcache`
- **Windows**: `C:\buildcache\buildcache.exe` (added to PATH)

## Using buildcache with CMake

After installing buildcache, you can use it with CMake by setting the compiler launcher:

```yaml
- name: Setup buildcache
  uses: CeetronSolutions/setup-buildcache-action@v1

- name: Configure CMake with buildcache
  run: |
    cmake -B build \
      -DCMAKE_CXX_COMPILER_LAUNCHER=buildcache \
      -DCMAKE_C_COMPILER_LAUNCHER=buildcache

- name: Build
  run: cmake --build build
```

## Cache Configuration

To persist buildcache between workflow runs, you can use GitHub's cache action:

```yaml
- name: Cache buildcache
  uses: actions/cache@v4
  with:
    path: |
      ~/.buildcache
    key: ${{ runner.os }}-buildcache-${{ github.sha }}
    restore-keys: |
      ${{ runner.os }}-buildcache-

- name: Setup buildcache
  uses: CeetronSolutions/setup-buildcache-action@v1

- name: Configure buildcache
  run: |
    buildcache -M 2G  # Set max cache size to 2GB
```

## Example Output

```
Getting latest buildcache release...
Latest version: v0.28.1
Installing buildcache v0.28.1 for Linux...
buildcache version 0.28.1
```

## Troubleshooting

### Version not found

If you specify a version that doesn't exist, the action will fail. Check the [releases page](https://gitlab.com/bits-n-bites/buildcache/-/releases) for available versions.

### Permission errors on Linux

The action uses `sudo` to install buildcache to `/usr/local/bin` on Linux. This should work on GitHub-hosted runners by default.

## Testing

This action includes comprehensive tests that run automatically on every push and pull request.

### Test Coverage

- ✅ **Latest version installation** - Tests installation using `latest` version on Linux and Windows
- ✅ **Specific version installation** - Tests installation of specific versions (e.g., `v0.31.5`)
- ✅ **Error handling** - Tests invalid version formats and non-existent versions
- ✅ **Cross-platform support** - Tests on both Ubuntu and Windows runners
- ✅ **Installation paths** - Verifies correct installation locations and permissions
- ✅ **Multiple installations** - Tests upgrade scenarios
- ✅ **URL format compatibility** - Tests both legacy (≤v0.31.3) and new (v0.31.4+) download URL formats
- ✅ **Version compatibility** - Tests with various buildcache versions including older releases
- ✅ **API availability** - Tests GitLab API accessibility and response format

### Running Tests

#### Automated Testing
Tests run automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` branch
- Manual workflow dispatch

#### Manual Testing
Test the action manually in a workflow:
```yaml
name: Manual Test
on: workflow_dispatch
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ./
      - run: buildcache --version
```

### Test Results

View test results in the [Actions tab](../../actions/workflows/test.yml) of this repository.

## Contributing

When making changes to this action:

1. Create a pull request
2. Ensure all automated tests pass
3. Test manually if needed using the manual test workflow above

## License

This action is provided as-is. buildcache itself is licensed under the GPLv3 license. See the [buildcache repository](https://gitlab.com/bits-n-bites/buildcache) for details.
