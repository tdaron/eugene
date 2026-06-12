#include <eugene/types.h>
#include <eugene/macros.h>
#include <eugene/tasks.h>
#include <arch/arch.h>

Task TASKS[TASKS_COUNT] = {0};
u32 task_count = 0;
u32 running_task = 0;

Task* create_task(char* name, void (*function)(void*), void* data) {
	// FIND WHERE TO PUT IT
	u32 i;
	for (i = 0; i < TASKS_COUNT; i++) {
		if (TASKS[i].tf == 0) {
			break;
		} 
	}
	if (i == TASKS_COUNT) PANIC("Maximum tasks number %d reached \n", TASKS_COUNT);
	printf("[KERNEL] Created task %s:%d\n", name, i);
	Task* task = &TASKS[i];
	task->name = name;
	task->data = data;
	task->tf = initial_task_trap_frame(function);
	task_count += 1;

	return &TASKS[i];
}



