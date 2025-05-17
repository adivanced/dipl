#include <stdio.h>
#include <stdint.h>


uint64_t true_rand(uint64_t start, uint64_t end){
	register uint64_t r;
	asm("rdrand %0"
		:"=r"(r)
	);

	return start + r%(end-start+1);
}


int main(void){
	FILE* outfile = fopen("zephyr.txt", "w+");

	for(uint64_t i = 0; i < 100; i++){
		fprintf(outfile, "%ld\n", true_rand(12090, 12240));
	}



	return 0;
}