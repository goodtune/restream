"""Private schemas for CLI internal use only.

These schemas are not part of the public API and may change without notice.
They exist solely to support CLI formatting and display needs.
"""

import attrs
from pyrestream.schemas import Channel


@attrs.define
class ChannelWithMeta(Channel):
    """Extended Channel with metadata fields for CLI display.
    
    Inherits from Channel and adds the metadata fields from ChannelMeta.
    """
    # Additional metadata fields from ChannelMeta
    title: str
    description: str
    
    def __str__(self):
        """Format for human-readable output."""
        return (
            f"Channel Information:\n"
            f"  ID: {self.id}\n"
            f"  Display Name: {self.display_name}\n"
            f"  Title: {self.title}\n"
            f"  Description: {self.description}\n"
            f"  Status: {'Active' if self.active else 'Inactive'}\n"
            f"  Channel URL: {self.channel_url}\n"
            f"  Channel Identifier: {self.channel_identifier}\n"
            f"  Service ID: {self.service_id}\n"
            f"  User ID: {self.user_id}"
        )