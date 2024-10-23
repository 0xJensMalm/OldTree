import os
import pyperclip
import time

def get_swift_files(directory):
    """Recursively find all .swift files in the directory."""
    swift_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.swift'):
                swift_files.append(os.path.join(root, file))
    return swift_files

def create_folder_structure(directory):
    """Create a visual folder structure string."""
    structure = []
    for root, dirs, files in os.walk(directory):
        # Skip build folders and .git
        if 'build' in root.lower() or '.git' in root:
            continue
            
        level = root.replace(directory, '').count(os.sep)
        indent = '│   ' * (level - 1) + '├── ' if level > 0 else ''
        structure.append(f'{indent}{os.path.basename(root)}/')
        
        for file in files:
            if file.endswith('.swift'):
                indent = '│   ' * level + '├── '
                structure.append(f'{indent}{file}')
    
    return '\n'.join(structure)

def read_file_content(file_path):
    """Read and return the content of a file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            return file.read()
    except Exception as e:
        return f"Error reading file: {str(e)}"

def extract_project():
    current_dir = os.getcwd()
    
    # Get folder structure
    output = "Project Structure:\n"
    output += "=================\n"
    output += create_folder_structure(current_dir)
    output += "\n\nCode Files:\n"
    output += "===========\n\n"
    
    # Get code from swift files
    swift_files = get_swift_files(current_dir)
    for file_path in swift_files:
        relative_path = os.path.relpath(file_path, current_dir)
        output += f"// File: {relative_path}\n"
        output += "```swift\n"
        output += read_file_content(file_path)
        output += "\n```\n\n"
    
    print("\nPreview of the output:")
    print("------------------------")
    print(output[:500] + "...\n")
    
    return output

def main():
    while True:
        output = extract_project()
        
        while True:
            copy_choice = input("\nDo you want to copy this to clipboard? (y/n): ").lower()
            if copy_choice in ['y', 'n']:
                break
            print("Please enter 'y' or 'n'")
            
        if copy_choice == 'y':
            pyperclip.copy(output)
            print("Content copied to clipboard!")
            time.sleep(1)  # Give user time to see the confirmation
        
        while True:
            again_choice = input("\nDo you want to extract from the same codebase again? (y/n): ").lower()
            if again_choice in ['y', 'n']:
                break
            print("Please enter 'y' or 'n'")
            
        if again_choice == 'n':
            print("\nGoodbye!")
            break

if __name__ == "__main__":
    main()
