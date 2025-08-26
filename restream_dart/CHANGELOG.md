# Changelog

## [0.1.0] - 2025-08-26

### Added
- Complete Dart library implementation for Restream.io API
- OAuth2 authentication flow with PKCE support for mobile apps
- Full REST API coverage matching Python CLI functionality
- Real-time WebSocket monitoring for streaming and chat events
- Comprehensive data models with JSON serialization
- Type-safe error handling with custom exception hierarchy
- Configurable token storage (file-based and memory-based)
- Retry logic with exponential backoff for API requests
- Flutter example app demonstrating complete integration
- Comprehensive documentation and usage examples

### API Coverage
- User profiles (`Profile` model)
- Streaming platforms (`Platform`, `PlatformImage` models)
- Ingest servers (`Server` model)
- Channels and metadata (`Channel`, `ChannelMeta` models)
- Stream events (`StreamEvent`, `EventDestination` models)
- Stream keys (`StreamKey` model)
- Real-time monitoring (`StreamingMonitor`, `ChatMonitor`)

### Development Features
- 8 comprehensive unit tests covering core functionality
- JSON code generation with build_runner
- Proper Dart package structure following conventions
- Example Flutter app with OAuth flow and UI
- Android deep link configuration for OAuth callbacks

### Dependencies
- `http` ^1.2.2 - HTTP client for REST API calls
- `web_socket_channel` ^2.4.3 - WebSocket support
- `json_annotation` ^4.8.1 - JSON serialization annotations
- `crypto` ^3.0.3 - PKCE implementation
- Dev dependencies for testing and code generation
