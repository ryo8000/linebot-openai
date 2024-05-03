"""Replier module."""

import json
from logging import getLogger

from linebotapi import handler
from openaiapi.client import OpenAIClient

logger = getLogger(__name__)


def lambda_handler(event: dict, context) -> dict:
    # logger.debug(json.dumps(event))

    client = OpenAIClient()

    return main(event, client)


def main(event: dict, client: OpenAIClient) -> dict:
    handler.handle(event)

    # response = client.chat("hey")
    # logger.info(response)

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
