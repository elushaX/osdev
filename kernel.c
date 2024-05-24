 #include "multiboot.h"

/* Check if the compiler thinks you are targeting the wrong operating system. */
#if defined(__linux__)
#error "You are not using a cross-compiler, you will most certainly run into trouble"
#endif
 
/* This tutorial will only work for the 32-bit ix86 targets. */
#if !defined(__i386__)
#error "This tutorial needs to be compiled with a ix86-elf compiler"
#endif


void kernel_main(unsigned long magic, unsigned long addr)
{
  multiboot_info_t *mbi;
  
  if (magic != MULTIBOOT_BOOTLOADER_MAGIC) {
    return;
  }

  /* Set MBI to the address of the Multiboot information structure. */
  mbi = (multiboot_info_t *) addr;



  while (1) {}
}
