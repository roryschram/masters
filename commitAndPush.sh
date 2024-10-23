#!/bin/bash

# Stage all changes
git add .

# Prompt the user for a commit message
read -p "Enter the commit message: " commit_message

# Commit with the provided message
git commit -am "$commit_message"

# Push the changes
git push
