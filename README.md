# Restream.io Multi-Language SDK

Unofficial multi-language SDKs and tools for the Restream.io API, including client libraries and command-line interfaces.

## Project Structure

```
/
├── README.md                    # This file
├── docs/                        # API documentation and guides
├── python/                      # Python client library
├── dart/                        # Dart client library
│   └── examples/
│       └── flutter_example/     # Flutter example app
└── cli/
    └── python/                  # Python CLI tool (installs as restream.io)
```

## Client Libraries

### Python - pyrestream

A Python client library for the Restream.io REST API and WebSocket APIs.

**Installation:**
```bash
pip install pyrestream
```

**Usage:**
```python
from pyrestream import RestreamClient

client = RestreamClient.from_config()
profile = client.get_profile()
print(f"Hello, {profile.displayName}!")
```

[📚 Python Library Documentation](python/README.md)

### Dart - restream

A Dart library for the Restream.io API, designed for Flutter and Dart applications.

**Installation:**
```yaml
dependencies:
  restream: ^0.1.0
```

**Usage:**
```dart
import 'package:restream/restream.dart';

final client = RestreamClient();
final profile = await client.getProfile();
print('Hello, ${profile.displayName}!');
```

[📚 Dart Library Documentation](dart/README.md)

## Command-Line Tools

### Python CLI - restream.io

A command-line interface for interacting with the Restream.io API.

**Installation:**
```bash
pip install restream.io
```

**Usage:**
```bash
# Authenticate
restream.io login

# Get profile
restream.io profile

# List channels
restream.io channel list

# Monitor live streaming
restream.io monitor streaming
```

[📚 CLI Documentation](cli/python/README.md)

## API Documentation

Comprehensive documentation for all Restream.io APIs is available in the `docs/` directory:

- [📖 API Reference](docs/developers.restream.io/README.md)
- [🚀 Getting Started Guide](docs/developers.restream.io/GUIDE.md)

## Authentication

All libraries and tools use OAuth2 authentication. You'll need:

- **Client ID**: OAuth2 client ID 
- **Client Secret**: OAuth2 client secret

Set these as environment variables:
```bash
export RESTREAM_CLIENT_ID="your_client_id_here"
export RESTREAM_CLIENT_SECRET="your_client_secret_here"
```

## Contributing

Each language implementation follows its own conventions:

### Python
- Uses `uv` for dependency management
- Follow PEP 8 style guidelines  
- Run tests with `uv run pytest`

### Dart
- Follow Dart/Flutter conventions
- Run tests with `dart test`
- Use `dart format` for formatting

## License

See individual package LICENSE files for details.

## Support

- 🐛 [Report Issues](https://github.com/goodtune/restream/issues)
- 📖 [API Documentation](https://developers.restream.io/)
- 💬 [Community Support](https://developers.restream.io/)