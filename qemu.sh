#qemu -kernel kernel.bin -s -S
qemu-system-x86_64 -bios /usr/share/OVMF/x64/OVMF.fd -net none -hda disk.img -s
