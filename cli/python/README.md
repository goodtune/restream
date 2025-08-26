# Restream.io CLI

Command-line interface for interacting with the Restream.io API.

## Installation

```bash
pip install restream.io
```

## Authentication

First, authenticate with your Restream.io account:

```bash
restream.io login
```

## Usage

### Profile Information
```bash
restream.io profile
```

### Channel Management
```bash
# List channels
restream.io channel list

# Get channel details
restream.io channel get <channel-id>

# Update channel
restream.io channel set <channel-id> --title "New Title" --enabled true
```

### Event Management
```bash
# List events
restream.io event list

# Get event details
restream.io event get <event-id>

# View historical events
restream.io event history --limit 10
```

### Real-time Monitoring
```bash
# Monitor streaming events
restream.io monitor streaming

# Monitor chat events  
restream.io monitor chat --duration 60
```

### JSON Output

Add `--json` to any command for machine-readable output:

```bash
restream.io profile --json
```

## Development

This CLI depends on the `pyrestream` client library.

For complete API documentation, see the [official Restream.io API docs](https://developers.restream.io/).