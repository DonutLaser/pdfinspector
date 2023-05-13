package pdfium

import "core:c"

when ODIN_OS == .Windows {
	foreign import lib "lib/pdfium.dll.lib"
} else {
	foreign import lib "system:pdfium"
}

@(default_calling_convention = "c")
foreign lib {
	/**
	* Experimental API.
	*
	* Determine if |document| represents a tagged PDF.
	*
	* For the definition of tagged PDF, See (see 10.7 "Tagged PDF" in PDF
	* Reference 1.7).
	*
	*   document - handle to a document.
	*
	* Returns |true| iff |document| is a tagged PDF.
	*/
	@(link_name = "FPDFCatalog_IsTagged")
	catalog_is_tagged :: proc(document: ^DOCUMENT) -> BOOL ---
}
