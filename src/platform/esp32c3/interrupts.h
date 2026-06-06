#pragma once
#include <eugene/types.h>

void set_interrupt_threshold(u32 threshold);
void route_interrupt(volatile u32 *interrupt, u32 trap_number, u32 priority);

