DEV=$(losetup -f)

rm disk.img

#qemu-img create disk.img 600M
dd if=/dev/zero of=disk.img status=progress count=600MB

parted disk.img << EFO
mklabel
gpt
mkpart
boot
fat32
0
100%
set 1 boot on
EFO

sudo losetup --detach-all
sudo losetup $DEV -o 17408 disk.img
sudo mkfs.fat -F 32 $DEV

sudo mkdir -p mnt
sudo mount $DEV ./mnt
#sudo mkdir -p mnt/EFI/BOOT
sudo grub-install --boot-directory=mnt --efi-directory=mnt --bootloader-id=BOOT --target=x86_64-efi

sudo cp grub.cfg mnt/grub/grub.cfg
sudo cp kernel.bin mnt/kernel.bin


#sudo rm -rf mnt/*
#sudo cp -r /boot/* mnt/
#sudo cp -r /boot/grub/grub.cfg mnt/grub/grub.cfg

#sudo rm -rf mnt/EFI
#sudo cp -r /boot/EFI mnt/EFI
#sudo rm -rf mnt/EFI/--removable
#sudo ls mnt/EFI

#sudo mv mnt/EFI/BOOT/grubx64.efi mnt/EFI/BOOT/BOOTX64.EFI

sudo cp BOOTX64.EFI mnt/EFI/BOOT/BOOTX64.EFI


sudo umount mnt
sudo losetup -d $DEV
