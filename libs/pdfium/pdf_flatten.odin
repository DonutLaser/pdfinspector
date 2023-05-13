package pdfium

import "core:c"
import "core:time"

when ODIN_OS == .Windows {
	foreign import lib "lib/pdfium.dll.lib"
} else {
	foreign import lib "system:pdfium"
}

// Flatten operation failed.
FLATTEN_FAIL :: 0
// Flatten operation succeed.
FLATTEN_SUCCESS :: 1
// Nothing to be flattened.
FLATTEN_NOTHINGTODO :: 2

// Flatten for normal display.
FLAT_NORMALDISPLAY :: 0
// Flatten for print.
FLAT_PRINT :: 1
