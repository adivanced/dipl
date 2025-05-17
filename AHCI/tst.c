#include <stdio.h>

#define SIZE 15

int* all_vec(int sz){
	return (int*)calloc(sz, sizeof(int));
}


int main(){
	int vec[SIZE];


	for(int i = 0; i < SIZE; i++){
		vec[i] = i;
	}

	int* ptr_add = vec + 0x7 + 6;
	int* ptr_sub = ptr_add - 2;
	int cmp = ptr_sub < vec;

	printf("%d\n", *ptr_add);
	printf("%d\n", *ptr_sub);
	printf("%d\n", cmp);


}


