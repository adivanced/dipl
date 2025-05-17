// static fs compiler
// produces a .img binary file, that represents our filesystem
// also produces a .inc file, that describes the files statically


#include <stdio.h>
#include <dirent.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>


struct file_desc{
	char* path;
	char* os_name; // operating system filename
	char* img_name; // formatted filename
	uint64_t id; // file id
	uint64_t os_size; // size in os (bytes)
	uint64_t img_size; // size in img (in 4096 LBAs)
	uint64_t img_offs; // offs in img (in 4096 LBAs)
};

char tmpbuf[4096];

uint64_t FILE_ID = 0;
uint64_t FILE_OFFS = 0;

struct file_desc* descs = NULL;
uint64_t descs_n = 0;

char* format_name(char* str){
	uint64_t len = strlen(str);
	char* res = calloc(len+1+6, 1);
	memcpy(res, "file__", 6);
	char* j = res+6;
	for(char* i = str; *i != 0; i++){
		if(*i == ' ' || *i == '.'){*j='_';}else if(*i >= 'a' && *i <= 'z'){*j=*i-0x20;}else{*j=*i;}
		*j++;
	}
	return res;
}

// creates a .inc file that describes the static_fs
// %defines with each fname and id
// array with adresses
// array with ids
// array with sizes in 4096 sectors
// array with sizes in bytes
void create_asm_file(){
	FILE* asmfile = fopen("static_fs_defines.inc", "w+");
	for(struct file_desc* i = descs; i < descs + descs_n; i++){
		fwrite("%define ", 1, 8, asmfile);
		fwrite(i->img_name, 1, strlen(i->img_name), asmfile);
		fwrite(" ", 1, 1, asmfile);
		char tmp[20] = {0};
		snprintf(tmp, 20, "%ld", i->id);
		fwrite(tmp, 1, strlen(tmp), asmfile);
		fwrite("\n", 1, 1, asmfile);
	}	
	fclose(asmfile);

	asmfile = fopen("static_fs_data.inc", "w+");

	fwrite("static_fs_LBA dq ", 1, 17, asmfile);
	for(struct file_desc* i = descs; i < descs + descs_n; i++){
		char tmp[20] = {0};
		snprintf(tmp, 20, "%ld", i->img_offs);
		fwrite(tmp, 1, strlen(tmp), asmfile);
		if(i + 1 < descs+descs_n){
			fwrite(", ", 1, 2, asmfile);
		}
	}
	fwrite("\n", 1, 1, asmfile);

	// fwrite("static_fs_ID dq ", 1, 16, asmfile);
	// for(struct file_desc* i = descs; i < descs + descs_n; i++){
	// 	fwrite(i->img_name, 1, strlen(i->img_name), asmfile);		
	// 	if(i + 1 < descs+descs_n){
	// 		fwrite(", ", 1, 2, asmfile);
	// 	}		
	// }
	// fwrite("\n", 1, 1, asmfile);

	fwrite("static_fs_LBA_SZ dq ", 1, 20, asmfile);
	for(struct file_desc* i = descs; i < descs + descs_n; i++){
		char tmp[20] = {0};
		snprintf(tmp, 20, "%ld", i->img_size);
		fwrite(tmp, 1, strlen(tmp), asmfile);
		if(i + 1 < descs+descs_n){
			fwrite(", ", 1, 2, asmfile);
		}		
	}
	fwrite("\n", 1, 1, asmfile);

	fwrite("static_fs_BYTE_SZ dq ", 1, 21, asmfile);
	for(struct file_desc* i = descs; i < descs + descs_n; i++){
		char tmp[20] = {0};
		snprintf(tmp, 20, "%ld", i->os_size);
		fwrite(tmp, 1, strlen(tmp), asmfile);
		if(i + 1 < descs+descs_n){
			fwrite(", ", 1, 2, asmfile);
		}		
	}
	fwrite("\n", 1, 1, asmfile);

	fclose(asmfile);
}

void create_img_file(){
	FILE* imgfile = fopen("static_fs.img", "w+");
	for(struct file_desc* i = descs; i < descs + descs_n; i++){
		FILE* ifile = fopen(i->path, "r");
		uint64_t rlen = 0;
		while(rlen = fread(tmpbuf, 1, 4096, ifile)){
			fwrite(tmpbuf, 1, rlen, imgfile);
			if(rlen != 4096){
				for(uint64_t j = 0; j < 4096-rlen; j++){
					fwrite("\0", 1, 1, imgfile);
				}
			}
		}
		fclose(ifile);
	}
	fclose(imgfile);
}




int main(void){
	DIR* dir = opendir("files");
	struct dirent* dir_i;

	dir_i = readdir(dir);
	dir_i = readdir(dir);

	while((dir_i = readdir(dir)) != NULL){
		descs_n++;
		descs = realloc(descs, descs_n*sizeof(struct file_desc));
		descs[descs_n-1].os_name = dir_i->d_name;

		char* path = calloc(strlen(descs[descs_n-1].os_name)+6+1, 1);
		memcpy(path, "files/", 6);
		memcpy(path+6, descs[descs_n-1].os_name, strlen(descs[descs_n-1].os_name));
		descs[descs_n-1].path = path;

		descs[descs_n-1].img_name = format_name(descs[descs_n-1].os_name);

		descs[descs_n-1].id = FILE_ID;
		FILE_ID++;

		struct stat* stbf = malloc(sizeof(struct stat));
		stat(descs[descs_n-1].path, stbf);
		descs[descs_n-1].os_size = stbf->st_size;
		free(stbf);

		if(!(descs[descs_n-1].os_size%4096)){
			descs[descs_n-1].img_size = descs[descs_n-1].os_size/4096;
		}else{
			descs[descs_n-1].img_size = descs[descs_n-1].os_size/4096+1;
		}

		descs[descs_n-1].img_offs = FILE_OFFS;
		FILE_OFFS += descs[descs_n-1].img_size;
	}

	for(struct file_desc* i = descs; i < descs + descs_n; i++){
		printf("{path:%s os_name:%s img_name:%s id:%ld os_size:%ld img_size:%ld img_offs:%ld}\n", i->path, i->os_name, i->img_name, i->id, i->os_size, i->img_size, i->img_offs);
	}

	create_asm_file();

	create_img_file();

}