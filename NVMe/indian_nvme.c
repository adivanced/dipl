/*
 * NVMe over PCIe driver.
 */
#include "string.h"
#include "printk.h"
#include <stdint.h>

volatile uint64_t *pcie_ecam = NULL;
int16_t detected_bus_num = -1;
int16_t detected_device_num = -1;
int16_t detected_function_num = -1;
volatile uint64_t *nvme_base = NULL;
volatile char *nvme_data_region;
volatile char *data_region_creation_addr;
volatile char *nvme_asqb;
volatile char *nvme_acqb;
volatile char *nvme_atail;
volatile char *nvme_iotail;
volatile char *nvme_ans = NULL;	// 4K Namespace Data
volatile char *nvme_nsid = NULL;	// 4K Namespace Identify Data
volatile char *nvme_iosqb;
volatile char *nvme_iocqb ;
char nvme_cc = 0x14;	// 4-byte Controller Configuration (CC) register

unsigned char check_xsdt_checksum(uint64_t *xsdt, uint32_t xsdt_length);
uint32_t check_mcfg_checksum(uint64_t *mcfg);
void check_all_buses(uint16_t start, uint16_t end);
int find_nvme_controller(uint16_t bus, uint8_t device, uint8_t function);
volatile uint64_t *get_nvme_base(uint16_t bus, uint8_t kbpo, uint8_t function);
int reset_controller(void);
int configure_admin_q(void);
int wait_for_reset_complete(void);
void set_admin_q_attrs(void);
char *get_next_4096_aligned_addr(void);
void enable_controller(void);
void create_io_queues(void);

int nvme_init(void *xsdp, char *sys_var_ptr)
{
	int i;
	uint64_t *xsdt;
	uint32_t xsdt_length;
	int num_entries;
	uint64_t *desc_header;
	uint64_t *mcfg;
	char desc_header_sig[4];
	uint16_t start_bus_num;
	uint16_t end_bus_num;

	mcfg = NULL;

	/* get physical address of the XSDT */
	xsdt = (uint64_t *) *((uint64_t *) ((char *) xsdp + 24));

	xsdt_length = *((uint32_t *) ((unsigned char *) xsdt + 4));

	/* check for valid XSDT checksum */
	if(check_xsdt_checksum(xsdt, xsdt_length) != 0) {
		printk("error: invalid xsdt table!\n");
		return 1;
	}

	num_entries = (xsdt_length - 36)/8 ;

	/* find and store MCFG table pointer */
	for(i = 0; i < num_entries; i++) {
		desc_header = (uint64_t *) ((uint64_t *) ((char *) xsdt + 36))[i];

		strncpy(desc_header_sig, (char *) desc_header, 4);

		/* check MCFG table signature */
		if(strncmp(desc_header_sig, "MCFG", 4) == 0) {
			/* check for valid MCFG checksum */
			if(check_mcfg_checksum(desc_header) == 0) {
				/* This is our MCFG table. Store its pointer */
				mcfg = desc_header;
				break;
			}
		}
	}

	if(mcfg == NULL) {
		printk("error: could not find MCFG table!\n");
		return 1;
	}

	/* get and store ECAM base address and starting and ending pcie bus number */
	pcie_ecam = (uint64_t *) *((uint64_t *) ((char *) mcfg + 44));
	start_bus_num = (uint16_t) *((unsigned char *) mcfg + 44 + 10);
	end_bus_num = (uint16_t) *(((unsigned char *) mcfg) + 44 + 11);

	/* enumerate pcie buses to find the nvme controller */
	check_all_buses(start_bus_num, end_bus_num);

	if(detected_bus_num != -1 && detected_device_num != -1 && detected_function_num != -1) {
		printk("found nvme controller! bus num={d}, device num={d}, function num={d}\n\n", detected_bus_num, detected_device_num, detected_function_num);
	} else {
		printk("couldn't found the nvme controller!\n");
		return 1;
	}

	/* get nvme base address */
	nvme_base = get_nvme_base(detected_bus_num, detected_device_num, detected_function_num);

	printk("@nvme_base={p}\n", (void *) nvme_base);

	/* reset the controller */
	if(reset_controller() == 1) {
		printk("nvme: error: the controller has had a fatal error!\n");
		return 1;
	}

	printk("@nvme: reset complete!\n");

	nvme_data_region = sys_var_ptr;

	data_region_creation_addr = nvme_data_region;

	/* configure the admin queue */
	configure_admin_q();

	/* enable controller */
	enable_controller();

	printk("@nvme: controller is enabled!\n");

	if(nvme_init_enable_wait() == 1) {
		printk("nvme: fatal error! CSTS.CFS (1) is not 0!\n");
		return 1;
	}

	nvme_atail = data_region_creation_addr;

	/* update data_region_creation_addr to the next 4096-byte aligned boundary to be reused */
	data_region_creation_addr += 4096;


	/* save the identify controller structure */
	save_controller_struct();

	/* crete the first i/o completion and the i/o submission queues */
	create_io_queues();

	/* save the active namespace id list */
	// save_active_nsid_list();

	/* save the identify namespace data */
	// save_identify_ns_struct();

	nvme_iotail = data_region_creation_addr;

	data_region_creation_addr += 4096;

	printk("@Done!\n");

	return 0;
}

