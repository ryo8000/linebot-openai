"""LINE Bot API hadler module."""

import os
from logging import getLogger

from linebot import WebhookHandler
from linebot.models import MessageEvent, TextMessage

from linebotapi.client import LineBotClient

handler = WebhookHandler(os.environ["LINE_CHANNEL_SECRET"])
logger = getLogger(__name__)


def handle(event: dict):
    signature = event["headers"]["x-line-signature"]
    webhook_event = event["body"]

    handler.handle(webhook_event, signature)


@handler.add(MessageEvent, message=TextMessage)
def handle_text_message(line_event: MessageEvent) -> None:
    LineBotClient().reply_text_message(line_event.reply_token, "hey")
