from sqlalchemy import create_engine, Column, Integer, Text, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import datetime

# Define the base class for our models
Base = declarative_base()

# Define a model for storing conversation logs
class Conversation(Base):
    __tablename__ = 'conversations'
    id = Column(Integer, primary_key=True)
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)
    user_message = Column(Text)
    bot_response = Column(Text)

# Create an SQLite database (memory.db will be created in the project folder)
engine = create_engine('sqlite:///../memory.db', echo=False)
Session = sessionmaker(bind=engine)
session = Session()

def init_db():
    """Initialize the database and create tables."""
    Base.metadata.create_all(engine)
    print("Database initialized. 'memory.db' created.")

# Example function to log a conversation
def log_conversation(user_msg: str, bot_resp: str):
    new_entry = Conversation(user_message=user_msg, bot_response=bot_resp)
    session.add(new_entry)
    session.commit()
    print("Conversation logged.")

if __name__ == "__main__":
    init_db()
    # Example: Log a sample conversation
    log_conversation("Hello, Lyra!", "Hello, Cole. How can I help you today?")