void uncacheable_memory(void)
{
        __asm__("mov rax, %0\n\t"
                "shr rax, 18\n\t"
                "and al, 0xF8\n\t"              // Clear the last 3 bits
                "mov rdi, 0x10000\n\t"          // Base of low PDE
                "add rdi, rax\n\t"
                "mov rax, [rdi]\n\t"
                "btc rax, 3\n\t"                        // Clear PWT to disable caching
                "bts rax, 4\n\t"                        // Set PCD to disable caching
                "mov [rdi], rax"
                ::"m" (nvme_base):"rax","rdi");
}

void *get_base_phy_addr(uint16_t bus, uint8_t device, uint8_t function)
{
        void *phy_addr;

        phy_addr = (void *) ((uint64_t) pcie_ecam + (((uint32_t) bus) << 20 | ((uint32_t) device) << 15 | ((uint32_t) function) << 12));

        return phy_addr;
}

void enable_pci_bus_mastering(void)
{
        volatile void *phy_addr;
        int32_t value;

        phy_addr = get_base_phy_addr(detected_bus_num, detected_device_num, detected_function_num);

        phy_addr = (void *) ((char *) phy_addr + (1 * 4));      /* get status/command from pcie device's register #1 */

        value = *((volatile int32_t *) phy_addr);

        __asm__("mov eax, %0\n\t"
                "bts eax, 2\n\t"
                "mov %0, eax"
                ::"m" (value):"eax");

        *((volatile int32_t *) phy_addr) = value;        /* write value to pcie device's register #1 */

}

void check_cmd_set_supported(void)
{
	char nvme_cap = 0x0;		
	volatile uint64_t *addr = (volatile uint64_t *) ((char *) nvme_base + nvme_cap);
	uint64_t value;

	value = *addr;

	printk("@cap register value={p}\n", (void *) value);
}


int nvme_init_enable_wait(void)
{
	char nvme_csts =  0x1C; // 4-byte controller status property
	void* addr = (void *) ((char *) nvme_base + nvme_csts);
	uint32_t val;

	do {
		val = *((volatile uint32_t *) addr);

		if((val & 0x2)!= 0x0)	// CSTS.CFS (1) should be 0. If not the controller has had a fatal error
		{
			return 1;
		}
	}while((val & 0x1) != 0x1);	// Wait for CSTS.RDY (0) to become '1'

	return 0;
}

void nvme_admin_wait(volatile char *acqb_copy)
{
	uint64_t val;

	do{
		val = *(volatile uint64_t *) acqb_copy;
	}while(val == 0);

	printk("acq: status field value: {p}\n", (void *) *(volatile uint16_t *) ((char *) acqb_copy + 2));
	
	*(volatile uint64_t *) acqb_copy = 0; // Overwrite the old entry
}	

void nvme_admin_savetail(uint32_t a_tail_val, volatile char* nvme_atail, uint32_t old_tail_val)
{
	uint8_t val = (uint8_t) a_tail_val;
	uint32_t val_new = val;
	volatile char *acqb_copy = nvme_acqb;

	printk("@old_tail_val={d}\n", old_tail_val);

	*nvme_atail = val;	// Save the tail for the next command

	printk("@written tail_val_new={d}\n", val_new);


	*((volatile uint32_t *) ((char *) nvme_base + 0x1000)) = val_new; // Write the new tail value

	// Check completion queue
	old_tail_val = (old_tail_val << 4);	// Each entry is 16 bytes
	// old_tail_val = (uint8_t) old_tail_val + 8;	// Add 8 for DW3
	old_tail_val = (uint8_t) old_tail_val + 12;	// Add 12 for DW3

	acqb_copy += old_tail_val;

	printk("@acqb_copy={p}\n", (volatile void *) acqb_copy);
	
	nvme_admin_wait(acqb_copy);
}

