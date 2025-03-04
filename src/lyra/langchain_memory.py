from langchain.memory import ConversationBufferMemory

def create_conversation_memory():
    """
    Create a basic conversation buffer memory from LangChain.
    This will store conversation context as plain text.
    """
    memory = ConversationBufferMemory(memory_key="chat_history", return_messages=True)
    return memory

if __name__ == "__main__":
    memory = create_conversation_memory()
    # Simulate adding messages to memory
    memory.save_context({"input": "Hello, Lyra!"}, {"output": "Hello, Cole. How can I help you today?"})
    
    # Retrieve stored context
    chat_history = memory.load_memory_variables({})
    print("Current conversation history:", chat_history)
