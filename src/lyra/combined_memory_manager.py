from lyra.memory.json_memory_manager import JSONMemoryManager
from lyra.memory.faiss_memory_manager import FAISSMemoryManager
from lyra.memory.sql_memory_manager import log_conversation
from lyra.langchain_integration import create_conversation_chain
from datetime import datetime
import numpy as np
from sentence_transformers import SentenceTransformer  # or use OpenAI embeddings

class CombinedMemoryManager:
    def __init__(self):
        self.json_manager = JSONMemoryManager(file_path="conversation_history.json")
        self.faiss_manager = FAISSMemoryManager(dim=384, index_file="faiss_index.bin")
        self.conversation_chain = create_conversation_chain()
        self.embedding_model = SentenceTransformer('all-MiniLM-L6-v2')  # or use OpenAI

    def add_memory(self, user_message: str, bot_response: str, conversation_id: str = None):
        entry = {
            "user": user_message,
            "bot": bot_response,
            "timestamp": datetime.now().isoformat(),
            "conversation_id": conversation_id
        }
        
        # Log to JSON memory
        self.json_manager.add_memory(entry)
        
        # Log to SQL memory
        try:
            log_conversation(user_message, bot_response)
        except Exception as e:
            print("SQL memory logging failed:", e)
        
        # Log to FAISS memory
        embedding = self.text_to_embedding(user_message + " " + bot_response)
        self.faiss_manager.add_embedding(embedding, entry)

    def text_to_embedding(self, text: str) -> np.ndarray:
        return self.embedding_model.encode(text)

    def get_context(self, query_text: str, k: int = 5):
        query_embedding = self.text_to_embedding(query_text)
        distances, results = self.faiss_manager.search(query_embedding, k=k)
        unique_results = self.faiss_manager.deduplicate_entries(results)  # Deduplicate results
        return unique_results