void nvme_io_wait(volatile uint64_t *iocqb_copy)
{
	uint64_t val;

	do{
		val = *(volatile uint64_t *) iocqb_copy;
	}while(val == 0);
	
	*(volatile uint64_t *) iocqb_copy = 0; // Overwrite the old entry
}	

void nvme_io_savetail(uint32_t io_tail_val, volatile char* nvme_iotail, uint32_t old_tail_val)
{
	uint8_t val = (uint8_t) io_tail_val;
	uint32_t val_new = val;
	volatile char *iocqb_copy = nvme_iocqb;

	printk("@old_tail_val={d}\n", old_tail_val);

	*nvme_iotail = val;	// Save the tail for the next command

	printk("@written tail_val_new={d}\n", val_new);


	*((volatile uint32_t *) ((char *) nvme_base + 0x1008)) = val_new; // Write the new tail value

	// Check completion queue
	old_tail_val = (old_tail_val << 4);	// Each entry is 16 bytes
	old_tail_val = (uint8_t) old_tail_val + 8;	// Add 8 for DW3

	iocqb_copy += old_tail_val;

	printk("@iocqb_copy={p}\n", (volatile void *) iocqb_copy);
	
	nvme_io_wait(iocqb_copy);
}

/*
 * nvme_admin -- Perform an Admin operation on a nvme controller
 */
void nvme_admin(uint32_t cdw0, uint32_t cdw1, uint32_t cdw10, uint32_t cdw11, volatile char* cdw6_7)
{
	volatile char *nvme_asqb_ptr = nvme_asqb;
	uint32_t tmp, a_tail_val = 0;
	int64_t val2;
	uint8_t a_tail_val_8;

	// Build the command at the expected location in the Submission ring
	a_tail_val = *nvme_atail; // Get the current Admin tail value

	a_tail_val *= 64;			// Quick multiply by 64
							//
	a_tail_val_8 = (uint8_t) a_tail_val;

	nvme_asqb_ptr += a_tail_val_8;

	// Build the structure
	*(volatile uint32_t *) nvme_asqb_ptr = cdw0;	// CDW0
	*(volatile uint32_t *) (nvme_asqb_ptr + 4) = cdw1;	// CDW1
	*(volatile uint32_t *) (nvme_asqb_ptr + 8) = 0;	// CDW2
	*(volatile uint32_t *) (nvme_asqb_ptr + 12) = 0;	// CDW3
	*(volatile uint64_t *) (nvme_asqb_ptr + 16) = 0;	// CDW4-5
	*(volatile uint64_t *) (nvme_asqb_ptr + 24) = (uint64_t) cdw6_7;	// CDW6-7
	*(volatile uint64_t *) (nvme_asqb_ptr + 32) = 0;	// CDW8-9
	*(volatile uint32_t *) (nvme_asqb_ptr + 40) = cdw10;	// CDW10
	*(volatile uint32_t *) (nvme_asqb_ptr + 44) = cdw11;	// CDW11
	*(volatile uint32_t *) (nvme_asqb_ptr + 48) = 0;	// CDW12
	*(volatile uint32_t *) (nvme_asqb_ptr + 52) = 0;	// CDW13
	*(volatile uint32_t *) (nvme_asqb_ptr + 56) = 0;	// CDW14
	*(volatile uint32_t *) (nvme_asqb_ptr + 60) = 0;	// CDW15
								//
	
	// Start the Admin command by updating the tail doorbell
	a_tail_val = 0;
	a_tail_val = *nvme_atail; // Get the current Admin tail value
	tmp = a_tail_val;	// Save the old Admin tail value for reading from the completion ring
	a_tail_val++;			// Add 1 to it
	
	if(a_tail_val>= 64)
		a_tail_val = 0;

	nvme_admin_savetail(a_tail_val, nvme_atail, tmp);
}

