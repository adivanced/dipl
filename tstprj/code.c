#include "exportfunc.h"



void user_main(struct exportfunc* ptr){
	ptr->get_MADT_BAR();

	ptr->conf_LAPIC();

	ptr->disable_PIC();

	uint64_t rval = ptr->init_hpet(1000, ptr->intfunc, 0, 0x22);

	uint64_t* counter = ptr->counter;
	ptr->print_func(ptr->tststr);

	uint64_t oldcounter = *counter;

	for(;;){
		if(*counter > oldcounter+1000){
			oldcounter = *counter;
			ptr->cvt2hex(ptr->tststr+34, oldcounter);
			ptr->print_func(ptr->tststr);
		}
	}
	
}