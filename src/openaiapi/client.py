"""Open AI API client module."""

from logging import getLogger

import openai

logger = getLogger(__name__)


class OpenAIClient:
    """Open AI API client class."""

    def __init__(self, client=None):
        """__init__ method.

        Args:
            client (optional): Open AI client
        """
        self.client = client or openai.OpenAI()

    def chat(self, content: str) -> str:
        """request to the OpenAI API.

        Args:
            content: send message

        Returns:
            response message
        """
        completions = (
            self.client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[{"role": "user", "content": content}],
            ),
        )

        logger.debug(completions)
        return completions[0].choices[0].message.content
