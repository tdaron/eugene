#pragma once
#include <eugene/types.h>
void init_platform();
void setup_traps();
void alarm_millis(u32 millis);
extern char platform_name[];
