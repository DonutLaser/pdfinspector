package pdfium

import "core:c"

when ODIN_OS == .Windows {
	foreign import lib "lib/pdfium.dll.lib"
} else {
	foreign import lib "system:pdfium"
}

// Structure for custom file write
FILEWRITE :: struct {
	//
	// Version number of the interface. Currently must be 1.
	//
	version:    c.int,

	// Method: WriteBlock
	//          Output a block of data in your custom way.
	// Interface Version:
	//          1
	// Implementation Required:
	//          Yes
	// Comments:
	//          Called by function FPDF_SaveDocument
	// Parameters:
	//          pThis       -   Pointer to the structure itself
	//          pData       -   Pointer to a buffer to output
	//          size        -   The size of the buffer.
	// Return value:
	//          Should be non-zero if successful, zero for error.
	WriteBlock: proc(pThis: ^FILEWRITE, pData: rawptr, size: c.ulong) -> c.int,
}

// Flags for FPDF_SaveAsCopy()
INCREMENTAL :: 1
NO_INCREMENTAL :: 2
REMOVE_SECURITY :: 3
