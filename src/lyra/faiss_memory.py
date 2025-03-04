import faiss
import numpy as np

class FaissMemory:
    def __init__(self, dim: int):
        self.dim = dim
        # Initialize an index for L2 (Euclidean) distance search
        self.index = faiss.IndexFlatL2(dim)
        self.vectors = []  # To keep track of the original vectors (optional)

    def add_embedding(self, vector: np.ndarray):
        """
        Add a single embedding to the index.
        """
        if vector.shape[0] != self.dim:
            raise ValueError(f"Expected vector of dimension {self.dim}, got {vector.shape[0]}")
        # Reshape vector to 2D array as required by faiss (n, dim)
        vector = np.expand_dims(vector, axis=0).astype('float32')
        self.index.add(vector)
        self.vectors.append(vector)
        print("Embedding added.")

    def search(self, query_vector: np.ndarray, k: int = 5):
        """
        Search the index for the top-k nearest neighbors.
        """
        if query_vector.shape[0] != self.dim:
            raise ValueError(f"Expected query vector of dimension {self.dim}, got {query_vector.shape[0]}")
        query_vector = np.expand_dims(query_vector, axis=0).astype('float32')
        distances, indices = self.index.search(query_vector, k)
        return distances, indices

if __name__ == "__main__":
    # Example usage:
    dim = 128  # Replace with your actual embedding dimension
    memory = FaissMemory(dim=dim)
    
    # Create a dummy embedding vector
    embedding = np.random.rand(dim).astype('float32')
    memory.add_embedding(embedding)
    
    # Search with the same embedding (should return itself as nearest)
    d, i = memory.search(embedding, k=1)
    print("Search distances:", d)
    print("Search indices:", i)
