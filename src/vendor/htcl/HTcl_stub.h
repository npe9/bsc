#ifndef HTCL_STUB_H
#define HTCL_STUB_H

#include "HsFFI.h"

// Forward declarations of Haskell functions
extern HsPtr hs_htcl_eval(const char* script);
extern HsPtr hs_htcl_load(const char* filename);

// TCL command wrappers
extern void zdmainzdHTclzdHTclzuwrapHTclDeleteCommand(void *cif, void* resp, void** args, void* the_stableptr);
extern void zdmainzdHTclzdHTclzuwrapHTclCommand(void *cif, void* resp, void** args, void* the_stableptr);

#endif /* HTCL_STUB_H */

