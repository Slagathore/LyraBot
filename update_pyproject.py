import os
import toml

def update_pyproject(file_path):
    if not os.path.exists(file_path):
        print(f"Error: {file_path} not found.")
        return

    # Load the current configuration
    with open(file_path, 'r', encoding='utf-8') as f:
        data = toml.load(f)

    # Check if [project] and its dependencies exist
    if 'project' in data and 'dependencies' in data['project']:
        deps = data['project']['dependencies']
        # Filter out any dependency that starts with 'python'
        new_deps = [dep for dep in deps if not dep.strip().lower().startswith('python')]
        
        if len(new_deps) != len(deps):
            data['project']['dependencies'] = new_deps
            # Write the updated configuration back to the file
            with open(file_path, 'w', encoding='utf-8') as f:
                toml.dump(data, f)
            print("Updated pyproject.toml successfully: removed python dependency.")
        else:
            print("No python dependency found in pyproject.toml; no changes made.")
    else:
        print("No [project] dependencies section found in pyproject.toml.")

if __name__ == "__main__":
    update_pyproject("pyproject.toml")
