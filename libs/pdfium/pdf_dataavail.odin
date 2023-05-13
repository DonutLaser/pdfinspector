package pdfium

import "core:c"

when ODIN_OS == .Windows {
	foreign import lib "lib/pdfium.dll.lib"
} else {
	foreign import lib "system:pdfium"
}

LINEARIZATION_UNKNOWN :: -1
NOT_LINEARIZED :: 0
LINEARIZED :: 1

DATA_ERROR :: -1
DATA_NOTAVAIL :: 0
DATA_AVAIL :: 1

FORM_ERROR :: -1
FORM_NOTAVAIL :: 0
FORM_AVAIL :: 1
FORM_NOTEXIST :: 2

// Interface for checking whether sections of the file are available.
FX_FILEAVAIL :: struct {
	// Version number of the interface. Must be 1.
	version:     c.int,

	// Reports if the specified data section is currently available. A section is
	// available if all bytes in the section are available.
	//
	// Interface Version: 1
	// Implementation Required: Yes
	//
	//   pThis  - pointer to the interface structure.
	//   offset - the offset of the data section in the file.
	//   size   - the size of the data section.
	//
	// Returns true if the specified data section at |offset| of |size|
	// is available.
	IsDataAvail: proc(pThis: ^FX_FILEAVAIL, offset: c.size_t, size: c.size_t) -> BOOL,
}

// Download hints interface. Used to receive hints for further downloading.
FX_DOWNLOADHINTS :: struct {
	// Version number of the interface. Must be 1.
	version:    c.int,

	// Add a section to be downloaded.
	//
	// Interface Version: 1
	// Implementation Required: Yes
	//
	//   pThis  - pointer to the interface structure.
	//   offset - the offset of the hint reported to be downloaded.
	//   size   - the size of the hint reported to be downloaded.
	//
	// The |offset| and |size| of the section may not be unique. Part of the
	// section might be already available. The download manager must deal with
	// overlapping sections.
	AddSegment: proc(pThis: ^FX_DOWNLOADHINTS, offset: c.size_t, size: c.size_t),
}

