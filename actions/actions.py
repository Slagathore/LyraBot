from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from lyra.openai_integration import get_openai_response
from lyra.combined_memory_manager import CombinedMemoryManager


class ActionLogConversation(Action):
    def name(self) -> Text:
        return "action_log_conversation"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any]
    ) -> List[Dict[Text, Any]]:
        # Log the conversation to a file or database
        user_message = tracker.latest_message.get("text", "")
        bot_response = "Your response logic here"  # Replace with actual bot response logic

        # Example: Log to a file
        with open("conversation_log.txt", "a") as f:
            f.write(f"User: {user_message}\n")
            f.write(f"Bot: {bot_response}\n\n")

        dispatcher.utter_message(text="Conversation logged successfully!")
        return []


class ActionOpenAIChat(Action):
    def name(self) -> Text:
        return "action_openai_chat"

    def __init__(self) -> None:
        super().__init__()
        self.memory_manager = CombinedMemoryManager()

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any]
    ) -> List[Dict[Text, Any]]:
        user_message = tracker.latest_message.get("text", "")
        if not user_message:
            dispatcher.utter_message(text="I didn't catch that. Could you please repeat?")
            return []

        # Retrieve context for the current query (e.g., top 3 similar past turns)
        context_entries = self.memory_manager.get_context(user_message, k=3)
        # Format context as a single string to prepend to the prompt
        if not context_entries:
            enriched_prompt = f"User: {user_message}\nBot:"
        else:
            context_str = "\n".join(
                [f"User: {entry.get('user', 'N/A')}\nBot: {entry.get('bot', 'N/A')}" for entry in context_entries]
            )
            enriched_prompt = f"Context:\n{context_str}\n\nUser: {user_message}\nBot:"

        # Generate a response using the enriched prompt
        try:
            response = get_openai_response(enriched_prompt, model="chatgpt-4o-latest")
        except Exception as e:
            print(f"OpenAI API error: {e}")
            dispatcher.utter_message(text="Sorry, I'm having trouble connecting to OpenAI. Please try again later.")
            return []

        if response and response.strip():
            dispatcher.utter_message(text=response)
        else:
            dispatcher.utter_message(text="Sorry, I couldn't generate a response. Please try again.")

        # Log the conversation turn with the original user message and bot response
        self.memory_manager.add_memory(user_message, response or "")
        
        # For debugging, print the retrieved context
        print("Retrieved context:", context_entries)
        print(f"User message: {user_message}")
        print(f"Enriched prompt: {enriched_prompt}")
        print(f"OpenAI response: {response}")

        return []