import asyncio
import json as json_lib
import sys
from importlib.metadata import version

import attrs
import click

from pyrestream import (
    RestreamClient,
    perform_login,
    APIError,
    AuthenticationError,
    ChatMonitorClient,
    StreamingMonitorClient,
)
from pyrestream.schemas import (
    Channel,
    ChannelMeta,
    ChannelSummary,
    ChatEvent,
    EventsHistoryResponse,
    Platform,
    Profile,
    Server,
    StreamEvent,
    StreamingEvent,
    StreamKey,
)


class RestreamCommand(click.Command):
    """Custom command class that adds common options and handles API errors."""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Add --json option to all commands
        self.params.append(
            click.Option(["--json"], is_flag=True, help="Output results in JSON format")
        )

    def invoke(self, ctx, *args, **kwargs):
        """Override invoke to handle common error patterns."""
        try:
            return super().invoke(ctx, *args, **kwargs)
        except APIError as e:
            _handle_api_error(e)
        except AuthenticationError as e:
            click.echo(f"Authentication error: {e}", err=True)
            click.echo("Please run 'restream.io login' first.", err=True)
            sys.exit(1)


def _attrs_to_dict(obj):
    """Convert attrs objects to dict for JSON serialization."""
    if attrs.has(obj):
        return attrs.asdict(obj)
    elif isinstance(obj, list):
        return [_attrs_to_dict(item) for item in obj]
    elif isinstance(obj, dict):
        return {key: _attrs_to_dict(value) for key, value in obj.items()}
    else:
        return obj


def _format_human_readable(data):
    """Format data for human-readable output."""
    if isinstance(
        data,
        (
            Profile,
            Channel,
            ChannelSummary,
            ChannelMeta,
            StreamEvent,
            EventsHistoryResponse,
            Platform,
            Server,
            StreamKey,
            StreamingEvent,
            ChatEvent,
        ),
    ):
        click.echo(str(data))
    elif (
        isinstance(data, list)
        and data
        and isinstance(
            data[0],
            (StreamEvent, ChannelSummary, Platform, Server, StreamingEvent, ChatEvent),
        )
    ):
        # Handle lists of events or channel summaries
        for i, item in enumerate(data, 1):
            click.echo(f"{i}. {item}")
            if i < len(data):
                click.echo()
    else:
        # Fallback to JSON for other data types
        click.echo(json_lib.dumps(_attrs_to_dict(data), indent=2, default=str))


def _get_client():
    """Get a configured RestreamClient instance."""
    return RestreamClient.from_config()


def _handle_output(data, json_flag):
    """Handle output formatting based on --json flag."""
    if json_flag:
        click.echo(json_lib.dumps(_attrs_to_dict(data), indent=2, default=str))
    else:
        _format_human_readable(data)


def _handle_api_error(e):
    """Handle API errors with appropriate user messages."""
    if e.status_code == 401:
        click.echo(
            "Authentication failed. Please run 'restream.io login' first.", err=True
        )
    elif e.status_code == 404:
        click.echo("Resource not found.", err=True)
    elif e.status_code == 429:
        click.echo("Rate limit exceeded. Please try again later.", err=True)
    elif e.status_code >= 500:
        click.echo(f"Server error ({e.status_code}). Please try again later.", err=True)
    else:
        click.echo(f"API error: {e}", err=True)
    sys.exit(1)


@click.group(invoke_without_command=True)
@click.option("--version", is_flag=True, help="Show version and exit")
@click.pass_context
def main(ctx, version_flag):
    """Restream.io CLI - Interact with the Restream.io API."""
    if version_flag:
        try:
            cli_version = version("restream.io")
            click.echo(f"restream.io CLI {cli_version}")
        except Exception:
            click.echo("restream.io CLI (development version)")
        return

    if ctx.invoked_subcommand is None:
        click.echo(ctx.get_help())


# Login command
@main.command(cls=RestreamCommand)
@click.pass_context
def login(ctx, json):
    """Authenticate with Restream.io using OAuth2."""
    try:
        tokens = perform_login()
        if json:
            click.echo(
                json_lib.dumps({"status": "success", "message": "Login successful"})
            )
        else:
            click.echo("Login successful!")
    except Exception as e:
        if json:
            click.echo(json_lib.dumps({"status": "error", "message": str(e)}))
        else:
            click.echo(f"Login failed: {e}", err=True)
        sys.exit(1)


# Profile command
@main.command(cls=RestreamCommand)
@click.pass_context
def profile(ctx, json):
    """Get user profile information."""
    client = _get_client()
    profile_data = client.get_profile()
    _handle_output(profile_data, json)


# Platforms command
@main.command(cls=RestreamCommand)
@click.pass_context
def platforms(ctx, json):
    """List available streaming platforms."""
    client = _get_client()
    platforms_data = client.list_platforms()
    _handle_output(platforms_data, json)


# Servers command
@main.command(cls=RestreamCommand)
@click.pass_context
def servers(ctx, json):
    """List available streaming servers."""
    client = _get_client()
    servers_data = client.list_servers()
    _handle_output(servers_data, json)


# Channel group
@main.group()
def channel():
    """Channel management commands."""
    pass


@channel.command("list", cls=RestreamCommand)
@click.pass_context
def channel_list(ctx, json):
    """List all channels."""
    client = _get_client()
    channels = client.list_channels()
    _handle_output(channels, json)


@channel.command("get", cls=RestreamCommand)
@click.argument("channel_id")
@click.pass_context
def channel_get(ctx, channel_id, json):
    """Get channel details by ID."""
    client = _get_client()
    channel_data = client.get_channel(channel_id)
    _handle_output(channel_data, json)


