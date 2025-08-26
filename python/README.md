# PyRestream

Python client library for the Restream.io REST API and WebSocket APIs.

## Installation

```bash
pip install pyrestream
```

## Basic Usage

```python
from pyrestream import RestreamClient

# Initialize client with token
client = RestreamClient.from_config()

# Get user profile
profile = client.get_profile()
print(f"Hello, {profile.displayName}!")

# List channels
channels = client.list_channels()
for channel in channels:
    print(f"Channel: {channel.title}")
```

## Authentication

The client supports OAuth2 authentication flow:

```python
from pyrestream import perform_login

# Perform OAuth2 login flow
tokens = perform_login()
```

## WebSocket Monitoring

Monitor real-time streaming and chat events:

```python
import asyncio
from pyrestream import StreamingMonitorClient, ChatMonitorClient

async def monitor_streaming():
    client = StreamingMonitorClient()
    async for event in client.monitor():
        print(f"Streaming event: {event}")

# Run monitoring
asyncio.run(monitor_streaming())
```

## Documentation

For complete API documentation, see the [official Restream.io API docs](https://developers.restream.io/).