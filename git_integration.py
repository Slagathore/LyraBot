from git import Repo, GitCommandError
import os

def commit_and_push(repo_dir: str, commit_message: str) -> None:
    """
    Adds all changes in the repo, commits with the provided message, and pushes to the remote repository.
    
    Parameters:
        repo_dir (str): Path to the local Git repository.
        commit_message (str): The commit message to use.
    """
    try:
        repo = Repo(repo_dir)
    except Exception as e:
        print(f"Error: Unable to locate a Git repository at {repo_dir}. {e}")
        return

    try:
        # Stage all changes (including untracked files)
        repo.git.add('--all')
        
        # Check if there are changes to commit
        if repo.is_dirty(untracked_files=True):
            commit = repo.index.commit(commit_message)
            print(f"Committed changes: {commit.hexsha}")
        else:
            print("No changes detected. Nothing to commit.")

        # Push to the remote named 'origin'
        origin = repo.remote(name='origin')
        push_info = origin.push()
        for info in push_info:
            if info.flags & info.ERROR:
                print(f"Push failed: {info.summary}")
            else:
                print(f"Push succeeded: {info.summary}")

    except GitCommandError as git_error:
        print(f"Git command error: {git_error}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

# Example usage:
if __name__ == "__main__":
    # Replace with your local repository path and commit message
    repository_path = os.path.abspath(".")  # Assuming current directory is the repo
    message = "Automated commit from my integration module."
    commit_and_push(repository_path, message)
