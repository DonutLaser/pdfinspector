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
	// Get the number of embedded files in |document|.
	//
	//   document - handle to a document.
	//
	// Returns the number of embedded files in |document|.
	@(link_name = "FPDFDoc_GetAttachmentCount")
	doc_get_attachment_count :: proc(document: ^DOCUMENT) -> c.int ---

	// Experimental API.
	// Add an embedded file with |name| in |document|. If |name| is empty, or if
	// |name| is the name of a existing embedded file in |document|, or if
	// |document|'s embedded file name tree is too deep (i.e. |document| has too
	// many embedded files already), then a new attachment will not be added.
	//
	//   document - handle to a document.
	//   name     - name of the new attachment.
	//
	// Returns a handle to the new attachment object, or NULL on failure.
	@(link_name = "FPDFDoc_AddAttachment")
	doc_add_attachment :: proc(document: ^DOCUMENT, name: WIDESTRING) -> ^ATTACHMENT ---

	// Experimental API.
	// Get the embedded attachment at |index| in |document|. Note that the returned
	// attachment handle is only valid while |document| is open.
	//
	//   document - handle to a document.
	//   index    - the index of the requested embedded file.
	//
	// Returns the handle to the attachment object, or NULL on failure.
	@(link_name = "FPDFDoc_GetAttachment")
	doc_get_attachment :: proc(document: ^DOCUMENT, index: c.int) -> ^ATTACHMENT ---

	// Experimental API.
	// Delete the embedded attachment at |index| in |document|. Note that this does
	// not remove the attachment data from the PDF file; it simply removes the
	// file's entry in the embedded files name tree so that it does not appear in
	// the attachment list. This behavior may change in the future.
	//
	//   document - handle to a document.
	//   index    - the index of the embedded file to be deleted.
	//
	// Returns true if successful.
	@(link_name = "FPDFDoc_DeleteAttachment")
	doc_delete_attachment :: proc(document: ^DOCUMENT, index: c.int) -> BOOL ---

	// Get the document's PageMode.
	//
	//   doc - Handle to document.
	//
	// Returns one of the |PAGEMODE_*| flags defined above.
	//
	// The page mode defines how the document should be initially displayed.
	@(link_name = "FPDFDoc_GetPageMode")
	doc_get_page_mode :: proc(document: ^DOCUMENT) -> c.int ---

	/*
	* Function: FPDFDOC_InitFormFillEnvironment
	*       Initialize form fill environment.
	* Parameters:
	*       document        -   Handle to document from FPDF_LoadDocument().
	*       formInfo        -   Pointer to a FPDF_FORMFILLINFO structure.
	* Return Value:
	*       Handle to the form fill module, or NULL on failure.
	* Comments:
	*       This function should be called before any form fill operation.
	*       The FPDF_FORMFILLINFO passed in via |formInfo| must remain valid until
	*       the returned FPDF_FORMHANDLE is closed.
	*/
	@(link_name = "FPDFDOC_InitFormFillEnvironment")
	doc_init_form_fill_environment :: proc(document: ^DOCUMENT, formInfo: ^FORMFILLINFO) -> ^FORMHANDLE ---

	/*
	* Function: FPDFDOC_ExitFormFillEnvironment
	*       Take ownership of |hHandle| and exit form fill environment.
	* Parameters:
	*       hHandle     -   Handle to the form fill module, as returned by
	*                       FPDFDOC_InitFormFillEnvironment().
	* Return Value:
	*       None.
	* Comments:
	*       This function is a no-op when |hHandle| is null.
	*/
	@(link_name = "FPDFDOC_ExitFormFillEnvironment")
	doc_exit_form_fill_environment :: proc(hHandle: ^FORMHANDLE) ---

	// Experimental API.
	// Get the number of JavaScript actions in |document|.
	//
	//   document - handle to a document.
	//
	// Returns the number of JavaScript actions in |document| or -1 on error.
	@(link_name = "FPDFDoc_GetJavaScriptActionCount")
	doc_get_javascript_action_count :: proc(document: ^DOCUMENT) -> c.int ---

	// Experimental API.
	// Get the JavaScript action at |index| in |document|.
	//
	//   document - handle to a document.
	//   index    - the index of the requested JavaScript action.
	//
	// Returns the handle to the JavaScript action, or NULL on failure.
	// Caller owns the returned handle and must close it with
	// FPDFDoc_CloseJavaScriptAction().
	@(link_name = "FPDFDoc_GetJavaScriptAction")
	doc_get_javascript_action :: proc(document: ^DOCUMENT, index: c.int) -> ^JAVASCRIPT_ACTION ---

	// Experimental API.
	// Close a loaded FPDF_JAVASCRIPT_ACTION object.
	//   javascript - Handle to a JavaScript action.
	@(link_name = "FPDFDoc_CloseJavaScriptAction")
	doc_close_javascript_action :: proc(javascript: ^JAVASCRIPT_ACTION) ---

}

