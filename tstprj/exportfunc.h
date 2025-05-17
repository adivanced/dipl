#include <stdint.h>

struct exportfunc{

	void** EFI_SYSTEM_TABLE;
	void* intfunc;
	uint64_t* counter;
	long long int (*init_hpet)(uint64_t frequency_rax, void* int_vec_rbx, uint64_t timerN_rcx, uint64_t intN_rdx);
	void (*print_func)(char* str_rax);
	char* tststr;
	void (*cvt2hex)(char* strend_rdi, uint64_t number_rax);
	void (*get_MADT_BAR)();
	void (*conf_LAPIC)();
	void (*disable_PIC)();
};
