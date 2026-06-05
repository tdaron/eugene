#include <common.h>
#include <stdarg.h>
typedef void (*constructor)();

extern constructor __init_array_start[];
extern constructor __init_array_end[];

// This function will call every
// constructor annotated with
//  __attribute__((constructor))
//
void call_constructors() {
  for (constructor *ctor = __init_array_start; ctor < __init_array_end;
       ctor++) {
    (*ctor)();
  }
}

