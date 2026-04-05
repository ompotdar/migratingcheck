#!/bin/bash
echo "Starting migration"
file="repos.txt"

while IFS='|' read -r stash_repo bit_repo || [[ -n "$stash_repo" ]]
do
    echo "stash_repo=$stash_repo"
    echo "bit_repo=$bit_repo"
    # Skip empty lines
    if [ -z "$stash_repo" ] || [ -z "$bit_repo" ]; then
        continue
    fi
    echo "Migrating: $stash_repo"
    git clone --mirror "$stash_repo"
    echo "cloning is complete"
    if [ $? -ne 0 ]; then
        echo "❌ Failed to clone: $stash_repo"
        continue
    fi

    # Extract repo directory name
    REPO_DIR="${stash_repo##*/}"

    cd "$REPO_DIR" || exit

    git push --mirror "$bit_repo"
    if [ $? -ne 0 ]; then
        echo "❌ Push failed for $REPO_DIR"
        cd ..
        rm -rf "$REPO_DIR"
        continue
    fi

    echo "✅ Migration completed for $REPO_DIR"

    cd ..
    rm -rf "$REPO_DIR"

done < "$file"