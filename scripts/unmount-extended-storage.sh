#!/bin/bash

# Script to safely unmount ExtendedStorage external drive
# Usage: ./unmount-extended-storage.sh

DRIVE_NAME="ExtendedStorage"
MOUNT_PATH="/Volumes/$DRIVE_NAME"

echo "🔍 Checking if $DRIVE_NAME is mounted..."

if [ ! -d "$MOUNT_PATH" ]; then
    echo "⚠️  $DRIVE_NAME is not currently mounted."
    exit 0
fi

echo "📤 Unmounting $DRIVE_NAME..."

if diskutil unmount "$MOUNT_PATH"; then
    echo "✅ $DRIVE_NAME safely unmounted! You can now remove the drive."
else
    echo "❌ Failed to unmount $DRIVE_NAME"
    echo ""
    echo "Possible reasons:"
    echo "  - Files are open on the drive"
    echo "  - Applications are using files from the drive"
    echo ""
    echo "Try closing any apps or files using the drive and run this script again."
    echo ""
    echo "To force unmount (may cause data loss):"
    echo "  diskutil unmount force $MOUNT_PATH"
    exit 1
fi
