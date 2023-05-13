package pdfium

import "core:c"

when ODIN_OS == .Windows {
	foreign import lib "lib/pdfium.dll.lib"
} else {
	foreign import lib "system:pdfium"
}

@(default_calling_convention = "c")
foreign lib {
	// Experimental API.
	// Get the name from the |javascript| handle. |buffer| is only modified if
	// |buflen| is longer than the length of the name. On errors, |buffer| is
	// unmodified and the returned length is 0.
	//
	//   javascript - handle to an JavaScript action.
	//   buffer     - buffer for holding the name, encoded in UTF-16LE.
	//   buflen     - length of the buffer in bytes.
	//
	// Returns the length of the JavaScript action name in bytes.
	@(link_name = "FPDFJavaScriptAction_GetName")
	javascriptaction_get_name :: proc(javascript: ^JAVASCRIPT_ACTION, buffer: ^WCHAR, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Get the script from the |javascript| handle. |buffer| is only modified if
	// |buflen| is longer than the length of the script. On errors, |buffer| is
	// unmodified and the returned length is 0.
	//
	//   javascript - handle to an JavaScript action.
	//   buffer     - buffer for holding the name, encoded in UTF-16LE.
	//   buflen     - length of the buffer in bytes.
	//
	// Returns the length of the JavaScript action name in bytes.
	@(link_name = "FPDFJavaScriptAction_GetScript")
	javascriptaction_get_script :: proc(javascript: ^JAVASCRIPT_ACTION, buffer: ^WCHAR, buflen: c.ulong) -> c.ulong ---
}
