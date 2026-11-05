//this driver will be used eventually when we boot frm a hard disk

void ata_read_sector(uint32_t lba, uint8_t *buffer){

    // Select master drive,enable LBA addressing and send the upper 4 bit of the lba
    outPortB(0x1F6, 0xE0 | ((lba >> 24) & 0x0F));

    //Port 0x1F2 is the Sector Count register, Set sector count to 1 meaning we want to read one sector?
    outPortB(0x1F2, 1);

    // Send the 28-bit LBA address
    outPortB(0x1F3, lba & 0xFF);// bit 0-7 (lowest byte)
    outPortB(0x1F4, (lba >> 8) & 0xFF); // bit 8-15
    outPortB(0x1F5, (lba >> 16) & 0xFF);//Bits 16–23 and Drive selection + bits 24–27 is in port 0x1F6 so that account for the last 4bits of the lba

    // Issue READ SECTORS command tell the disk to read
    outPortB(0x1F7, 0x20);

    // 400ns delay
    for(int i = 0; i < 4; i++){
        importB(0x3F6);//are we just doing time to wait 400ns which is the time needed to read 1 sector or is there another reason for this wait?
    }

    uint32_t timeout = 1000000;
    uint8_t status;

    // Wait for BSY to clear
    while((status = importB(0x1F7)) & 0x80){BSY 1 being busy mean what what device is being busy? is it the storage device if yes busy doing what and what is the ata controller?
        if(--timeout == 0){
            print("ATA timeout waiting for BSY\n");
            return;
        }
    }

    // Wait for DRQ, checking for errors
    timeout = 1000000;

    while(1){

        status = importB(0x1F7);

        if(status == 0){//if status is as a whole 0 then it means there is no devise responding at all
            print("ATA device not present\n");
            return;
        }

        if(status & 0x01){//The ERR bit is bit zero,If it is set, the device encountered an error.
            print("ATA read error\n");
            return;
        }

        if(status & 0x20){//DF stands for Device Fault,If this bit is set, the device reports a fault condition.
            print("ATA device fault\n");
            return;
        }

        if(!(status & 0x80) && (status & 0x08)){//first is BSY and second id DRQ so what we do here is check if device is not busy and has somthing go give us BSY becoming zero does not necessarily mean the data is ready. That is why you also check DRQ.
            break;
        }

        if(--timeout == 0){//this is to make sure we dont wait on DRQ indefinitly
            print("ATA timeout waiting for DRQ\n");
            return;
        }
    }

    // Read 256 words (512 bytes) now we transfer the actual sectot into RAM
    for(uint16_t i = 0; i < 256; i++){//what is little edian?

        uint16_t data = inw(0x1F0);//we read 16 bits from this port

        buffer[i * 2]     = data & 0xFF;//then explain why we do this?
        buffer[i * 2 + 1] = (data >> 8) & 0xFF; and this?
    }

    // Check for errors after data transfer via the status regiter
    status = importB(0x1F7);

    if(status & 0x01){
        print("ATA error after sector read\n");
        return;
    }

    if(status & 0x20){
        print("ATA device fault after sector read\n");
        return;
    }
}



