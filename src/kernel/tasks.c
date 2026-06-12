#include <eugene/types.h>
#include <eugene/macros.h>
#include <eugene/tasks.h>

#define TASKS_COUNT 256
Task TASKS[TASKS_COUNT] = {0};


// temporary malloc for now
extern char __heap_start[];
extern char __heap_end[];
u32 allocated;
void* malloc(u32 size) {
	allocated += size;
	return __heap_start + allocated - size;
}


#define TASK_STACK_SIZE  256
void* create_stack_frame(void (*ra)(void*)) {
	// points at the END of the stack
	u32* stack = (u32*)(malloc(TASK_STACK_SIZE) + TASK_STACK_SIZE);
	stack -= 13;
	stack[0] = (u32)ra;
	stack[1] = 0;
	stack[2] = 0;
	stack[3] = 0;
	stack[4] = 0;
	stack[5] = 0;
	stack[6] = 0;
	stack[7] = 0;
	stack[8] = 0;
	stack[9] = 0;
	stack[10] = 0;
	stack[11] = 0;
	stack[12] = 0;
	return stack; 
}

__attribute__((naked)) void switch_context(u32 **prev_sp,
                                           u32 **next_sp) {
    __asm__ __volatile__(
        // Save callee-saved registers onto the current process's stack.
        "beq x0, a0, 1f\n"
        "addi sp, sp, -13 * 4\n" // Allocate stack space for 13 4-byte registers
        "sw ra,  0  * 4(sp)\n"   // Save callee-saved registers only
        "sw s0,  1  * 4(sp)\n"
        "sw s1,  2  * 4(sp)\n"
        "sw s2,  3  * 4(sp)\n"
        "sw s3,  4  * 4(sp)\n"
        "sw s4,  5  * 4(sp)\n"
        "sw s5,  6  * 4(sp)\n"
        "sw s6,  7  * 4(sp)\n"
        "sw s7,  8  * 4(sp)\n"
        "sw s8,  9  * 4(sp)\n"
        "sw s9,  10 * 4(sp)\n"
        "sw s10, 11 * 4(sp)\n"
        "sw s11, 12 * 4(sp)\n"

        // Switch the stack pointer.
        "sw sp, (a0)\n"         // *prev_sp = sp;
		"1:\n"
        "lw sp, (a1)\n"         // Switch stack pointer (sp) here
        // Restore callee-saved registers from the next process's stack.
        "lw ra,  0  * 4(sp)\n"  // Restore callee-saved registers only
        "lw s0,  1  * 4(sp)\n"
        "lw s1,  2  * 4(sp)\n"
        "lw s2,  3  * 4(sp)\n"
        "lw s3,  4  * 4(sp)\n"
        "lw s4,  5  * 4(sp)\n"
        "lw s5,  6  * 4(sp)\n"
        "lw s6,  7  * 4(sp)\n"
        "lw s7,  8  * 4(sp)\n"
        "lw s8,  9  * 4(sp)\n"
        "lw s9,  10 * 4(sp)\n"
        "lw s10, 11 * 4(sp)\n"
        "lw s11, 12 * 4(sp)\n"
        "addi sp, sp, 13 * 4\n"  // We've popped 13 4-byte registers from the stack
        "ret\n"
    );
}


Task* create_task(char* name, void (*function)(void*), void* data) {
	// FIND WHERE TO PUT IT
	u32 i;
	for (i = 0; i < TASKS_COUNT; i++) {
		if (TASKS[i].sp == 0) {
			break;
		} 
	}
	if (i == TASKS_COUNT) PANIC("Maximum tasks number %d reached \n", TASKS_COUNT);
	printf("[KERNEL] Created task %s:%d\n", name, i);
	Task* task = &TASKS[i];
	task->name = name;
	task->data = data;
	printf("[ADDR]: %x\n" ,(u32)function);
	task->sp = create_stack_frame(function);

	switch_context(0, &task->sp);
	return &TASKS[i];
}



