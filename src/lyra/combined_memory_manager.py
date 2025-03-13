from lyra.memory.json_memory_manager import JSONMemoryManager
from lyra.memory.faiss_memory_manager import FAISSMemoryManager
from lyra.memory.sql_memory_manager import log_conversation
from lyra.langchain_integration import create_conversation_chain
from datetime import datetime
import numpy as np
from sentence_transformers import SentenceTransformer
from textblob import TextBlob  # For sentiment analysis
from typing import List, Optional

class CombinedMemoryManager:
    def __init__(self):
        self.json_manager = JSONMemoryManager(file_path="conversation_history.json")
        self.faiss_manager = FAISSMemoryManager(dim=384, index_file="faiss_index.bin")
        self.conversation_chain = create_conversation_chain()
        self.embedding_model = SentenceTransformer('all-MiniLM-L6-v2')  # or use OpenAI

    def add_memory(self, user_message: str, bot_response: str, tags: Optional[List[str]] = None, conversation_id: str = None):
        print(f"🛠 Adding memory: {user_message} -> {bot_response}")

        """
        Add a memory entry with user message, bot response, tags, and sentiment analysis.
        """
        # Analyze sentiment
        sentiment = TextBlob(user_message).sentiment

        entry = {
            "user": user_message,
            "bot": bot_response,
            "timestamp": datetime.now().isoformat(),
            "conversation_id": conversation_id,
            "tags": tags if tags else [],  # Add tags if provided
            "sentiment": {  # Add sentiment analysis
                "polarity": sentiment.polarity,  # Positive/negative score (-1 to 1)
                "subjectivity": sentiment.subjectivity  # Objective/subjective score (0 to 1)
            }
        }

        # ✅ Always log all conversations, not just tagged ones
        self.json_manager.add_memory(entry)

        # ✅ Log to SQL memory (if enabled)
        try:
            log_conversation(user_message, bot_response)
        except Exception as e:
            print("❌ SQL memory logging failed:", e)

        # ✅ Log to FAISS memory for similarity searches
        embedding = self.text_to_embedding(user_message + " " + bot_response)
        self.faiss_manager.add_embedding(embedding, entry)

    def text_to_embedding(self, text: str) -> np.ndarray:
        """
        Convert text to an embedding vector.
        """
        return self.embedding_model.encode(text)

def get_context(self, query_text: str, k: int = 5) -> dict[str, any]:
    """
    Retrieve context using FAISS + LangChain conversation reasoning.
    """

    query_embedding = self.text_to_embedding(query_text)
    distances, results = self.faiss_manager.search(query_embedding, k=k)

    current_time = datetime.now()
    for result in results:
        timestamp = datetime.fromisoformat(result["timestamp"])
        age = (current_time - timestamp).total_seconds() / 3600  # Age in hours
        decay_factor = max(0, 1 - (age / 24))  # Memories fade over time

        if "important" in result.get("tags", []):
            decay_factor = 1.0  # 🔥 Important memories never fade

        result["score"] *= decay_factor  # Adjust memory strength based on time

    results.sort(key=lambda x: x["score"], reverse=True)

    # ✅ Deduplicate results before passing to LangChain
    unique_results = self.faiss_manager.deduplicate_entries(results)

    # ✅ Use LangChain to generate an enhanced memory summary
    summary = self.conversation_chain.run(f"Summarize these past conversations: {unique_results}")

    return {"context": unique_results, "summary": summary}
