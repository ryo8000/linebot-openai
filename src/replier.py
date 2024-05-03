"""Replier module."""

import json
from logging import getLogger

from openaiapi.client import OpenAIClient

logger = getLogger(__name__)


def lambda_handler(event: dict, context):
    logger.debug(json.dumps(event))

    client = OpenAIClient()

    main(event, client)


def main(event: dict, client: OpenAIClient):
    response = client.chat("hey")
    logger.info(response)
