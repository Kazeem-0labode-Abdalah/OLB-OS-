#include "Interupts/idt.h"
#include "Timer/timer.h"
#include "Keyboard/keyboard.h"
#include "PMM/pmm.h"
#include "VMM/vmm.h"
#include "kernel.h"
#include "utils/util.h"
#include "user_program_loader/upl.h"
#include "vga/vga.h"

void kernel_main(void){

extern uint8_t _pcb_entries_start[];
extern uint32_t _pcb_cur_index;
extern uint32_t _amount_of_used_pcb;
asm volatile("cli");//disable all interupt till the interupt handlers have been installed
extern volatile uint32_t timer_irq_count;
    print("Welcome to the kernel of OLB_OS, focus on the text with red background\n");
    uint32_t *amount_of_used_pcb = &_amount_of_used_pcb;
    *amount_of_used_pcb = 1;
    mmap_entry_t *mmap_location = (mmap_entry_t*)MMAP_LOCATION;
   uint16_t mmap_entries_num = *(uint16_t*)MMAP_ENTRIES_NUM;

     initIdt();
     print("IDT has been initiated\n");
     initTimer();
     print("Timer has been initiated\n");
     initKeyboard();
     print("Keyboard has been initiated\n");
     init_pmm(mmap_location,mmap_entries_num);
     print("Physical memory manager has been initiated\n");
     init_vmm();
     print("Virtual memory manager has been initiated\n");
     PCB_entry *kernel_pcb_holder = (PCB_entry *)_pcb_entries_start;
     uint32_t *pcb_entries_cur_index = &_pcb_cur_index;
     *pcb_entries_cur_index = 0;
     memset(kernel_pcb_holder,0,sizeof(PCB_entry) * MAX_AMOUNT_OF_PCB_ENTRIES); 
      for (uint32_t i = 0; i < MAX_AMOUNT_OF_PCB_ENTRIES; i++) {
      kernel_pcb_holder[i].state = PCB_UNUSED;
     }
      print("PCB array initialized\n");
      asm volatile("STI");
      print("Interrupts have enabled\n");
      print("You can start typing now\n");
      print("\n");
      print("\n");
      print("\n");

  char program1[11] = {
     'P','G','R','A','M','1',' ',' ',
     'B','I','N'
 };

 char program2[11] = {
     'P','G','R','A','M','2',' ',' ',
     'B','I','N'
 };
    user_program_loader((uint32_t)page_dir,kernel_pcb_holder,program1);
  //  user_program_loader((uint32_t)page_dir,kernel_pcb_holder,program2);
    //return;

//for(;;);
 }
