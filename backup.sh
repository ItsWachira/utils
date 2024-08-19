#!/bin/bash


SOURCE_DIRS=(
    "/home/oloo/Documents"
    "/home/oloo/DataGripProjects"
    "/home/oloo/IdeaProjects"
    "/home/oloo/Code"
)
DEST_DIR="/mnt/plex/BackUps"
DEVICE="/dev/sda1"  
MOUNT_POINT="/mnt/plex"

# Create the mount point if it doesn't exist
mkdir -p $MOUNT_POINT

# Mount the drive
mount $DEVICE $MOUNT_POINT

# Check if the mount was successful
if mountpoint -q $MOUNT_POINT; then
    echo "Drive mounted successfully."

    # Iterate over each source directory and perform the backup
    for SOURCE_DIR in "${SOURCE_DIRS[@]}"; do
        echo "Backing up $SOURCE_DIR to $DEST_DIR"
        rsync -av --delete "$SOURCE_DIR/" "$DEST_DIR/$(basename $SOURCE_DIR)/"
    done

    # Unmount the drive
     umount $MOUNT_POINT

    if ! mountpoint -q $MOUNT_POINT; then
        echo "Drive unmounted successfully."
    else
        echo "Failed to unmount the drive."
    fi
else
    echo "Failed to mount the drive."
fi

