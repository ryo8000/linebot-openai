"""LINE Bot API client module."""

import os
from logging import getLogger

from linebot import LineBotApi
from linebot.models import TextSendMessage

logger = getLogger(__name__)


class LineBotClient:
    """LINE Bot API client class."""

    def __init__(self, client=None):
        """__init__ method.

        Args:
            client (optional): LINE Bot client
        """
        self.client = client or LineBotApi(os.environ["LINE_CHANNEL_ACCESS_TOKEN"])

    def reply_text_message(self, reply_token: str, message: str) -> None:
        """reply text message.

        Args:
            reply_token: reply token
            message: reply message
        """
        self.client.reply_message(reply_token, TextSendMessage(text=message))
