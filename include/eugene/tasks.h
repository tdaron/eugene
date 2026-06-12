#pragma once
#include <eugene/types.h>

typedef struct {
	char* name;
	void* data;
	u32* tf;
} Task;


Task* create_task(char* name, void (*function)(void*), void* data);
#define TASKS_COUNT 3
extern Task TASKS[TASKS_COUNT];
extern u32 task_count;
extern u32 running_task;
