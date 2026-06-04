void print(const char*);
void putc(char a);
void register_func(void* func);
typedef unsigned int u32;
typedef unsigned char u8;

extern char __heap_start[];
extern char __heap_end[];


static char *heap_cur = __heap_start;

typedef struct Task task_t;
typedef struct Task {
	void* sp;
	task_t* nextTask;
} task_t;
void context_switch(task_t* old, task_t* new);

static task_t* firstTask = 0;
static task_t* currentTask = 0;

void *kalloc(u32 size) {
    size = (size + 7) & ~7; // align to 8
    if (heap_cur + size > __heap_end) {
        return 0;
    }

    void *p = heap_cur;
    heap_cur += size;
    return p;
}

int toto(int a, int b) {
	return a + b;
}

void print_digit(int d) {
	int c = d + 48;
	putc(c);
}


void* create_stack(void* func) {
	u8* mem = kalloc(4096);
	u32* stack = (u32*)(mem + (4096 - 64));
	stack[0] = (u32)func; // ra
	stack[1] = 0; // s0
	stack[2] = 0; // s1 
	stack[3] = 0; // s2
	stack[4] = 0; // s3
	stack[5] = 0; // s4
	stack[6] = 0; // s5
	stack[7] = 0; // s6
	stack[8] = 0; // s7
	stack[9] = 0; // s8
	stack[10] = 0; // s9
	stack[11] = 0; // s10
	stack[12] = 0; // s11
	return stack;
}

void register_func(void* func) {
	task_t* task = kalloc(sizeof(task_t));
	task->sp = create_stack(func);
	task->nextTask = firstTask;
	firstTask = task;
	print("Registered function\n");
}

void yield() {
	task_t* old = currentTask;
	currentTask = currentTask->nextTask;
	if (currentTask == 0) currentTask = firstTask;
	context_switch(old, currentTask);
	
}

void start() {
	currentTask = firstTask;
	context_switch(0, currentTask);
}

void funcA() {
	int i = 0;
	while (1) {
		i++;
		i = i % 20000;
		if (i == 0) {
			print("WHILE A\n");
			yield();
		}
	}
	
}
void funcB() {
	int i = 0;
	while (1) {
		i++;
		i = i % 20000;
		if (i == 0) {
			print("WHILE B\n");
			yield();
		}
	}
}

void funcC() {
	int i = 0;
	while (1) {
		i++;
		i = i % 20000;
		if (i == 0) {
			print("WHILE C\n");
			yield();
		}
	}
	
}


void sink(char* data) {
	print(data);
}

void kernel_main(u32 hartid, u32* dtb) {
	print("Hello from C code ! \n");
	print("Thread: ");
	print_digit(hartid);
	print("\n");
	print("Starting cooperative scheduler..\n");
	register_func(funcA);
	register_func(funcB);
	register_func(funcC);
	start();
}

 __attribute__((constructor))
 void hey() {
 	print("[INIT] Doing stuff !\n");
 }

