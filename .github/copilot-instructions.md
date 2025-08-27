# Restream.io Multi-Language SDK

Multi-language SDKs and tools for the Restream.io REST API and WebSocket APIs, including Python client library (`pyrestream`), Python CLI (`restream.io`), and Dart library (`restream`) with Flutter example app.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Initial Setup and Dependencies
- Install uv (Python dependency manager): `curl -LsSf https://astral.sh/uv/install.sh | sh`
- Install Dart SDK 3.9.0: Download from `https://storage.googleapis.com/dart-archive/channels/stable/release/3.9.0/sdk/dartsdk-linux-x64-release.zip`
- Install Flutter 3.35.1: Download from `https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.35.1-stable.tar.xz`
- Add `$HOME/.local/bin`, `/opt/dart-sdk/bin`, and `/opt/flutter/bin` to PATH

### Python Client Library (pyrestream)
**Location**: `python/`

**Build and test workflow**:
```bash
cd python/
uv sync                    # ~1.4 seconds - NEVER CANCEL
uv run pytest            # ~2.2 seconds, 102 tests - NEVER CANCEL
uv build                  # ~3.7 seconds - NEVER CANCEL
```

**Validation**:
```bash
uv run python -c "from pyrestream import RestreamClient; print('Import successful')"
```

### Python CLI (restream.io)
**Location**: `cli/python/`
**Depends on**: pyrestream client library

**Build and test workflow**:
```bash
cd python/ && uv sync && uv build  # Build client library first
cd ../cli/python/
uv add ../../python/ --editable   # Add local pyrestream dependency
uv run pytest                     # ~1 second, 30 tests - NEVER CANCEL
```

**Validation**:
```bash
uv run restream.io --help
uv run restream.io version
uv run restream.io platforms      # Public endpoint - no auth required
uv run restream.io servers        # Public endpoint - no auth required
```

### Dart Library (restream)
**Location**: `dart/`

**Build and test workflow**:
```bash
cd dart/
dart pub get              # ~4.3 seconds - NEVER CANCEL
dart format --output=none --set-exit-if-changed .  # ~0.8 seconds
dart analyze --fatal-infos lib test               # ~1.3 seconds
dart test                 # ~5.4 seconds, 8 tests - NEVER CANCEL
dart run example/restream_example.dart            # ~1.6 seconds
```

### Flutter Example App
**Location**: `dart/examples/flutter_example/`

**Build and test workflow**:
```bash
cd dart/examples/flutter_example/
flutter pub get          # ~13 seconds - NEVER CANCEL
flutter analyze          # ~10.6 seconds - NEVER CANCEL
flutter build web --wasm --debug  # ~35 seconds - NEVER CANCEL, Set timeout to 60+ minutes
```

### Linting
**Python projects**:
```bash
cd python/ (or cli/python/)
uv run isort .            # ~0.2 seconds - fixes import order
uv run ruff check .       # ~0.02 seconds - code style/quality
uv run pymarkdown scan . # ~0.5 seconds - markdown validation
```

**Expected Successful Output**:
- Python tests: "102 passed" (client), "30 passed" (CLI)
- Dart tests: "8 tests passed"  
- Public API calls: "Found 57 platforms", "Found 22 servers"
- Dart example: "✅ Example completed!"
- CLI help: Lists commands including "platforms", "servers", "login", "profile"

**Dart projects**:
```bash
cd dart/
dart format .             # Auto-format code
dart analyze             # Static analysis
```

## Manual Testing Scenarios

### CRITICAL: Complete Developer Onboarding Test
**Test that a fresh developer can get the entire codebase working**:
```bash
# Start from fresh repository clone
export PATH="$HOME/.local/bin:$PATH"

# 1. Build and test Python client (should take ~5 seconds total)
cd python/
uv sync && uv run pytest && uv build

# 2. Build and test Python CLI (should take ~2 seconds total) 
cd ../cli/python/
uv add ../../python/ --editable && uv run pytest

# 3. Test public endpoints work
uv run python -c "
from pyrestream.api import RestreamClient
import requests
client = RestreamClient(requests.Session(), '', 'https://api.restream.io/v2')
platforms = client.get_platforms()
assert len(platforms) > 50, f'Expected 50+ platforms, got {len(platforms)}'
servers = client.get_servers()  
assert len(servers) > 20, f'Expected 20+ servers, got {len(servers)}'
print('✅ Public endpoints working correctly')
"

# 4. Build and test Dart library (should take ~15 seconds total)
cd ../../dart/
dart pub get && dart format . && dart analyze && dart test

# 5. Test Dart example runs (should take ~2 seconds)
dart run example/restream_example.dart | grep "✅ Example completed!"

# 6. Test Flutter example builds (should take ~45 seconds total)
cd examples/flutter_example/
flutter pub get && flutter analyze

echo "🎉 Complete developer onboarding test PASSED"
```

### CRITICAL: Test Public Endpoints
**Always verify these work without authentication**:
```bash
# Python CLI - public endpoints
cd cli/python/
uv run restream.io platforms     # Should list 57+ platforms
uv run restream.io servers       # Should list 22+ servers

# Python client library - direct API test
cd python/
uv run python -c "
from pyrestream.api import RestreamClient
import requests
client = RestreamClient(requests.Session(), '', 'https://api.restream.io/v2')
platforms = client.get_platforms()
print(f'Found {len(platforms)} platforms')
servers = client.get_servers()
print(f'Found {len(servers)} servers')
"
```

