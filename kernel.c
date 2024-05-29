 #include "multiboot.h"


void kmain(unsigned long magic, unsigned long)
{
  // multiboot_info_t *mbi;
  
  if (magic != MULTIBOOT_BOOTLOADER_MAGIC) {
    return;
  }

  /* Set MBI to the address of the Multiboot information structure. */
   // mbi = (multiboot_info_t *) addr;



  while (1) {}
}