void create_io_queues(void)
{
	/* set cc.iocqes to 16 commands (16 bytes) and cc.iosqes to 64 */
	volatile uint32_t *addr = (volatile uint32_t *) ((char *) nvme_base + nvme_cc);
	uint32_t value;

	value = *addr;

	printk("@create_io_queues: old CC value={d}\n", value);

	/* set cc.iocqes to 16, cc.iosqes to 64, and cc.en (bit #0) to 1 */
	value = 0x460001;

	*addr = value;

	printk("@create_io_queues: new CC value={p}\n", (void *) *addr);


	/* create the first i/o completion queue */
	uint32_t cdw0 = 0x00000005;	// CDW0 CID 0, PRP used (15:14 clear), FUSE normal (bits 9:8 clear), command create io completion queue (0x05)
	uint32_t cdw1 = 0;	// CDW1 Ignored
	// uint32_t cdw10 = 0x3f0001;	/* cdw10: queue size = 64 commands, qid = 1 */
	uint32_t cdw10 = 0xf0001;	/* cdw10: queue size = 16 commands, qid = 1 */
	uint32_t cdw11 = 0x1;		/* cdw11: physically contiguous (1<<0), interrupts disabled */
	
	nvme_iocqb = data_region_creation_addr;

	data_region_creation_addr += 4096;
	
	printk("@nvme_iocqb = {p}\n", (void *) nvme_iocqb);

	nvme_admin(cdw0, cdw1, cdw10, cdw11, nvme_iocqb);


	/* create the first i/o submission queue */
	cdw0 = 0x00000001;	// CDW0 CID 0, PRP used (15:14 clear), FUSE normal (bits 9:8 clear), command create io submission queue (0x01)
	cdw1 = 0;	// CDW1 Ignored
	cdw10 = 0x3f0001;	/* cdw10: queue size = 64 commands, qid = 1 */
	// cdw11 = 0x1;		/* cdw11: cqid = 1, physically contiguous (1<<0) */
	cdw11 = 0x10001;		/* cdw11: cqid = 1, physically contiguous (1<<0) */
	
	nvme_iosqb = data_region_creation_addr;

	data_region_creation_addr += 4096;
	
	printk("@nvme_iosqb = {p}\n", (void *) nvme_iosqb);

	nvme_admin(cdw0, cdw1, cdw10, cdw11, nvme_iosqb);
}

void save_controller_struct(void)
{
	uint32_t cdw0 = 0x00000006;	// CDW0 CID 0, PRP used (15:14 clear), FUSE normal (bits 9:8 clear), command Identify (0x06)
	uint32_t cdw1 = 0;	// CDW1 Ignored
	uint32_t nvme_ID_CTRL = 0x01;		// CDW10 CNS. Identify Controller data structure for the controller
	uint32_t cdw11 = 0;	// CDW11 Ignored
	volatile char *nvme_CTRLID;	// 4K Controller Identify Data

	nvme_CTRLID = data_region_creation_addr;

	data_region_creation_addr += 4096;

	printk("nvme_CTRLID val before submitting identify cmd = {p}\n", (void *) (*(volatile uint64_t *)nvme_CTRLID));

	nvme_admin(cdw0, cdw1, nvme_ID_CTRL, cdw11, nvme_CTRLID);
	
	printk("nvme_CTRLID val after receiving response = {p}\n", (void *) (*(volatile uint64_t *)nvme_CTRLID));

	/* record the max. transfer size */

	uint8_t mdts = *(volatile uint8_t *) ((char *) nvme_CTRLID + 77);
	
	uint8_t cqes= *(volatile uint8_t *) ((char *) nvme_CTRLID + 513);
	uint8_t sqes= *(volatile uint8_t *) ((char *) nvme_CTRLID + 512);

	printk("@mdts = {d}\n", mdts);
	printk("@cqes = {d}\n", cqes);
	printk("@sqes = {d}\n", sqes);
}

void save_active_nsid_list(void)
{
	uint32_t cdw0 = 0x00000006;	// CDW0 CID 0, PRP used (15:14 clear), FUSE normal (bits 9:8 clear), command Identify (0x06)
	uint32_t cdw1 = 0;	// CDW1 Ignored
	uint32_t nvme_ID_CTRL = 0x02;		// CDW10 CNS. Identify Active Namespace ID list
	uint32_t cdw11 = 0;	// CDW11 Ignored

	nvme_ans = data_region_creation_addr;

	data_region_creation_addr += 4096;


	printk("nvme_ans val before submitting identify cmd = {p}\n", (void *) (*(volatile uint64_t *)nvme_ans));

	
	nvme_admin(cdw0, cdw1, nvme_ID_CTRL, cdw11, nvme_ans);
	
	
	printk("nvme_ans val after receiving response = {p}\n", (void *) (*(volatile uint64_t *)nvme_ans));
}

