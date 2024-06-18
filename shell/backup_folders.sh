#!/bin/bash

# This script will ensure that only the files that have changed are copied and that the destination directory is a mirror of the source directories.

# Define source directories
SOURCE_DIRS=(
    "/path/to/source1"
    "/path/to/source2"
    "/path/to/source3"
)

# Define backup destination
BACKUP_PATH="/path/to/backup"

# Iterate over each source directory and perform the mirror sync
for SOURCE_DIR in "${SOURCE_DIRS[@]}"; do
    # Perform the mirror sync using rsync
    rsync -avh --delete --update --progress "$SOURCE_DIR/" "$BACKUP_PATH/$(basename "$SOURCE_DIR")"
done

echo "Mirror sync completed successfully!"
