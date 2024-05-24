#!/bin/bash

# Create disk image
dd if=/dev/zero of=disk.img bs=1M count=600 status=progress

# Partition disk image
parted -s disk.img mklabel gpt
parted -s disk.img mkpart boot fat32 0% 100%
parted -s disk.img set 1 boot on

# Associate loop device
DEV=$(losetup -f)
sudo losetup $DEV disk.img

# Create partition device maps
sudo kpartx -av $DEV

# Wait for partitions to be available
sleep 0.5

PART=/dev/mapper/$(basename $DEV)p1

sudo mkfs.fat -F 32 $PART 

# Mount the first partition
sudo mount  $PART ./mnt

sudo grub-install --boot-directory=mnt --efi-directory=mnt --bootloader-id=BOOT --target=x86_64-efi --removable

sudo cp grub.cfg mnt/grub/grub.cfg
#sudo cp /boot/grub/grub.cfg mnt/grub/grub.cfg

sudo cp kernel.bin mnt/kernel.bin

# Unmount partition and clean up
sudo umount ./mnt
sudo kpartx -d disk.img
#sudo losetup -d $DEV