### CRITICAL: Test Example Applications
```bash
# Dart example - should demonstrate OAuth flow and API usage
cd dart/
dart run example/restream_example.dart  # Should complete without errors
```

### Build Timing Expectations
**NEVER CANCEL these operations - they may take longer than expected:**
- Python client sync: ~1.4 seconds (typical), timeout: 300 seconds
- Python client tests: ~2.2 seconds (typical), timeout: 300 seconds  
- Python client build: ~3.7 seconds (typical), timeout: 300 seconds
- CLI tests: ~1 second (typical), timeout: 300 seconds
- Dart pub get: ~4.3 seconds (typical), timeout: 300 seconds
- Dart tests: ~5.4 seconds (typical), timeout: 300 seconds
- Flutter pub get: ~13 seconds (typical), timeout: 600 seconds
- Flutter web build: ~35 seconds (typical), timeout: 3600 seconds

**CRITICAL TIMEOUT SETTINGS**:
- Set bash command timeouts to at least 2x the typical time
- For Flutter web builds, always use timeout of 60+ minutes (3600+ seconds)
- If any command appears to hang, wait the full timeout before canceling
- Build failures are usually immediate; hanging usually means it's still working

### Common Issues and Solutions

**CLI platforms/servers commands require authentication**:
- Known issue: CLI incorrectly uses authenticated client for public endpoints
- Additional issue: CLI calls `list_platforms()` but method is `get_platforms()`
- Workaround: Test public endpoints directly via Python client library
- These should work without authentication: `platforms`, `servers`

**Version conflicts in CLI installation**:
- Use editable install: `cd cli/python && uv add ../../python/ --editable`
- This resolves pyrestream dependency version mismatches

**Flutter formatting warnings**:
- Expected in examples/flutter_example - run `dart format .` to fix
- Analysis warnings about package resolution can be ignored

## Project Structure Reference

```
/
├── python/                      # Python client library (pyrestream)
│   ├── src/pyrestream/         # Source code
│   ├── tests/                  # 102 unit tests
│   └── pyproject.toml          # Uses uv for dependencies
├── cli/python/                 # Python CLI (restream.io)
│   ├── src/restream_io/        # CLI source code  
│   ├── tests/                  # 30 unit tests
│   └── pyproject.toml          # Depends on pyrestream
├── dart/                       # Dart library (restream)
│   ├── lib/                    # Library source code
│   ├── test/                   # 8 unit tests
│   ├── example/                # Dart example app
│   └── examples/flutter_example/  # Flutter example app
└── docs/                       # API documentation
```

## Authentication and Environment

**For local testing**:
- Public endpoints (platforms, servers) work without authentication
- Authenticated endpoints require OAuth2 flow with valid tokens
- Set environment variables for OAuth testing:
  ```bash
  export RESTREAM_CLIENT_ID="your_client_id"
  export RESTREAM_CLIENT_SECRET="your_client_secret"
  ```

**OAuth Flow**: 
- Python: Use `pyrestream.perform_login()` for interactive authentication
- Dart: Use `OAuthFlow` class with PKCE support for mobile apps
- CLI: Use `restream.io login` command

## Additional Validation Steps

**Always run before committing**:
```bash
# Python client library validation
cd python/
uv sync && uv run pytest && uv run isort . && uv run ruff check .

# Python CLI validation  
cd cli/python/
uv run pytest && uv run restream.io --help && uv run restream.io platforms

# Dart library validation
cd dart/
dart pub get && dart format . && dart analyze && dart test && dart run example/restream_example.dart

# Flutter example validation
cd dart/examples/flutter_example/
flutter pub get && flutter analyze
```

## API Endpoints Summary

**Public (no auth required)**:
- `GET /v2/platform/all` - List streaming platforms (57+ platforms)
- `GET /v2/server/all` - List ingest servers (22+ servers)

**Authenticated (OAuth2 required)**:
- `GET /v2/user/profile` - User profile information
- `GET /v2/user/channels` - User's streaming channels
- `GET /v2/user/events/*` - Stream events and history
- `GET /v2/user/stream-key` - Primary stream key
- WebSocket endpoints for real-time monitoring

**WebSocket APIs**:
- `wss://streaming.api.restream.io/ws` - Real-time streaming events
- `wss://chat.api.restream.io/ws` - Real-time chat monitoring
- Authentication via `?accessToken=token` query parameter

## Development Workflow

1. **Set up environment**: Install uv, Dart, Flutter
2. **Build all components**: Python client → Python CLI → Dart library → Flutter example
3. **Run comprehensive tests**: All test suites must pass (102 + 30 + 8 tests)
4. **Test public endpoints**: Verify platforms/servers work without auth
5. **Test example applications**: Dart example and Flutter build
6. **Run linting**: Python (isort, ruff, pymarkdown) and Dart (format, analyze)
7. **Validate end-to-end scenarios**: Complete user workflows

This codebase is stable and well-tested. Follow the exact commands and timing expectations above for reliable development.