@(default_calling_convention = "c")
foreign lib {
	// Create a document availability provider.
	//
	//   file_avail - pointer to file availability interface.
	//   file       - pointer to a file access interface.
	//
	// Returns a handle to the document availability provider, or NULL on error.
	//
	// FPDFAvail_Destroy() must be called when done with the availability provider.
	@(link_name = "FPDFAvail_Create")
	avail_create :: proc(file_avail: ^FX_FILEAVAIL, file: ^FILEACCESS) -> ^AVAIL ---

	// Destroy the |avail| document availability provider.
	//
	//   avail - handle to document availability provider to be destroyed.
	@(link_name = "FPDFAvail_Destroy")
	avail_destroy :: proc(avail: ^AVAIL) ---

	// Checks if the document is ready for loading, if not, gets download hints.
	//
	//   avail - handle to document availability provider.
	//   hints - pointer to a download hints interface.
	//
	// Returns one of:
	//   PDF_DATA_ERROR: A common error is returned. Data availability unknown.
	//   PDF_DATA_NOTAVAIL: Data not yet available.
	//   PDF_DATA_AVAIL: Data available.
	//
	// Applications should call this function whenever new data arrives, and process
	// all the generated download hints, if any, until the function returns
	// |PDF_DATA_ERROR| or |PDF_DATA_AVAIL|.
	// if hints is nullptr, the function just check current document availability.
	//
	// Once all data is available, call FPDFAvail_GetDocument() to get a document
	// handle.
	@(link_name = "FPDFAvail_IsDocAvail")
	avail_is_doc_avail :: proc(avail: ^AVAIL, hints: ^FX_DOWNLOADHINTS) -> c.int ---

	// Get document from the availability provider.
	//
	//   avail    - handle to document availability provider.
	//   password - password for decrypting the PDF file. Optional.
	//
	// Returns a handle to the document.
	//
	// When FPDFAvail_IsDocAvail() returns TRUE, call FPDFAvail_GetDocument() to
	// retrieve the document handle.
	// See the comments for FPDF_LoadDocument() regarding the encoding for
	// |password|.
	@(link_name = "FPDFAvail_GetDocument")
	avail_get_document :: proc(avail: ^AVAIL, password: BYTESTRING) -> ^DOCUMENT ---

	// Get the page number for the first available page in a linearized PDF.
	//
	//   doc - document handle.
	//
	// Returns the zero-based index for the first available page.
	//
	// For most linearized PDFs, the first available page will be the first page,
	// however, some PDFs might make another page the first available page.
	// For non-linearized PDFs, this function will always return zero.
	@(link_name = "FPDFAvail_GetFirstPageNum")
	avail_get_first_page_num :: proc(doc: ^DOCUMENT) -> c.int ---

	// Check if |page_index| is ready for loading, if not, get the
	// |FX_DOWNLOADHINTS|.
	//
	//   avail      - handle to document availability provider.
	//   page_index - index number of the page. Zero for the first page.
	//   hints      - pointer to a download hints interface. Populated if
	//                |page_index| is not available.
	//
	// Returns one of:
	//   PDF_DATA_ERROR: A common error is returned. Data availability unknown.
	//   PDF_DATA_NOTAVAIL: Data not yet available.
	//   PDF_DATA_AVAIL: Data available.
	//
	// This function can be called only after FPDFAvail_GetDocument() is called.
	// Applications should call this function whenever new data arrives and process
	// all the generated download |hints|, if any, until this function returns
	// |PDF_DATA_ERROR| or |PDF_DATA_AVAIL|. Applications can then perform page
	// loading.
	// if hints is nullptr, the function just check current availability of
	// specified page.
	@(link_name = "FPDFAvail_IsPageAvail")
	avail_is_page_avail :: proc(avail: ^AVAIL, page_index: c.int, hints: ^FX_DOWNLOADHINTS) -> c.int ---

	// Check if form data is ready for initialization, if not, get the
	// |FX_DOWNLOADHINTS|.
	//
	//   avail - handle to document availability provider.
	//   hints - pointer to a download hints interface. Populated if form is not
	//           ready for initialization.
	//
	// Returns one of:
	//   PDF_FORM_ERROR: A common eror, in general incorrect parameters.
	//   PDF_FORM_NOTAVAIL: Data not available.
	//   PDF_FORM_AVAIL: Data available.
	//   PDF_FORM_NOTEXIST: No form data.
	//
	// This function can be called only after FPDFAvail_GetDocument() is called.
	// The application should call this function whenever new data arrives and
	// process all the generated download |hints|, if any, until the function
	// |PDF_FORM_ERROR|, |PDF_FORM_AVAIL| or |PDF_FORM_NOTEXIST|.
	// if hints is nullptr, the function just check current form availability.
	//
	// Applications can then perform page loading. It is recommend to call
	// FPDFDOC_InitFormFillEnvironment() when |PDF_FORM_AVAIL| is returned.
	@(link_name = "FPDFAvail_IsFormAvail")
	avail_is_form_avail :: proc(avail: ^AVAIL, hints: ^FX_DOWNLOADHINTS) -> c.int ---

	// Check whether a document is a linearized PDF.
	//
	//   avail - handle to document availability provider.
	//
	// Returns one of:
	//   PDF_LINEARIZED
	//   PDF_NOT_LINEARIZED
	//   PDF_LINEARIZATION_UNKNOWN
	//
	// FPDFAvail_IsLinearized() will return |PDF_LINEARIZED| or |PDF_NOT_LINEARIZED|
	// when we have 1k  of data. If the files size less than 1k, it returns
	// |PDF_LINEARIZATION_UNKNOWN| as there is insufficient information to determine
	// if the PDF is linearlized.
	@(link_name = "FPDFAvail_IsLinearized")
	avail_is_linearized :: proc(avail: ^AVAIL) -> c.int ---
}
