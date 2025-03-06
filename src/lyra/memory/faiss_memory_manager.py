import faiss
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity

class FAISSMemoryManager:
    def __init__(self, dim: int = 384, index_file: str = "faiss_index.bin"):
        """
        Initializes a FAISS index for embeddings.

        Parameters:
            dim (int): The dimension of the embeddings.
            index_file (str): File path to save/load the index.
        """
        self.dim = dim
        self.index_file = index_file
        self.index = faiss.IndexFlatL2(dim)
        self.metadata = []

    def add_embedding(self, embedding: np.ndarray, metadata: dict):
        """
        Adds an embedding with associated metadata to the FAISS index.

        Parameters:
            embedding (np.ndarray): A 1D or 2D numpy array representing the embedding.
            metadata (dict): Additional data (like conversation details) to store alongside the embedding.
        """
        if embedding.ndim == 1:
            embedding = embedding.reshape(1, -1)
        assert embedding.shape[1] == self.dim, f"Embedding dimension {embedding.shape[1]} does not match FAISS index dimension {self.dim}"
        faiss.normalize_L2(embedding)
        self.index.add(embedding)
        metadata['embedding'] = embedding  # Add embedding to metadata
        self.metadata.append(metadata)

    def search(self, query_embedding: np.ndarray, k: int = 5):
        """
        Searches for the top-k similar embeddings in the FAISS index.

        Parameters:
            query_embedding (np.ndarray): A 1D or 2D numpy array representing the query embedding.
            k (int): Number of nearest neighbors to retrieve.

        Returns:
            distances, results: Distances and a list of metadata corresponding to the nearest embeddings.
        """
        if query_embedding.ndim == 1:
            query_embedding = query_embedding.reshape(1, -1)
        assert query_embedding.shape[1] == self.dim, f"Query embedding dimension {query_embedding.shape[1]} does not match FAISS index dimension {self.dim}"
        faiss.normalize_L2(query_embedding)
        distances, indices = self.index.search(query_embedding, k)

        # Handle empty index
        if self.index.ntotal == 0:
            return [], []

        # Debugging: Print indices and metadata length
        print(f"Indices: {indices}")
        print(f"Metadata length: {len(self.metadata)}")

        # Ensure indices are within bounds
        results = []
        for i in indices[0]:
            if i < len(self.metadata):
                results.append(self.metadata[i])
            else:
                results.append({})  # Fallback for out-of-range indices

        return distances, results

    def deduplicate_entries(self, entries, threshold=0.95):
        """
        Removes duplicate entries based on cosine similarity.

        Parameters:
            entries (list): List of metadata entries.
            threshold (float): Similarity threshold for deduplication.

        Returns:
            list: List of unique entries.
        """
        unique_entries = []
        for entry in entries:
            is_duplicate = False
            for unique_entry in unique_entries:
                # Compare embeddings using cosine similarity
                similarity = cosine_similarity(
                    [entry['embedding']], [unique_entry['embedding']]
                )[0][0]
                if similarity > threshold:
                    is_duplicate = True
                    break
            if not is_duplicate:
                unique_entries.append(entry)
        return unique_entries

    def save_index(self):
        """
        Saves the FAISS index to a file.
        """
        faiss.write_index(self.index, self.index_file)

    def load_index(self):
        """
        Loads the FAISS index from a file.
        """
        try:
            self.index = faiss.read_index(self.index_file)
        except Exception as e:
            print("Could not load FAISS index:", e)