@(default_calling_convention = "c")
foreign lib {
	// Experimental API.
	// Get the name of the |attachment| file. |buffer| is only modified if |buflen|
	// is longer than the length of the file name. On errors, |buffer| is unmodified
	// and the returned length is 0.
	//
	//   attachment - handle to an attachment.
	//   buffer     - buffer for holding the file name, encoded in UTF-16LE.
	//   buflen     - length of the buffer in bytes.
	//
	// Returns the length of the file name in bytes.
	@(link_name = "FPDFAttachment_GetName")
	attachment_get_name :: proc(attachment: ^ATTACHMENT, buffer: ^WCHAR, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Check if the params dictionary of |attachment| has |key| as a key.
	//
	//   attachment - handle to an attachment.
	//   key        - the key to look for, encoded in UTF-8.
	//
	// Returns true if |key| exists.
	@(link_name = "FPDFAttachment_HasKey")
	attachment_has_key :: proc(attachment: ^ATTACHMENT, key: BYTESTRING) -> BOOL ---

	// Experimental API.
	// Get the type of the value corresponding to |key| in the params dictionary of
	// the embedded |attachment|.
	//
	//   attachment - handle to an attachment.
	//   key        - the key to look for, encoded in UTF-8.
	//
	// Returns the type of the dictionary value.
	@(link_name = "FPDFAttachment_GetValueType")
	attachment_get_value_type :: proc(attachment: ^ATTACHMENT, key: BYTESTRING) -> OBJECT_TYPE ---

	// Experimental API.
	// Set the string value corresponding to |key| in the params dictionary of the
	// embedded file |attachment|, overwriting the existing value if any. The value
	// type should be FPDF_OBJECT_STRING after this function call succeeds.
	//
	//   attachment - handle to an attachment.
	//   key        - the key to the dictionary entry, encoded in UTF-8.
	//   value      - the string value to be set, encoded in UTF-16LE.
	//
	// Returns true if successful.
	@(link_name = "FPDFAttachment_SetStringValue")
	attachment_set_string_value :: proc(attachment: ^ATTACHMENT, key: BYTESTRING, value: WIDESTRING) -> BOOL ---

	// Experimental API.
	// Get the string value corresponding to |key| in the params dictionary of the
	// embedded file |attachment|. |buffer| is only modified if |buflen| is longer
	// than the length of the string value. Note that if |key| does not exist in the
	// dictionary or if |key|'s corresponding value in the dictionary is not a
	// string (i.e. the value is not of type FPDF_OBJECT_STRING or
	// FPDF_OBJECT_NAME), then an empty string would be copied to |buffer| and the
	// return value would be 2. On other errors, nothing would be added to |buffer|
	// and the return value would be 0.
	//
	//   attachment - handle to an attachment.
	//   key        - the key to the requested string value, encoded in UTF-8.
	//   buffer     - buffer for holding the string value encoded in UTF-16LE.
	//   buflen     - length of the buffer in bytes.
	//
	// Returns the length of the dictionary value string in bytes.
	@(link_name = "FPDFAttachment_GetStringValue")
	attachment_get_string_value :: proc(attachment: ^ATTACHMENT, key: BYTESTRING, buffer: ^WCHAR, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Set the file data of |attachment|, overwriting the existing file data if any.
	// The creation date and checksum will be updated, while all other dictionary
	// entries will be deleted. Note that only contents with |len| smaller than
	// INT_MAX is supported.
	//
	//   attachment - handle to an attachment.
	//   contents   - buffer holding the file data to write to |attachment|.
	//   len        - length of file data in bytes.
	//
	// Returns true if successful.
	@(link_name = "FPDFAttachment_SetFile")
	attachment_set_file :: proc(attachment: ^ATTACHMENT, document: ^DOCUMENT, contents: rawptr, len: c.ulong) -> BOOL ---

	// Experimental API.
	// Get the file data of |attachment|.
	// When the attachment file data is readable, true is returned, and |out_buflen|
	// is updated to indicate the file data size. |buffer| is only modified if
	// |buflen| is non-null and long enough to contain the entire file data. Callers
	// must check both the return value and the input |buflen| is no less than the
	// returned |out_buflen| before using the data.
	//
	// Otherwise, when the attachment file data is unreadable or when |out_buflen|
	// is null, false is returned and |buffer| and |out_buflen| remain unmodified.
	//
	//   attachment - handle to an attachment.
	//   buffer     - buffer for holding the file data from |attachment|.
	//   buflen     - length of the buffer in bytes.
	//   out_buflen - pointer to the variable that will receive the minimum buffer
	//                size to contain the file data of |attachment|.
	//
	// Returns true on success, false otherwise.
	@(link_name = "FPDFAttachment_GetFile")
	attachment_get_file :: proc(attachment: ^ATTACHMENT, buffer: rawptr, buflen: c.ulong, out_buflen: ^c.ulong) -> BOOL ---
}
