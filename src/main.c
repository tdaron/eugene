void print(const char*);
void putc(char a);
typedef unsigned int u32;
typedef unsigned char u8;



void sink(char* data) {
	print(data);
}

void kernel_main() {
	print("Hello from C code ! \n");
}

 __attribute__((constructor))
 void hey() {
 	print("[INIT] Doing stuff !\n");
 }