void save_identify_ns_struct(void)
{
	uint32_t cdw0 = 0x00000006;	// CDW0 CID 0, PRP used (15:14 clear), FUSE normal (bits 9:8 clear), command Identify (0x06)
	uint32_t cdw1 = 1;	// CDW1 NSID
	uint32_t nvme_ID_CTRL = 0x00;		// CDW10 CNS. Identify Namespace data structure for the specified NSID
	uint32_t cdw11 = 0;	// CDW11 Ignored

	nvme_nsid = data_region_creation_addr;

	data_region_creation_addr += 4096;


	printk("nvme_nsid val before submitting identify cmd = {p}\n", (void *) (*(volatile uint64_t *)nvme_nsid));

	
	nvme_admin(cdw0, cdw1, nvme_ID_CTRL, cdw11, nvme_nsid);
	
	
	printk("nvme_nsid val after receiving response = {p}\n", (void *) (*(volatile uint64_t *)nvme_nsid));
}

/*
 * paste data from nvme partition to the partition data buffer
 */
char *paste_from_nvme()
{
	uint32_t cdw0 = 0x00000002;	// CDW0 CID 0, PRP used (15:14 clear), FUSE normal (bits 9:8 clear), command read (0x02)
	uint32_t cdw1 = 1;	// CDW1 NSID
	uint32_t cdw10_11 = 422324224;		// CDW10 
	uint32_t cdw12 = 42;	/* 43 bytes */

	volatile char *partition_data_buffer = data_region_creation_addr;

	data_region_creation_addr += 4096;


	printk("nvme_read val before submitting identify cmd = {d}\n", *(volatile uint64_t *)partition_data_buffer);

	
	volatile char *nvme_iosqb_ptr = nvme_iosqb;
	uint32_t tmp, io_tail_val = 0;
	int64_t val2;
	uint8_t io_tail_val_8;

	// Build the command at the expected location in the Submission ring
	io_tail_val = *nvme_iotail; // Get the current io tail value

	io_tail_val *= 64;			// Quick multiply by 64
							//
	io_tail_val_8 = (uint8_t) io_tail_val;

	nvme_iosqb_ptr += io_tail_val_8;

	printk("@nvme_iosqb_ptr before = {d}\n", *(volatile uint64_t *) nvme_iosqb_ptr);

	// Build the structure
	*(volatile uint32_t *) nvme_iosqb_ptr = cdw0;	// CDW0
	*(volatile uint32_t *) (nvme_iosqb_ptr + 4) = cdw1;	// CDW1
	*(volatile uint32_t *) (nvme_iosqb_ptr + 8) = 0;	// CDW2
	*(volatile uint32_t *) (nvme_iosqb_ptr + 12) = 0;	// CDW3
	*(volatile uint64_t *) (nvme_iosqb_ptr + 16) = 0;	// CDW4-5
	*(volatile uint64_t *) (nvme_iosqb_ptr + 24) = (uint64_t) partition_data_buffer;	// CDW6-7
	*(volatile uint64_t *) (nvme_iosqb_ptr + 32) = 0;	// CDW8-9
	*(volatile uint64_t *) (nvme_iosqb_ptr + 40) = cdw10_11;	// CDW10_11
	*(volatile uint32_t *) (nvme_iosqb_ptr + 48) = cdw12;	// CDW12
	*(volatile uint32_t *) (nvme_iosqb_ptr + 52) = 0;	// CDW13
	*(volatile uint32_t *) (nvme_iosqb_ptr + 56) = 0;	// CDW14
	*(volatile uint32_t *) (nvme_iosqb_ptr + 60) = 0;	// CDW15
								//
	
	printk("@nvme_iosqb_ptr after = {d}\n", *(volatile uint64_t *) nvme_iosqb_ptr);

	// Start the read command by updating the tail doorbell
	io_tail_val = 0;
	io_tail_val = *nvme_iotail; // Get the current io tail value
	tmp = io_tail_val;	// Save the old io tail value for reading from the completion ring
	io_tail_val++;			// Add 1 to it
	
	if(io_tail_val>= 64)
		io_tail_val = 0;

	nvme_io_savetail(io_tail_val, nvme_iotail, tmp);


	printk("nvme_read val after submitting identify cmd = {p}\n", *(volatile uint64_t *)partition_data_buffer);

	// for(int i=0; i<2; i++)
	// 	printk("{c}", partition_data_buffer[i]);

	return partition_data_buffer;
}


