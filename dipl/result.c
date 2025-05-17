#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>


uint64_t times[100];


int main(){
	//FILE* result = fopen("result.txt", "r");
	FILE* result = fopen("result_uefi.txt", "r");

	printf("work times: {");
	for(int i = 0; i < 100; i++){
		fscanf(result, "%ld", times+i);
		fread(times+i, 8, 1, result);
		if(i != 99){
			printf(" %ld,", times[i]);
		}else{
			printf(" %ld", times[i]);
		}
	}
	printf("}\n");

	uint64_t mean = 0;
	for(int i = 0; i < 100; i++){
		mean += times[i];
	}
	long double mean_fl = ((long double)mean)/100.0f;
	mean = (uint64_t)mean_fl;
	printf("mean: %Lf\n", mean_fl);

	uint64_t meanotkl = 0;
	for(int i = 0; i < 100; i++){
		meanotkl += abs(mean-times[i]);
	}
	long double meanotkl_fl = ((long double)meanotkl)/100.0f;
	printf("mean diff: %Lf\n", meanotkl_fl);

}