#include <stdint.h>
#include <string.h>
// gcc code.c -S -masm=intel -fcf-protection=none -fverbose-asm -fno-asynchronous-unwind-tables -fno-dwarf2-cfi-asm -ffreestanding -mno-red-zone -fshort-wchar 



void test(uint64_t* arr, uint64_t n){
	for(uint64_t i = 0; i < n; i++){
		arr[i] = arr[i] * arr[i]/100;
		if(i+1 < n){
			arr[i] *= arr[i+1]+1;
		}
		if(i-1 >= 0){			
			if(arr[i-1] != 0){
				arr[i] /= arr[i-1];
			}
		}
		for(uint64_t j = i+1; j < n; j++){
			if(arr[j]){
				arr[i] *= arr[j];
			}else{
				if(j%2){
					arr[j] += 2929;
				}else{
					arr[j] -= 9193810;
				}
			}
		}
		for(uint64_t j = 0; j < i; j++){
			if(arr[j]){
				arr[i] /= arr[j];
			}else{
				if(j%2){
					arr[j] += 203203;
				}else{
					arr[j] -= 199931283;
				}
			}
		}
	}
}

