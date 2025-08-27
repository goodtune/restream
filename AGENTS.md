# AGENTS.md

## Project intent

Build and evolve a multi-language SDK for the Restream.io REST API and WebSocket APIs. This includes:

1. **Client Libraries**: Python (`pyrestream`) and Dart (`restream`) libraries for integrating Restream.io APIs into applications
2. **Command-Line Tools**: Python CLI (`restream.io`) for direct API interaction

Current implemented surface: OAuth2 login, profile retrieval, channel management, event management, stream key management, real-time streaming monitoring, real-time chat monitoring, and version reporting. All tools must be easily extensible with new endpoints, safe for local development, and automatable via AI agents.

## Project Structure

```
/
├── python/                      # Python client library
├── dart/                        # Dart client library  
│   └── example/
│       └── flutter_example/     # Flutter example app
├── cli/
│   └── python/                  # Python CLI tool (installs as restream.io)
└── docs/                        # API documentation
```

## Python Client Library (pyrestream)

### Location & Layout
- Package location: `python/`
- Source layout: `src/pyrestream/` to prevent accidental local imports
- Package name: `pyrestream` (installable via `pip install pyrestream`)

### Language & ecosystem
- **Python 3.11+**
- Use `uv` for dependency management: `uv sync`, `uv run pytest`
- Dynamic versioning via `setuptools_scm` from git tags

### Dependencies
- `requests` for HTTP interactions with session reuse
- `attrs` for data classes and schema definitions  
- `websockets` for real-time monitoring features
- `responses` + `pytest-asyncio` for testing

### Authentication
- OAuth2 Authorization Code flow
- Local redirect URI listener on `localhost` 
- CSRF protection via `state` parameter
- Secure token storage in `~/.config/restream.io/`
- WebSocket authentication via query parameter `?accessToken=token`

## Python CLI (restream.io)

### Location & Layout
- Package location: `cli/python/`
- Source layout: `src/restream_io_cli/`
- Package name: `restream.io` (installable via `pip install restream.io`)
- **Depends on `pyrestream` client library**

### CLI conventions
- Use `click` for rich CLI features
- Command hierarchy:
  - `restream.io platforms` - public API endpoint, no auth required
  - `restream.io servers` - public API endpoint, no auth required  
  - `restream.io login`
  - `restream.io profile`
  - `restream.io channel list|get|set`
  - `restream.io channel meta get|set`
  - `restream.io event list|get|history|in-progress|upcoming|stream-key`
  - `restream.io stream-key get`
  - `restream.io monitor streaming|chat [--duration <seconds>]`
  - `restream.io version`
- Support `--json` for machine-readable output
- Support verbosity flags (`-v`/`--verbose`) for debugging

## Dart Client Library (restream)

### Location & Layout
- Package location: `dart/`
- Package name: `restream` (publishable to pub.dev)
- Flutter example: `dart/example/flutter_example/`

### Language & ecosystem
- **Dart 3.9+**
- Follow Dart/Flutter conventions
- Use `dart test` for testing, `dart format` for formatting

## Real-time Monitoring (WebSocket APIs)

- **Streaming Monitor**: Connects to `wss://streaming.api.restream.io/ws`
- **Chat Monitor**: Connects to `wss://chat.api.restream.io/ws`  
- **Event Format**: `action`-based message format with structured payloads
- **Duration Support**: Optional `--duration` parameter
- **Error Handling**: Automatic reconnection with exponential backoff

## Error handling

- Wrap API errors into user-friendly messages
- Retry transient failures (network / 5xx) with exponential backoff
- Clear differentiation between authentication issues, not-found, and rate limits

## Testing

- All new functionality must be accompanied by tests
- Use `pytest` for Python, `dart test` for Dart
- Mock all external HTTP calls using `responses` (Python) or equivalent
- Cover positive, negative, and edge cases

## API Schema Development

- **Never trust documented response types** - validate actual API responses first
- **Always validate actual API responses** before creating schemas:
  1. Implement minimal API call to fetch real response data
  2. Examine actual JSON structure returned by the API
  3. Create schemas based on real response format
  4. Handle missing or additional fields gracefully
- Only implement features available to all plan types

## Style & quality

### Python
- Follow PEP 8; functions should be small and focused
- No global mutable state except where documented
- Docstrings required for public functions
- Avoid leaking secrets in logs; mask tokens if logged

### Dart  
- Follow Dart style guide and Flutter conventions
- Use `dart format` and `dart analyze`
- Proper error handling and null safety

## Extensibility

### Python
- New REST API endpoints: add to `pyrestream/api.py` 
- New WebSocket functionality: add to `pyrestream/websocket.py`
- Schema definitions: add to `pyrestream/schemas/` using `@attrs.define`
- CLI commands: add to `restream_io_cli/cli.py`

### Dart
- Follow similar patterns for API client and WebSocket functionality
- Use proper Dart conventions for schema definitions

## Security

- Do not commit client secrets or tokens to version control
- Prefer environment variables for volatile secrets in CI contexts
- Restrict file permissions on token storage

## Commit conventions

- Use imperative commit messages: "Add channel get command" not "Added"
- Update changelog when bumping versions

## Release

- Tag releases with `v` prefix (e.g., `v1.2.3`)
- Ensure CI fetches tags for `setuptools_scm` version computation

## Developer workflow

### Python
1. Add new functionality: extend client library + CLI + tests
2. Run linting: `uv run isort . && uv run ruff check . && uv run pymarkdown scan .`
3. Commit, tag, push

### Dart
1. Add new functionality following Dart conventions
2. Run formatting: `dart format .` and analysis: `dart analyze`
3. Run tests: `dart test`
4. Commit, tag, push

## Local development fallbacks

- If `importlib.metadata.version` fails, use `setuptools_scm.get_version` with `relative_to=__file__`
- Provide safe fallback of `0.0.0+unknown` on version detection failure

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
