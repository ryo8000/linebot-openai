"""Replier module."""

import json
import os
from logging import getLogger

from linebot import WebhookHandler
from linebot.models import MessageEvent, TextMessage

from linebotapi.client import LineBotClient
from openaiapi.client import OpenAIClient

logger = getLogger(__name__)
handler = WebhookHandler(os.environ["LINE_CHANNEL_SECRET"])


def lambda_handler(event: dict, context) -> dict:
    logger.debug(json.dumps(event))

    signature = event["headers"]["x-line-signature"]
    webhook_event = event["body"]
    handler.handle(webhook_event, signature)

    return {
        "statusCode": 200,
        "body": json.dumps("success")
    }


@handler.add(MessageEvent, message=TextMessage)
def handle_text_message(line_event: MessageEvent) -> None:
    logger.debug(line_event)

    response = OpenAIClient().chat(line_event.message.text)

    LineBotClient().reply_text_message(line_event.reply_token, response)
