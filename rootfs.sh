#!/bin/bash
ROOTFS_NAME="alpine-rootfs"
ROOTFS_FILE="$ROOTFS_NAME.ext4"
ROOTFS_MNT="/tmp/$ROOTFS_NAME/"

# Create and mount rootfs
umount -R "$ROOTFS_MNT"
rm -rf "$ROOTFS_FILE" "$ROOTFS_MNT"
mkdir -R "$ROOTFS_MNT"
dd if=/dev/zero of="$ROOTFS_FILE" bs=1M count=100
mkfs.ext4 "$ROOTFS_FILE"
mount "$ROOTFS_FILE" "$ROOTFS_MNT"

# Setting up multiarch support
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# Create docker
docker run -it \
    --name armv7alpine \
    --net host \
    -v "bootstrap.sh:/bootstrap.sh" \
    -v "$ROOTFS_MNT:/extrootfs" \
    arm32v7/alpine \
    bootstrap.sh

# Cleanup
