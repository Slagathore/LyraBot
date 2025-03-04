from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher

# Import your integration function
from lyra.openai_integration import get_openai_response

class ActionOpenAIChat(Action):
    def name(self) -> Text:
        return "action_openai_chat"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any]
    ) -> List[Dict[Text, Any]]:
        # Extract user message
        user_message = tracker.latest_message.get("text")
        if not user_message:
            user_message = "Hello there!"

        # Call your OpenAI integration
        response = get_openai_response(
            prompt=user_message,
            model="chatgpt-4o-latest",  # Or any valid model you have
            max_tokens=150,
            temperature=0.7
        )

        # Send the response back to the user
        if response:
            dispatcher.utter_message(text=response)
        else:
            dispatcher.utter_message(text="I'm sorry, I couldn't process your request.")

        return []
