.PHONY: wrt qemu all code


code: code.c
	gcc code.c -c -fPIC -fcf-protection=none -fno-asynchronous-unwind-tables -fno-dwarf2-cfi-asm -ffreestanding -mno-red-zone -fshort-wchar -O3
	gcc dipl.c -o dipl -fPIC -fcf-protection=none -fno-asynchronous-unwind-tables -fno-dwarf2-cfi-asm -mno-red-zone -fshort-wchar -O3
	objcopy -O binary -j .text code.o

main.efi: main.asm Makefile
	nasm -f bin main.asm -o main.efi
	dd if=main.efi of=bootdrv/EFI/BOOT/BOOTX64.EFI

all:
	nasm -f bin main.asm -o main.efi
	dd if=main.efi of=bootdrv/EFI/BOOT/BOOTX64.EFI
	
wrt: bootdrv/EFI/BOOT/BOOTX64.EFI
	dd if=bootdrv/EFI/BOOT/BOOTX64.EFI of=/media/adivanced/uefi_shell/EFI/BOOT/BOOTX64.EFI

qemu:
	qemu-system-x86_64 -M q35 -bios OVMF.fd -net none -vga cirrus -drive file=fat:rw:bootdrv,format=raw,if=none,id=nvm -device nvme,serial=deadbeef,drive=nvm 