/* 
 * set_admin_q_attrs
 *
 * set the Admin Queue Attributes (AQA) register for ACQS and ASQS values
 */
void set_admin_q_attrs(void)
{
	char nvme_aqa = 0x24;		// 4-byte AQA register offset
	volatile uint32_t *addr = (volatile uint32_t *) ((char *) nvme_base + nvme_aqa);
	uint32_t value = 0x003f003f;	// 64 commands each for ACQS (27:16) and ASQS (11:00).
					// Both are 0’s based values i.e. the value is 63.

	*addr = value;

	printk("@aqa register value={p}\n", (void *) *addr);
}

char *get_next_4096_aligned_addr(void)
{
	char *new_addr = data_region_creation_addr;

	while((((uint64_t) new_addr) % 4096) != 0) {
		new_addr++;
	}

	data_region_creation_addr = new_addr;

	return new_addr;
}

/*
 * configure_admin_q
 *
 * configure the admin queue
 */
int configure_admin_q(void)
{
	char nvme_asq = 0x28;   // 8-byte admin submission queue base address
	char nvme_acq = 0x30;	// 8-byte admin completion queue base address
	volatile uint64_t *addr_asq = (volatile uint32_t *) ((char *) nvme_base + nvme_asq);
	volatile uint64_t *addr_acq = (volatile uint32_t *) ((char *) nvme_base + nvme_acq);

	/* set the Admin Queue Attributes (AQA) register for ACQS and ASQS values */
	set_admin_q_attrs();

	/* get the next 4096 aligned address in the data region to be assigned as asqb */
	nvme_asqb = get_next_4096_aligned_addr();

	/* set data region creation address to the next 4096 aligned address */
	data_region_creation_addr = nvme_asqb + 4096;

	nvme_acqb = data_region_creation_addr;

	data_region_creation_addr = nvme_acqb + 4096;


	printk("@new asqb={p}\n", (volatile void *) nvme_asqb);
	printk("@new acqb={p}\n", (volatile void *) nvme_acqb);

	*addr_asq = (uint64_t) nvme_asqb;	// ASQB 4K aligned (63:12)
	*addr_acq = (uint64_t) nvme_acqb;	// ACQB 4K aligned (63:12)

	printk("@read asq register={p}\n", (volatile void *) *addr_asq);
	printk("@read acq register={p}\n", (volatile void *) *addr_acq);

	return 0;
}

/*
 * wait_for_reset_complete
 *
 * wait for the controller to indicate that the previous reset is complete by
 * waiting for CSTS.RDY to become ‘0'.
 */
int wait_for_reset_complete(void)
{
	char nvme_csts =  0x1C;			// 4-byte Controller Status (CSTS) register
	volatile uint32_t *addr = (volatile uint32_t *) ((char *) nvme_base + nvme_csts);
	uint32_t val;

	do {
		val = *addr;

		if((val & 0x2) != 0x0) {		// CSTS.CFS (bit #1) should be 0. If not the controller has had a fatal error
			return 1;
		}
	} while((val & 0x1) != 0x0);	// Wait for CSTS.RDY (bit #0) to become 0

	return 0;
}

void enable_controller(void)
{
	volatile uint32_t *addr = (volatile uint32_t *) ((char *) nvme_base + nvme_cc);
	uint32_t value;

	value = *addr;

	printk("@old CC value={d}\n", value);

	// set CC.EN (bit #0) to 1
	value |= 0x1;

	*addr = value;

	printk("@enable_controller: new CC value={d}\n", *addr);
}

int reset_controller(void)
{
	volatile uint32_t *addr = (volatile uint32_t *) ((char *) nvme_base + nvme_cc);
	uint32_t value;

	value = *addr;

	printk("@old CC value={d}\n", value);

	if((value & 0x1) != 0x0) {		// clear CC.EN (bit #0) to 0
		value &= 0xfffffffe;
		*addr = value;
	}

	printk("@new CC value={d}\n", *addr);

	/* wait for the reset to complete */
	return wait_for_reset_complete();
}

