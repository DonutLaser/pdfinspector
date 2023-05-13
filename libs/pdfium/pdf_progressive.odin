package pdfium

import "core:c"

when ODIN_OS == .Windows {
	foreign import lib "lib/pdfium.dll.lib"
} else {
	foreign import lib "system:pdfium"
}

// Flags for progressive process status.
RENDER_READY :: 0
RENDER_TOBECONTINUED :: 1
RENDER_DONE :: 2
RENDER_FAILED :: 3

// IFPDF_RENDERINFO interface.
IFSDK_PAUSE :: struct {
	/*
   * Version number of the interface. Currently must be 1.
   */
	version:        c.int,

	/*
   * Method: NeedToPauseNow
   *           Check if we need to pause a progressive process now.
   * Interface Version:
   *           1
   * Implementation Required:
   *           yes
   * Parameters:
   *           pThis       -   Pointer to the interface structure itself
   * Return Value:
   *           Non-zero for pause now, 0 for continue.
   */
	NeedToPauseNow: proc(pThis: ^IFSDK_PAUSE) -> BOOL,

	// A user defined data pointer, used by user's application. Can be NULL.
	user:           rawptr,
}
