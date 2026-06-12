#pragma once
#include <eugene/types.h>

typedef struct {
	char* name;
	void* data;
	u32* sp;
} Task;


Task* create_task(char* name, void (*function)(void*), void* data);

