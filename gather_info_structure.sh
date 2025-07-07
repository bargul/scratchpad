#!/bin/bash

# Define the output file
output_file="info_structure.txt"

# Create an array of patterns to ignore from .gitignore and other sources
ignore_patterns=()
if [ -f ".gitignore" ]; then
    # Read .gitignore into the array, ignoring empty lines and comments
    mapfile -t ignore_patterns < <(grep -v -e '^#' -e '^$' .gitignore)
fi
# Add standard items to always ignore
ignore_patterns+=(".git" "node_modules" ".DS_Store" "$output_file")

# Function to check if an item should be ignored
should_ignore() {
    local item_to_check="$1"
    for pattern in "${ignore_patterns[@]}"; do
        # Use grep to match the pattern against the item path
        if echo "$item_to_check" | grep -qE -- "$pattern"; then
            return 0 # 0 means true (should be ignored)
        fi
    done
    return 1 # 1 means false (should not be ignored)
}

# Function to recursively list directory contents
list_directory() {
    local dir="$1"
    local prefix="$2"
    
    for item in "$dir"/*; do
        # Check if the item exists and is not in the ignore list
        if [ -e "$item" ] && ! should_ignore "$item"; then
            echo "${prefix}$(basename "$item")" >> "$output_file"
            if [ -d "$item" ]; then
                list_directory "$item" "  ${prefix}"
            fi
        fi
    done
}

# Clear the file if it exists, or create a new one
> "$output_file"

# Write the directory structure to the file
list_directory "." ""

echo "Folder structure has been saved to $output_file"
