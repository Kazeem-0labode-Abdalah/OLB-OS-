ENTRY(_start)

SECTIONS
{
    . = 0x00100000;

    .multiboot ALIGN(4K) : {
        *(.multiboot)
    }

    .boot ALIGN(4K) : {
        *(.boot)
    }

    .text ALIGN(4K) : {
        *(.text)
    }

    .rodata ALIGN(4K) : {
        *(.rodata)
    }

    .data ALIGN(4K) : {
        *(.data)
    }

    .bss ALIGN(4K) : {
        *(COMMON)
        *(.bss*)
    }

    /* Actual end of the kernel's normal sections */
    _kernel_end = .;

    /* PCB array and its counters */
    .pcb_storage ALIGN(16) (NOLOAD) : {
        _pcb_entries_start = .;
        . += 7600;              /* 100 PCBs × 76 bytes */

        _pcb_cur_index = .;
        . += 4;

        _amount_of_used_pcb = .;
        . += 4;
    }

    /* PMM bitmap: maximum 4 GiB addressable, 128 KiB bitmap */
    .pmm_bitmap ALIGN(4096) (NOLOAD) : {
        _pmm_bitmap_start = .;
        . += 131072;
    }
}