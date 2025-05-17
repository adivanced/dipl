.PHONY: wrt qemu

main.efi: main.asm Makefile
	nasm -f bin main.asm -o main.efi
	dd if=main.efi of=bootdrv/EFI/BOOT/BOOTX64.EFI

wrt: bootdrv/EFI/BOOT/BOOTX64.EFI
	dd if=bootdrv/EFI/BOOT/BOOTX64.EFI of=/media/adivanced/uefi_shell/EFI/BOOT/BOOTX64.EFI

qemu:
	qemu-system-x86_64 -bios OVMF.fd -net none -vga cirrus -drive file=fat:rw:bootdrv,format=raw