volatile uint64_t *get_nvme_base(uint16_t bus, uint8_t device, uint8_t function) {
	volatile char *phy_addr;
	uint32_t bar0_value, bar1_value;
	uint64_t base_addr;

	phy_addr = (volatile char *) ((uint64_t) pcie_ecam + (((uint32_t) bus) << 20 | ((uint32_t) device) << 15 | ((uint32_t) function) << 12));

	phy_addr = phy_addr + (4 * 4);	/* Multiplying by 4 because each register consists of 4 bytes */

	/* read register 4 for BAR0 */
	bar0_value = *(volatile uint32_t *) phy_addr;

	if((bar0_value & 0x6) == 0x4) {	// type (2:1) is 0x2 means the base register is 64-bits wide
		phy_addr += 4;	/* BAR1 is the register no. 5 */
		bar1_value = *(volatile uint32_t *) phy_addr;

		base_addr = bar1_value;
		base_addr <<= 32;		/* left shift 32 bits */
		base_addr |= (uint64_t) bar0_value;
	} else if((bar0_value & 0x6) == 0x0) {	/* type (2:1) is 0x0 means the base register is 32-bits wide */
		base_addr = bar0_value;
	}

	base_addr &= 0xfffffffffffffff0;		/* clear the lowest 4 bits */

	return (volatile uint64_t *) base_addr;
}


int find_nvme_controller(uint16_t bus, uint8_t device, uint8_t function) {
	volatile uint64_t *phy_addr;
	uint32_t value;

	phy_addr = (uint64_t *) ((uint64_t) pcie_ecam + (((uint32_t) bus) << 20 | ((uint32_t) device) << 15 | ((uint32_t) function) << 12));

	phy_addr = (uint64_t *) ((char *) phy_addr + 8);

	value = *(volatile uint32_t *) phy_addr;
	
	value = value >> 8;

	if(value == 0x00010802) /* class code = 0x1, subclass code = 0x8, prog if = 0x2 */
		return 0;
	else
		return 1;
}

uint16_t get_vendor_id(uint16_t bus, uint8_t device, uint8_t function)
{
	volatile uint64_t *phy_addr;
	uint16_t vendor_id;

	phy_addr = (uint64_t *) ((uint64_t) pcie_ecam + (((uint32_t) bus) << 20 | ((uint32_t) device) << 15 | ((uint32_t) function) << 12));

	vendor_id = *(volatile uint16_t *) phy_addr;

	return vendor_id;
}

int check_device(uint16_t bus, uint8_t device)
{
	uint8_t function = 0;
	uint16_t vendor_id;
	int res;

	vendor_id = get_vendor_id(bus, device, function);
	if (vendor_id == 0xFFFF)	/* device doesn't exist */
		return 1;

	res = find_nvme_controller(bus, device, function);	

	return res;
}

void check_all_buses(uint16_t start, uint16_t end)
{
     uint16_t bus;
     uint8_t device;	
     uint8_t found;

     found = 0;

     for(bus = start; bus <= end; bus++) {
         for(device = 0; device < 32; device++) {
		if(check_device(bus, device) == 0) {
			detected_bus_num = (int16_t) bus;
		 	detected_device_num = (int16_t) device;
			detected_function_num = 0;

			found = 1;
			break;
	 	}
        }
	if(found == 1) {
		 break;
	}
     }
}

/*
 * returns 0 if the checksum is valid.
 */
uint32_t check_mcfg_checksum(uint64_t *mcfg)
{
	uint32_t length;
	uint32_t sum;
	uint32_t i;

	sum = 0;

	length = *((uint32_t *) ((unsigned char *) mcfg + 4));

	for(i = 0; i < length; i++)
		sum += ((unsigned char *) mcfg)[i];

	return (sum & 0xff);
}

/*
 * returns 0 if the checksum is valid.
 */
unsigned char check_xsdt_checksum(uint64_t *xsdt, uint32_t xsdt_length)
{
    unsigned char sum;
    int i;

    sum = 0;

    for(i = 0; i < xsdt_length; i++) {
	sum += ((char *) xsdt)[i];
    }

    return sum;
}