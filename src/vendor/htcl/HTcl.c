#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tcl.h>
#include "HsFFI.h"
#include "HTcl_stub.h"

// Export symbols
#ifdef __APPLE__
#define EXPORT __attribute__((visibility("default")))
#else
#define EXPORT
#endif

// TCL command handlers
static int
htcl_evalCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
{
    if (objc != 2) {
        Tcl_WrongNumArgs(interp, 1, objv, "script");
        return TCL_ERROR;
    }

    const char *script = Tcl_GetString(objv[1]);
    HsPtr result = hs_htcl_eval(script);
    
    if (result == NULL) {
        Tcl_SetResult(interp, "Error evaluating script", TCL_STATIC);
        return TCL_ERROR;
    }

    Tcl_SetResult(interp, (char*)result, TCL_DYNAMIC);
    return TCL_OK;
}

static int
htcl_loadCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
{
    if (objc != 2) {
        Tcl_WrongNumArgs(interp, 1, objv, "filename");
        return TCL_ERROR;
    }

    const char *filename = Tcl_GetString(objv[1]);
    HsPtr result = hs_htcl_load(filename);
    
    if (result == NULL) {
        Tcl_SetResult(interp, "Error loading file", TCL_STATIC);
        return TCL_ERROR;
    }

    Tcl_SetResult(interp, (char*)result, TCL_DYNAMIC);
    return TCL_OK;
}

// Initialize TCL bindings
EXPORT int
htcl_Init(Tcl_Interp *interp)
{
    if (Tcl_InitStubs(interp, TCL_VERSION, 1) == NULL) {
        return TCL_ERROR;
    }

    // Register commands
    Tcl_CreateObjCommand(interp, "htcl::eval", htcl_evalCmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "htcl::load", htcl_loadCmd, NULL, NULL);

    return TCL_OK;
}

// Cleanup function
EXPORT void
htcl_Cleanup(Tcl_Interp *interp)
{
    // Add any cleanup code here if needed
} 