@channel.command("set", cls=RestreamCommand)
@click.argument("channel_id")
@click.option("--title", help="Channel title")
@click.option("--enabled", type=bool, help="Enable/disable channel")
@click.pass_context
def channel_set(ctx, channel_id, title, enabled, json):
    """Update channel settings."""
    client = _get_client()
    updates = {}
    if title is not None:
        updates["title"] = title
    if enabled is not None:
        updates["enabled"] = enabled

    if not updates:
        click.echo("No updates specified", err=True)
        sys.exit(1)

    updated_channel = client.update_channel(channel_id, **updates)
    _handle_output(updated_channel, json)


# Channel meta group
@channel.group("meta")
def channel_meta():
    """Channel metadata commands."""
    pass


@channel_meta.command("get", cls=RestreamCommand)
@click.pass_context
def channel_meta_get(ctx, json):
    """Get channel metadata."""
    client = _get_client()
    meta = client.get_channel_meta()
    _handle_output(meta, json)


@channel_meta.command("set", cls=RestreamCommand)
@click.option("--title", help="Stream title")
@click.option("--description", help="Stream description")
@click.option("--game", help="Game/category")
@click.pass_context
def channel_meta_set(ctx, title, description, game, json):
    """Update channel metadata."""
    client = _get_client()
    updates = {}
    if title is not None:
        updates["title"] = title
    if description is not None:
        updates["description"] = description
    if game is not None:
        updates["game"] = game

    if not updates:
        click.echo("No updates specified", err=True)
        sys.exit(1)

    updated_meta = client.update_channel_meta(**updates)
    _handle_output(updated_meta, json)


# Event group
@main.group()
def event():
    """Event management commands."""
    pass


@event.command("list", cls=RestreamCommand)
@click.pass_context
def event_list(ctx, json):
    """List all events."""
    client = _get_client()
    events = client.list_events()
    _handle_output(events, json)


@event.command("get", cls=RestreamCommand)
@click.argument("event_id")
@click.pass_context
def event_get(ctx, event_id, json):
    """Get event details by ID."""
    client = _get_client()
    event_data = client.get_event(event_id)
    _handle_output(event_data, json)


@event.command("history", cls=RestreamCommand)
@click.option(
    "--limit", type=int, default=10, help="Number of historical events to retrieve"
)
@click.pass_context
def event_history(ctx, limit, json):
    """Get historical events."""
    client = _get_client()
    history = client.get_events_history(limit=limit)
    _handle_output(history, json)


@event.command("in-progress", cls=RestreamCommand)
@click.pass_context
def event_in_progress(ctx, json):
    """Get currently in-progress events."""
    client = _get_client()
    events = client.get_in_progress_events()
    _handle_output(events, json)


@event.command("upcoming", cls=RestreamCommand)
@click.pass_context
def event_upcoming(ctx, json):
    """Get upcoming events."""
    client = _get_client()
    events = client.get_upcoming_events()
    _handle_output(events, json)


@event.command("stream-key", cls=RestreamCommand)
@click.argument("event_id")
@click.pass_context
def event_stream_key(ctx, event_id, json):
    """Get stream key for event."""
    client = _get_client()
    stream_key = client.get_event_stream_key(event_id)
    _handle_output(stream_key, json)


# Stream key group
@main.group("stream-key")
def stream_key():
    """Stream key management commands."""
    pass


@stream_key.command("get", cls=RestreamCommand)
@click.pass_context
def stream_key_get(ctx, json):
    """Get the current stream key."""
    client = _get_client()
    key = client.get_stream_key()
    _handle_output(key, json)


# Monitor group
@main.group()
def monitor():
    """Real-time monitoring commands."""
    pass


@monitor.command("streaming", cls=RestreamCommand)
@click.option("--duration", type=int, help="Duration to monitor in seconds")
@click.pass_context
def monitor_streaming(ctx, duration, json):
    """Monitor real-time streaming events via WebSocket."""

    async def run_monitor():
        monitor_client = StreamingMonitorClient()
        try:
            count = 0
            async for event in monitor_client.monitor(duration=duration):
                count += 1
                if json:
                    click.echo(json_lib.dumps(_attrs_to_dict(event), default=str))
                else:
                    click.echo(f"[{count}] {event}")
        except KeyboardInterrupt:
            if not json:
                click.echo("\nMonitoring stopped.")
        finally:
            await monitor_client.close()

    asyncio.run(run_monitor())


@monitor.command("chat", cls=RestreamCommand)
@click.option("--duration", type=int, help="Duration to monitor in seconds")
@click.pass_context
def monitor_chat(ctx, duration, json):
    """Monitor real-time chat events via WebSocket."""

    async def run_monitor():
        monitor_client = ChatMonitorClient()
        try:
            count = 0
            async for event in monitor_client.monitor(duration=duration):
                count += 1
                if json:
                    click.echo(json_lib.dumps(_attrs_to_dict(event), default=str))
                else:
                    click.echo(f"[{count}] {event}")
        except KeyboardInterrupt:
            if not json:
                click.echo("\nMonitoring stopped.")
        finally:
            await monitor_client.close()

    asyncio.run(run_monitor())


# Version command
@main.command(cls=RestreamCommand)
@click.pass_context
def version_cmd(ctx, json):
    """Show version information."""
    try:
        cli_version = version("restream.io")
    except Exception:
        cli_version = "development"

    try:
        lib_version = version("pyrestream")
    except Exception:
        lib_version = "development"

    if json:
        click.echo(
            json_lib.dumps({"cli_version": cli_version, "library_version": lib_version})
        )
    else:
        click.echo(f"restream.io CLI: {cli_version}")
        click.echo(f"pyrestream library: {lib_version}")


if __name__ == "__main__":
    main()
