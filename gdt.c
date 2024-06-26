#include <stdint.h>
// #include <cpu.h>
#include <memory.h>

#define GDT_CODE      (0x18<<8)
#define GDT_DATA      (0x12<<8)
#define GDT_TSS       (0x09<<8)
#define GDT_DPL(lvl)  ((lvl)<<13)
#define GDT_PRESENT   (1<<15)
#define GDT_LONG      (1<<21)

struct gdt
{
  uint32_t addr;
  uint32_t flags;
}__attribute__((packed));

struct gdtp
{
  uint16_t len;
  struct gdt *gdt;
}__attribute__((packed));

struct tss
{
  uint32_t r1;
  uint64_t rsp0;
  uint64_t rsp1;
  uint64_t rsp2;
  uint64_t r2;
  uint64_t ist1;
  uint64_t ist2;
  uint64_t ist3;
  uint64_t ist4;
  uint64_t ist5;
  uint64_t ist6;
  uint64_t ist7;
  uint64_t r3;
  uint16_t r4;
  uint16_t io_mba;
}__attribute__((packed));


struct gdt BootGDT[] = {
  {0, 0},
  {0, GDT_PRESENT | GDT_DPL(0) | GDT_CODE | GDT_LONG},
  {0, GDT_PRESENT | GDT_DPL(3) | GDT_CODE | GDT_LONG},
  {0, GDT_PRESENT | GDT_DPL(3) | GDT_DATA},
  {0, 0},
  {0, 0},
};

struct gdtp GDTp = {2*8-1, BootGDT};

