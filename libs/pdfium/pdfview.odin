package pdfium

import "core:c"
import "core:os"

when ODIN_OS == .Windows {
	foreign import lib "lib/pdfium.dll.lib"
} else {
	foreign import lib "system:pdfium"
}

// PDF object types
OBJECT_UNKNOWN :: 0
OBJECT_BOOLEAN :: 1
OBJECT_NUMBER :: 2
OBJECT_STRING :: 3
OBJECT_NAME :: 4
OBJECT_ARRAY :: 5
OBJECT_DICTIONARY :: 6
OBJECT_STREAM :: 7
OBJECT_NULLOBJ :: 8
OBJECT_REFERENCE :: 9

// PDF text rendering modes
TEXT_RENDERMODE :: enum {
	UNKNOWN          = -1,
	FILL             = 0,
	STROKE           = 1,
	FILL_STROKE      = 2,
	INVISIBLE        = 3,
	FILL_CLIP        = 4,
	STROKE_CLIP      = 5,
	FILL_STROKE_CLIP = 6,
	CLIP             = 7,
	LAST             = 7,
}

// PDF types - use incomplete types (never completed) to force API type safety.
ACTION :: struct {}
ANNOTATION :: struct {}
ATTACHMENT :: struct {}
AVAIL :: struct {}
BITMAP :: struct {}
BOOKMARK :: struct {}
CLIPPATH :: struct {}
DEST :: struct {}
DOCUMENT :: struct {}
FONT :: struct {}
FORMHANDLE :: struct {}
GLYPHPATH :: struct {}
JAVASCRIPT_ACTION :: struct {}
LINK :: struct {}
PAGE :: struct {}
PAGELINK :: struct {}
PAGEOBJECT :: struct {}
PAGEOBJECTMARK :: struct {}
PAGERANGE :: struct {}
PATHSEGMENT :: struct {}
RECORDER :: rawptr
SCHANDLE :: struct {}
SIGNATURE :: struct {}
STRUCTELEMENT :: struct {}
STRUCTELEMENT_ATTR :: struct {}
STRUCTTREE :: struct {}
TEXTPAGE :: struct {}
WIDGET :: struct {}
XOBJECT :: struct {}

// Basic data types
BOOL :: c.int
RESULT :: c.int
DWORD :: c.ulong
FLOAT :: f32

// Duplex types
DUPLEXTYPE :: enum {
	DuplexUndefined,
	Simplex,
	DuplexFlipShortEdge,
	DuplexFlipLongEdge,
}

// String types
WCHAR :: c.ushort

// FPDFSDK may use three types of strings: byte string, wide string (UTF-16LE
// encoded), and platform dependent string
BYTESTRING :: cstring

// FPDFSDK always uses UTF-16LE encoded wide strings, each character uses 2
// bytes (except surrogation), with the low byte first.
WIDESTRING :: ^WCHAR

// Structure for persisting a string beyond the duration of a callback.
// Note: although represented as a char*, string may be interpreted as
// a UTF-16LE formated string. Used only by XFA callbacks.
BSTR :: struct {
	str: string,
	len: c.int,
}

// For Windows programmers: In most cases it's OK to treat FPDF_WIDESTRING as a
// Windows unicode string, however, special care needs to be taken if you
// expect to process Unicode larger than 0xffff.
//
// For Linux/Unix programmers: most compiler/library environments use 4 bytes
// for a Unicode character, and you have to convert between FPDF_WIDESTRING and
// system wide string by yourself.
STRING :: cstring

// Matrix for transformation, in the form [a b c d e f], equivalent to:
// | a  b  0 |
// | c  d  0 |
// | e  f  1 |
//
// Translation is performed with [1 0 0 1 tx ty].
// Scaling is performed with [sx 0 0 sy 0 0].
// See PDF Reference 1.7, 4.2.2 Common Transformations for more.
MATRIX :: struct {
	a: f32,
	b: f32,
	c: f32,
	d: f32,
	e: f32,
	f: f32,
}

// Rectangle area(float) in device or page coordinate system.
RECTF :: struct {
	// The x-coordinate of the left-top corner.
	left:   c.float,
	top:    c.float,
	right:  c.float,
	bottom: c.float,
}

// Rectangle size. Coordinate system agnostic.
SIZEF :: struct {
	width:  c.float,
	height: c.float,
}

// 2D Point. Coordinate system agnostic.
POINTF :: struct {
	x: c.float,
	y: c.float,
}

QUADPOINTSF :: struct {
	x1: FLOAT,
	y1: FLOAT,
	x2: FLOAT,
	y2: FLOAT,
	x3: FLOAT,
	y3: FLOAT,
	x4: FLOAT,
	y4: FLOAT,
}

ANNOTATION_SUBTYPE :: c.int
ANNOT_APPEARANCEMODE :: c.int

// Dictionary value types.
OBJECT_TYPE :: c.int

@(default_calling_convention = "c")
foreign lib {
	// Function: FPDF_InitLibrary
	//          Initialize the FPDFSDK library
	// Parameters:
	//          None
	// Return value:
	//          None.
	// Comments:
	//          Convenience function to call FPDF_InitLibraryWithConfig() for
	//          backwards compatibility purposes. This will be deprecated in the
	//          future.
	@(link_name = "FPDF_InitLibrary")
	init_library :: proc() ---

	// Function: FPDF_InitLibraryWithConfig
	//          Initialize the FPDFSDK library
	// Parameters:
	//          config - configuration information as above.
	// Return value:
	//          None.
	// Comments:
	//          You have to call this function before you can call any PDF
	//          processing functions.
	@(link_name = "FPDF_InitLibraryWithConfig")
	init_library_with_config :: proc(config: ^LIBRARY_CONFIG) ---

	// Function: FPDF_DestroyLibary
	//          Release all resources allocated by the FPDFSDK library.
	// Parameters:
	//          None.
	// Return value:
	//          None.
	// Comments:
	//          You can call this function to release all memory blocks allocated by
	//          the library.
	//          After this function is called, you should not call any PDF
	//          processing functions.
	@(link_name = "FPDF_DestroyLibrary")
	destroy_library :: proc() ---

	// Function: FPDF_SetSandBoxPolicy
	//          Set the policy for the sandbox environment.
	// Parameters:
	//          policy -   The specified policy for setting, for example:
	//                     FPDF_POLICY_MACHINETIME_ACCESS.
	//          enable -   True to enable, false to disable the policy.
	// Return value:
	//          None.
	@(link_name = "FPDF_FPDFSetSandBoxPolicy")
	set_sandbox_policy :: proc(policy: DWORD, enable: BOOL) ---

	// Function: FPDF_LoadDocument
	//          Open and load a PDF document.
	// Parameters:
	//          file_path -  Path to the PDF file (including extension).
	//          password  -  A string used as the password for the PDF file.
	//                       If no password is needed, empty or NULL can be used.
	//                       See comments below regarding the encoding.
	// Return value:
	//          A handle to the loaded document, or NULL on failure.
	// Comments:
	//          Loaded document can be closed by FPDF_CloseDocument().
	//          If this function fails, you can use FPDF_GetLastError() to retrieve
	//          the reason why it failed.
	//
	//          The encoding for |file_path| is UTF-8.
	//
	//          The encoding for |password| can be either UTF-8 or Latin-1. PDFs,
	//          depending on the security handler revision, will only accept one or
	//          the other encoding. If |password|'s encoding and the PDF's expected
	//          encoding do not match, FPDF_LoadDocument() will automatically
	//          convert |password| to the other encoding.
	@(link_name = "FPDF_LoadDocument")
	load_document :: proc(file_path: STRING, password: BYTESTRING) -> ^DOCUMENT ---

	// Function: FPDF_LoadMemDocument
	//          Open and load a PDF document from memory.
	// Parameters:
	//          data_buf    -   Pointer to a buffer containing the PDF document.
	//          size        -   Number of bytes in the PDF document.
	//          password    -   A string used as the password for the PDF file.
	//                          If no password is needed, empty or NULL can be used.
	// Return value:
	//          A handle to the loaded document, or NULL on failure.
	// Comments:
	//          The memory buffer must remain valid when the document is open.
	//          The loaded document can be closed by FPDF_CloseDocument.
	//          If this function fails, you can use FPDF_GetLastError() to retrieve
	//          the reason why it failed.
	//
	//          See the comments for FPDF_LoadDocument() regarding the encoding for
	//          |password|.
	// Notes:
	//          If PDFium is built with the XFA module, the application should call
	//          FPDF_LoadXFA() function after the PDF document loaded to support XFA
	//          fields defined in the fpdfformfill.h file.
	@(link_name = "FPDF_LoadMemDocument")
	load_mem_document :: proc(data_buf: rawptr, size: c.int, password: BYTESTRING) -> ^DOCUMENT ---

	// Experimental API.
	// Function: FPDF_LoadMemDocument64
	//          Open and load a PDF document from memory.
	// Parameters:
	//          data_buf    -   Pointer to a buffer containing the PDF document.
	//          size        -   Number of bytes in the PDF document.
	//          password    -   A string used as the password for the PDF file.
	//                          If no password is needed, empty or NULL can be used.
	// Return value:
	//          A handle to the loaded document, or NULL on failure.
	// Comments:
	//          The memory buffer must remain valid when the document is open.
	//          The loaded document can be closed by FPDF_CloseDocument.
	//          If this function fails, you can use FPDF_GetLastError() to retrieve
	//          the reason why it failed.
	//
	//          See the comments for FPDF_LoadDocument() regarding the encoding for
	//          |password|.
	// Notes:
	//          If PDFium is built with the XFA module, the application should call
	//          FPDF_LoadXFA() function after the PDF document loaded to support XFA
	//          fields defined in the fpdfformfill.h file.
	@(link_name = "FPDF_LoadMemDocument64")
	load_mem_document64 :: proc(data_buf: rawptr, size: c.int, password: BYTESTRING) -> ^DOCUMENT ---

	// Function: FPDF_LoadCustomDocument
	//          Load PDF document from a custom access descriptor.
	// Parameters:
	//          pFileAccess -   A structure for accessing the file.
	//          password    -   Optional password for decrypting the PDF file.
	// Return value:
	//          A handle to the loaded document, or NULL on failure.
	// Comments:
	//          The application must keep the file resources |pFileAccess| points to
	//          valid until the returned FPDF_DOCUMENT is closed. |pFileAccess|
	//          itself does not need to outlive the FPDF_DOCUMENT.
	//
	//          The loaded document can be closed with FPDF_CloseDocument().
	//
	//          See the comments for FPDF_LoadDocument() regarding the encoding for
	//          |password|.
	// Notes:
	//          If PDFium is built with the XFA module, the application should call
	//          FPDF_LoadXFA() function after the PDF document loaded to support XFA
	//          fields defined in the fpdfformfill.h file.
	@(link_name = "FPDF_LoadCustomDocument")
	load_custom_document :: proc(pFileAccess: ^FILEACCESS, password: BYTESTRING) -> ^DOCUMENT ---

	// Function: FPDF_GetFileVersion
	//          Get the file version of the given PDF document.
	// Parameters:
	//          doc         -   Handle to a document.
	//          fileVersion -   The PDF file version. File version: 14 for 1.4, 15
	//                          for 1.5, ...
	// Return value:
	//          True if succeeds, false otherwise.
	// Comments:
	//          If the document was created by FPDF_CreateNewDocument,
	//          then this function will always fail.
	@(link_name = "FPDF_GetFileVersion")
	get_file_version :: proc(doc: ^DOCUMENT, fileVersion: ^c.int) -> BOOL ---

	// Function: FPDF_GetLastError
	//          Get last error code when a function fails.
	// Parameters:
	//          None.
	// Return value:
	//          A 32-bit integer indicating error code as defined above.
	// Comments:
	//          If the previous SDK call succeeded, the return value of this
	//          function is not defined. This function only works in conjunction
	//          with APIs that mention FPDF_GetLastError() in their documentation.
	@(link_name = "FPDF_GetLastError")
	get_last_error :: proc() -> c.ulong ---

	// Experimental API.
	// Function: FPDF_DocumentHasValidCrossReferenceTable
	//          Whether the document's cross reference table is valid or not.
	// Parameters:
	//          document    -   Handle to a document. Returned by FPDF_LoadDocument.
	// Return value:
	//          True if the PDF parser did not encounter problems parsing the cross
	//          reference table. False if the parser could not parse the cross
	//          reference table and the table had to be rebuild from other data
	//          within the document.
	// Comments:
	//          The return value can change over time as the PDF parser evolves.
	@(link_name = "FPDF_DocumentHasValidCrossReferenceTable")
	document_has_valid_cross_reference_table :: proc(document: ^DOCUMENT) -> BOOL ---

	// Experimental API.
	// Function: FPDF_GetTrailerEnds
	//          Get the byte offsets of trailer ends.
	// Parameters:
	//          document    -   Handle to document. Returned by FPDF_LoadDocument().
	//          buffer      -   The address of a buffer that receives the
	//                          byte offsets.
	//          length      -   The size, in ints, of |buffer|.
	// Return value:
	//          Returns the number of ints in the buffer on success, 0 on error.
	//
	// |buffer| is an array of integers that describes the exact byte offsets of the
	// trailer ends in the document. If |length| is less than the returned length,
	// or |document| or |buffer| is NULL, |buffer| will not be modified.
	@(link_name = "FPDF_GetTrailerEnds")
	get_trailer_ends :: proc(document: ^DOCUMENT, buffer: ^c.uint, length: c.ulong) -> c.ulong ---

	// Function: FPDF_GetDocPermission
	//          Get file permission flags of the document.
	// Parameters:
	//          document    -   Handle to a document. Returned by FPDF_LoadDocument.
	// Return value:
	//          A 32-bit integer indicating permission flags. Please refer to the
	//          PDF Reference for detailed descriptions. If the document is not
	//          protected, 0xffffffff will be returned.
	@(link_name = "FPDF_GetDocPermissions")
	get_doc_permissions :: proc(document: ^DOCUMENT) -> c.ulong ---

	// Function: FPDF_GetSecurityHandlerRevision
	//          Get the revision for the security handler.
	// Parameters:
	//          document    -   Handle to a document. Returned by FPDF_LoadDocument.
	// Return value:
	//          The security handler revision number. Please refer to the PDF
	//          Reference for a detailed description. If the document is not
	//          protected, -1 will be returned.
	@(link_name = "FPDF_GetSecurityHandlerRevision")
	get_security_handler_revision :: proc(document: ^DOCUMENT) -> c.int ---

	// Function: FPDF_GetPageCount
	//          Get total number of pages in the document.
	// Parameters:
	//          document    -   Handle to document. Returned by FPDF_LoadDocument.
	// Return value:
	//          Total number of pages in the document.
	@(link_name = "FPDF_GetPageCount")
	get_page_count :: proc(document: ^DOCUMENT) -> c.int ---

	// Function: FPDF_LoadPage
	//          Load a page inside the document.
	// Parameters:
	//          document    -   Handle to document. Returned by FPDF_LoadDocument
	//          page_index  -   Index number of the page. 0 for the first page.
	// Return value:
	//          A handle to the loaded page, or NULL if page load fails.
	// Comments:
	//          The loaded page can be rendered to devices using FPDF_RenderPage.
	//          The loaded page can be closed using FPDF_ClosePage.
	@(link_name = "FPDF_LoadPage")
	load_page :: proc(document: ^DOCUMENT, page_index: c.int) -> ^PAGE ---

	// Experimental API
	// Function: FPDF_GetPageWidthF
	//          Get page width.
	// Parameters:
	//          page        -   Handle to the page. Returned by FPDF_LoadPage().
	// Return value:
	//          Page width (excluding non-displayable area) measured in points.
	//          One point is 1/72 inch (around 0.3528 mm).
	@(link_name = "FPDF_GetPageWidthF")
	get_page_widthf :: proc(page: ^PAGE) -> c.float ---

	// Function: FPDF_GetPageWidth
	//          Get page width.
	// Parameters:
	//          page        -   Handle to the page. Returned by FPDF_LoadPage.
	// Return value:
	//          Page width (excluding non-displayable area) measured in points.
	//          One point is 1/72 inch (around 0.3528 mm).
	// Note:
	//          Prefer FPDF_GetPageWidthF() above. This will be deprecated in the
	//          future.
	@(link_name = "FPDF_GetPageWidth")
	get_page_width :: proc(page: ^PAGE) -> c.double ---

	// Experimental API
	// Function: FPDF_GetPageHeightF
	//          Get page height.
	// Parameters:
	//          page        -   Handle to the page. Returned by FPDF_LoadPage().
	// Return value:
	//          Page height (excluding non-displayable area) measured in points.
	//          One point is 1/72 inch (around 0.3528 mm)
	@(link_name = "FPDF_GetPageHeightF")
	get_page_heightf :: proc(page: ^PAGE) -> c.float ---

	// Function: FPDF_GetPageHeight
	//          Get page height.
	// Parameters:
	//          page        -   Handle to the page. Returned by FPDF_LoadPage.
	// Return value:
	//          Page height (excluding non-displayable area) measured in points.
	//          One point is 1/72 inch (around 0.3528 mm)
	// Note:
	//          Prefer FPDF_GetPageHeightF() above. This will be deprecated in the
	//          future.
	@(link_name = "FPDF_GetPageHeight")
	get_page_height :: proc(page: ^PAGE) -> c.double ---

	// Experimental API.
	// Function: FPDF_GetPageBoundingBox
	//          Get the bounding box of the page. This is the intersection between
	//          its media box and its crop box.
	// Parameters:
	//          page        -   Handle to the page. Returned by FPDF_LoadPage.
	//          rect        -   Pointer to a rect to receive the page bounding box.
	//                          On an error, |rect| won't be filled.
	// Return value:
	//          True for success.
	@(link_name = "FPDF_GetPageBoundingBox")
	get_page_bounding_box :: proc(page: ^PAGE, rect: ^RECTF) -> BOOL ---

	// Experimental API.
	// Function: FPDF_GetPageSizeByIndexF
	//          Get the size of the page at the given index.
	// Parameters:
	//          document    -   Handle to document. Returned by FPDF_LoadDocument().
	//          page_index  -   Page index, zero for the first page.
	//          size        -   Pointer to a FS_SIZEF to receive the page size.
	//                          (in points).
	// Return value:
	//          Non-zero for success. 0 for error (document or page not found).
	@(link_name = "FPDF_GetPageSizeByIndexF")
	get_page_size_by_indexf :: proc(document: ^DOCUMENT, page_index: c.int, size: ^SIZEF) -> BOOL ---

	// Function: FPDF_GetPageSizeByIndex
	//          Get the size of the page at the given index.
	// Parameters:
	//          document    -   Handle to document. Returned by FPDF_LoadDocument.
	//          page_index  -   Page index, zero for the first page.
	//          width       -   Pointer to a double to receive the page width
	//                          (in points).
	//          height      -   Pointer to a double to receive the page height
	//                          (in points).
	// Return value:
	//          Non-zero for success. 0 for error (document or page not found).
	// Note:
	//          Prefer FPDF_GetPageSizeByIndexF() above. This will be deprecated in
	//          the future.
	@(link_name = "FPDF_GetPageSizeByIndex")
	get_page_size_by_index :: proc(document: ^DOCUMENT, page_index: c.int, width: ^c.double, height: ^c.double) -> c.int ---

	// Experimental API.
	// Function: FPDF_RenderPageBitmapWithColorScheme_Start
	//          Start to render page contents to a device independent bitmap
	//          progressively with a specified color scheme for the content.
	// Parameters:
	//          bitmap       -   Handle to the device independent bitmap (as the
	//                           output buffer). Bitmap handle can be created by
	//                           FPDFBitmap_Create function.
	//          page         -   Handle to the page as returned by FPDF_LoadPage
	//                           function.
	//          start_x      -   Left pixel position of the display area in the
	//                           bitmap coordinate.
	//          start_y      -   Top pixel position of the display area in the
	//                           bitmap coordinate.
	//          size_x       -   Horizontal size (in pixels) for displaying the
	//                           page.
	//          size_y       -   Vertical size (in pixels) for displaying the page.
	//          rotate       -   Page orientation: 0 (normal), 1 (rotated 90
	//                           degrees clockwise), 2 (rotated 180 degrees),
	//                           3 (rotated 90 degrees counter-clockwise).
	//          flags        -   0 for normal display, or combination of flags
	//                           defined in fpdfview.h. With FPDF_ANNOT flag, it
	//                           renders all annotations that does not require
	//                           user-interaction, which are all annotations except
	//                           widget and popup annotations.
	//          color_scheme -   Color scheme to be used in rendering the |page|.
	//                           If null, this function will work similar to
	//                           FPDF_RenderPageBitmap_Start().
	//          pause        -   The IFSDK_PAUSE interface. A callback mechanism
	//                           allowing the page rendering process.
	// Return value:
	//          Rendering Status. See flags for progressive process status for the
	//          details.
	@(link_name = "FPDF_RenderPageBitmapWithColorScheme_Start")
	render_page_bitmap_with_color_scheme_start :: proc(bitmap: ^BITMAP, page: ^PAGE, start_x: c.int, start_y: c.int, size_x: c.int, size_y: c.int, rotate: c.int, flags: c.int, color_scheme: ^COLORSCHEME, pause: ^IFSDK_PAUSE) -> c.int ---

	// Function: FPDF_RenderPageBitmap_Start
	//          Start to render page contents to a device independent bitmap
	//          progressively.
	// Parameters:
	//          bitmap      -   Handle to the device independent bitmap (as the
	//                          output buffer). Bitmap handle can be created by
	//                          FPDFBitmap_Create().
	//          page        -   Handle to the page, as returned by FPDF_LoadPage().
	//          start_x     -   Left pixel position of the display area in the
	//                          bitmap coordinates.
	//          start_y     -   Top pixel position of the display area in the bitmap
	//                          coordinates.
	//          size_x      -   Horizontal size (in pixels) for displaying the page.
	//          size_y      -   Vertical size (in pixels) for displaying the page.
	//          rotate      -   Page orientation: 0 (normal), 1 (rotated 90 degrees
	//                          clockwise), 2 (rotated 180 degrees), 3 (rotated 90
	//                          degrees counter-clockwise).
	//          flags       -   0 for normal display, or combination of flags
	//                          defined in fpdfview.h. With FPDF_ANNOT flag, it
	//                          renders all annotations that does not require
	//                          user-interaction, which are all annotations except
	//                          widget and popup annotations.
	//          pause       -   The IFSDK_PAUSE interface.A callback mechanism
	//                          allowing the page rendering process
	// Return value:
	//          Rendering Status. See flags for progressive process status for the
	//          details.
	@(link_name = "FPDF_RenderPageBitmap_Start")
	render_page_bitmap_start :: proc(bitmap: ^BITMAP, page: ^PAGE, start_x: c.int, start_y: c.int, size_x: c.int, size_y: c.int, rotate: c.int, flags: c.int, pause: ^IFSDK_PAUSE) -> c.int ---

	// Function: FPDF_RenderPageBitmap
	//          Render contents of a page to a device independent bitmap.
	// Parameters:
	//          bitmap      -   Handle to the device independent bitmap (as the
	//                          output buffer). The bitmap handle can be created
	//                          by FPDFBitmap_Create or retrieved from an image
	//                          object by FPDFImageObj_GetBitmap.
	//          page        -   Handle to the page. Returned by FPDF_LoadPage
	//          start_x     -   Left pixel position of the display area in
	//                          bitmap coordinates.
	//          start_y     -   Top pixel position of the display area in bitmap
	//                          coordinates.
	//          size_x      -   Horizontal size (in pixels) for displaying the page.
	//          size_y      -   Vertical size (in pixels) for displaying the page.
	//          rotate      -   Page orientation:
	//                            0 (normal)
	//                            1 (rotated 90 degrees clockwise)
	//                            2 (rotated 180 degrees)
	//                            3 (rotated 90 degrees counter-clockwise)
	//          flags       -   0 for normal display, or combination of the Page
	//                          Rendering flags defined above. With the FPDF_ANNOT
	//                          flag, it renders all annotations that do not require
	//                          user-interaction, which are all annotations except
	//                          widget and popup annotations.
	// Return value:
	//          None.
	@(link_name = "FPDF_RenderPageBitmap")
	render_page_bitmap :: proc(bitmap: ^BITMAP, page: ^PAGE, start_x: c.int, start_y: c.int, size_x: c.int, size_y: c.int, rotate: c.int, flags: c.int) ---

	// Function: FPDF_RenderPageBitmapWithMatrix
	//          Render contents of a page to a device independent bitmap.
	// Parameters:
	//          bitmap      -   Handle to the device independent bitmap (as the
	//                          output buffer). The bitmap handle can be created
	//                          by FPDFBitmap_Create or retrieved by
	//                          FPDFImageObj_GetBitmap.
	//          page        -   Handle to the page. Returned by FPDF_LoadPage.
	//          matrix      -   The transform matrix, which must be invertible.
	//                          See PDF Reference 1.7, 4.2.2 Common Transformations.
	//          clipping    -   The rect to clip to in device coords.
	//          flags       -   0 for normal display, or combination of the Page
	//                          Rendering flags defined above. With the FPDF_ANNOT
	//                          flag, it renders all annotations that do not require
	//                          user-interaction, which are all annotations except
	//                          widget and popup annotations.
	// Return value:
	//          None. Note that behavior is undefined if det of |matrix| is 0.
	@(link_name = "FPDF_RenderPageBitmapWithMatrix")
	render_page_bitmap_with_matrix :: proc(bitmap: ^BITMAP, page: ^PAGE, mat: ^MATRIX, clipping: ^RECTF, flags: c.int) ---

	// Function: FPDF_ClosePage
	//          Close a loaded PDF page.
	// Parameters:
	//          page        -   Handle to the loaded page.
	// Return value:
	//          None.
	@(link_name = "FPDF_ClosePage")
	close_page :: proc(page: ^PAGE) ---

	// Function: FPDF_CloseDocument
	//          Close a loaded PDF document.
	// Parameters:
	//          document    -   Handle to the loaded document.
	// Return value:
	//          None.
	@(link_name = "FPDF_CloseDocument")
	close_document :: proc(document: ^DOCUMENT) ---

	// Function: FPDF_DeviceToPage
	//          Convert the screen coordinates of a point to page coordinates.
	// Parameters:
	//          page        -   Handle to the page. Returned by FPDF_LoadPage.
	//          start_x     -   Left pixel position of the display area in
	//                          device coordinates.
	//          start_y     -   Top pixel position of the display area in device
	//                          coordinates.
	//          size_x      -   Horizontal size (in pixels) for displaying the page.
	//          size_y      -   Vertical size (in pixels) for displaying the page.
	//          rotate      -   Page orientation:
	//                            0 (normal)
	//                            1 (rotated 90 degrees clockwise)
	//                            2 (rotated 180 degrees)
	//                            3 (rotated 90 degrees counter-clockwise)
	//          device_x    -   X value in device coordinates to be converted.
	//          device_y    -   Y value in device coordinates to be converted.
	//          page_x      -   A pointer to a double receiving the converted X
	//                          value in page coordinates.
	//          page_y      -   A pointer to a double receiving the converted Y
	//                          value in page coordinates.
	// Return value:
	//          Returns true if the conversion succeeds, and |page_x| and |page_y|
	//          successfully receives the converted coordinates.
	// Comments:
	//          The page coordinate system has its origin at the left-bottom corner
	//          of the page, with the X-axis on the bottom going to the right, and
	//          the Y-axis on the left side going up.
	//
	//          NOTE: this coordinate system can be altered when you zoom, scroll,
	//          or rotate a page, however, a point on the page should always have
	//          the same coordinate values in the page coordinate system.
	//
	//          The device coordinate system is device dependent. For screen device,
	//          its origin is at the left-top corner of the window. However this
	//          origin can be altered by the Windows coordinate transformation
	//          utilities.
	//
	//          You must make sure the start_x, start_y, size_x, size_y
	//          and rotate parameters have exactly same values as you used in
	//          the FPDF_RenderPage() function call.
	@(link_name = "FPDF_DeviceToPage")
	device_to_page :: proc(page: ^PAGE, start_x: c.int, start_y: c.int, size_x: c.int, size_y: c.int, rotate: c.int, device_x: c.int, device_y: c.int, page_x: ^c.double, page_y: ^c.double) -> BOOL ---

	// Function: FPDF_PageToDevice
	//          Convert the page coordinates of a point to screen coordinates.
	// Parameters:
	//          page        -   Handle to the page. Returned by FPDF_LoadPage.
	//          start_x     -   Left pixel position of the display area in
	//                          device coordinates.
	//          start_y     -   Top pixel position of the display area in device
	//                          coordinates.
	//          size_x      -   Horizontal size (in pixels) for displaying the page.
	//          size_y      -   Vertical size (in pixels) for displaying the page.
	//          rotate      -   Page orientation:
	//                            0 (normal)
	//                            1 (rotated 90 degrees clockwise)
	//                            2 (rotated 180 degrees)
	//                            3 (rotated 90 degrees counter-clockwise)
	//          page_x      -   X value in page coordinates.
	//          page_y      -   Y value in page coordinate.
	//          device_x    -   A pointer to an integer receiving the result X
	//                          value in device coordinates.
	//          device_y    -   A pointer to an integer receiving the result Y
	//                          value in device coordinates.
	// Return value:
	//          Returns true if the conversion succeeds, and |device_x| and
	//          |device_y| successfully receives the converted coordinates.
	// Comments:
	//          See comments for FPDF_DeviceToPage().
	@(link_name = "FPDF_PageToDevice")
	page_to_device :: proc(page: ^PAGE, start_x: c.int, start_y: c.int, size_x: c.int, size_y: c.int, rotate: c.int, page_x: c.double, page_y: c.double, device_x: ^c.int, device_y: ^c.int) -> BOOL ---

	// Function: FPDF_CountNamedDests
	//          Get the count of named destinations in the PDF document.
	// Parameters:
	//          document    -   Handle to a document
	// Return value:
	//          The count of named destinations.
	@(link_name = "FPDF_CountNamedDests")
	count_named_dests :: proc(document: ^DOCUMENT) -> DWORD ---

	// Function: FPDF_GetNamedDestByName
	//          Get a the destination handle for the given name.
	// Parameters:
	//          document    -   Handle to the loaded document.
	//          name        -   The name of a destination.
	// Return value:
	//          The handle to the destination.
	@(link_name = "FPDF_GetNamedDestByName")
	get_named_dest_by_name :: proc(document: ^DOCUMENT, name: BYTESTRING) -> ^DEST ---

	// Function: FPDF_GetNamedDest
	//          Get the named destination by index.
	// Parameters:
	//          document        -   Handle to a document
	//          index           -   The index of a named destination.
	//          buffer          -   The buffer to store the destination name,
	//                              used as wchar_t*.
	//          buflen [in/out] -   Size of the buffer in bytes on input,
	//                              length of the result in bytes on output
	//                              or -1 if the buffer is too small.
	// Return value:
	//          The destination handle for a given index, or NULL if there is no
	//          named destination corresponding to |index|.
	// Comments:
	//          Call this function twice to get the name of the named destination:
	//            1) First time pass in |buffer| as NULL and get buflen.
	//            2) Second time pass in allocated |buffer| and buflen to retrieve
	//               |buffer|, which should be used as wchar_t*.
	//
	//         If buflen is not sufficiently large, it will be set to -1 upon
	//         return.
	@(link_name = "FPDF_GetNamedDest")
	get_named_dest :: proc(document: ^DOCUMENT, index: c.int, buffer: rawptr, buflen: c.long) -> ^DEST ---

	// Experimental API.
	// Function: FPDF_GetXFAPacketCount
	//          Get the number of valid packets in the XFA entry.
	// Parameters:
	//          document - Handle to the document.
	// Return value:
	//          The number of valid packets, or -1 on error.
	@(link_name = "FPDF_GetXFAPacketCount")
	get_xfa_packet_count :: proc(document: ^DOCUMENT) -> c.int ---

	// Experimental API.
	// Function: FPDF_GetXFAPacketName
	//          Get the name of a packet in the XFA array.
	// Parameters:
	//          document - Handle to the document.
	//          index    - Index number of the packet. 0 for the first packet.
	//          buffer   - Buffer for holding the name of the XFA packet.
	//          buflen   - Length of |buffer| in bytes.
	// Return value:
	//          The length of the packet name in bytes, or 0 on error.
	//
	// |document| must be valid and |index| must be in the range [0, N), where N is
	// the value returned by FPDF_GetXFAPacketCount().
	// |buffer| is only modified if it is non-NULL and |buflen| is greater than or
	// equal to the length of the packet name. The packet name includes a
	// terminating NUL character. |buffer| is unmodified on error.
	@(link_name = "FPDF_GetXFAPacketName")
	get_xfa_packet_name :: proc(document: ^DOCUMENT, index: c.int, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Function: FPDF_GetXFAPacketContent
	//          Get the content of a packet in the XFA array.
	// Parameters:
	//          document   - Handle to the document.
	//          index      - Index number of the packet. 0 for the first packet.
	//          buffer     - Buffer for holding the content of the XFA packet.
	//          buflen     - Length of |buffer| in bytes.
	//          out_buflen - Pointer to the variable that will receive the minimum
	//                       buffer size needed to contain the content of the XFA
	//                       packet.
	// Return value:
	//          Whether the operation succeeded or not.
	//
	// |document| must be valid and |index| must be in the range [0, N), where N is
	// the value returned by FPDF_GetXFAPacketCount(). |out_buflen| must not be
	// NULL. When the aforementioned arguments are valid, the operation succeeds,
	// and |out_buflen| receives the content size. |buffer| is only modified if
	// |buffer| is non-null and long enough to contain the content. Callers must
	// check both the return value and the input |buflen| is no less than the
	// returned |out_buflen| before using the data in |buffer|.
	@(link_name = "FPDF_GetXFAPacketContent")
	get_xfa_packet_content :: proc(document: ^DOCUMENT, index: c.int, buffer: rawptr, buflen: c.ulong, out_buflen: ^c.ulong) -> BOOL ---

	when ODIN_OS == .Windows {
		// Experimental API.
		// Function: FPDF_SetPrintMode
		//          Set printing mode when printing on Windows.
		// Parameters:
		//          mode - FPDF_PRINTMODE_EMF to output EMF (default)
		//                 FPDF_PRINTMODE_TEXTONLY to output text only (for charstream
		//                 devices)
		//                 FPDF_PRINTMODE_POSTSCRIPT2 to output level 2 PostScript into
		//                 EMF as a series of GDI comments.
		//                 FPDF_PRINTMODE_POSTSCRIPT3 to output level 3 PostScript into
		//                 EMF as a series of GDI comments.
		//                 FPDF_PRINTMODE_POSTSCRIPT2_PASSTHROUGH to output level 2
		//                 PostScript via ExtEscape() in PASSTHROUGH mode.
		//                 FPDF_PRINTMODE_POSTSCRIPT3_PASSTHROUGH to output level 3
		//                 PostScript via ExtEscape() in PASSTHROUGH mode.
		//                 FPDF_PRINTMODE_EMF_IMAGE_MASKS to output EMF, with more
		//                 efficient processing of documents containing image masks.
		//                 FPDF_PRINTMODE_POSTSCRIPT3_TYPE42 to output level 3
		//                 PostScript with embedded Type 42 fonts, when applicable, into
		//                 EMF as a series of GDI comments.
		//                 FPDF_PRINTMODE_POSTSCRIPT3_TYPE42_PASSTHROUGH to output level
		//                 3 PostScript with embedded Type 42 fonts, when applicable,
		//                 via ExtEscape() in PASSTHROUGH mode.
		// Return value:
		//          True if successful, false if unsuccessful (typically invalid input).
		@(link_name = "FPDF_SetPrintMode")
		set_print_mode :: proc(mode: c.int) -> BOOL ---

		// Function: FPDF_RenderPage
		//          Render contents of a page to a device (screen, bitmap, or printer).
		//          This function is only supported on Windows.
		// Parameters:
		//          dc          -   Handle to the device context.
		//          page        -   Handle to the page. Returned by FPDF_LoadPage.
		//          start_x     -   Left pixel position of the display area in
		//                          device coordinates.
		//          start_y     -   Top pixel position of the display area in device
		//                          coordinates.
		//          size_x      -   Horizontal size (in pixels) for displaying the page.
		//          size_y      -   Vertical size (in pixels) for displaying the page.
		//          rotate      -   Page orientation:
		//                            0 (normal)
		//                            1 (rotated 90 degrees clockwise)
		//                            2 (rotated 180 degrees)
		//                            3 (rotated 90 degrees counter-clockwise)
		//          flags       -   0 for normal display, or combination of flags
		//                          defined above.
		// Return value:
		//          None.
		@(link_name = "FPDF_RenderPage")
		render_page :: proc(dc: os.Handle, page: PAGE, start_x: c.int, start_y: c.int, size_x: c.int, size_y: c.int, rotate: c.int, flags: c.int) ---
	}

	// Experimental API
	// Gets an additional-action from |page|.
	//
	//   page      - handle to the page, as returned by FPDF_LoadPage().
	//   aa_type   - the type of the page object's addtional-action, defined
	//               in public/fpdf_formfill.h
	//
	//   Returns the handle to the action data, or NULL if there is no
	//   additional-action of type |aa_type|.
	//   If this function returns a valid handle, it is valid as long as |page| is
	//   valid.
	@(link_name = "FPDF_GetPageAAction")
	get_page_aaction :: proc(page: ^PAGE, aa_type: c.int) -> ^ACTION ---

	// Experimental API.
	// Get the file identifer defined in the trailer of |document|.
	//
	//   document - handle to the document.
	//   id_type  - the file identifier type to retrieve.
	//   buffer   - a buffer for the file identifier. May be NULL.
	//   buflen   - the length of the buffer, in bytes. May be 0.
	//
	// Returns the number of bytes in the file identifier, including the NUL
	// terminator.
	//
	// The |buffer| is always a byte string. The |buffer| is followed by a NUL
	// terminator.  If |buflen| is less than the returned length, or |buffer| is
	// NULL, |buffer| will not be modified.
	@(link_name = "FPDF_GetFileIdentifier")
	get_file_identifier :: proc(document: ^DOCUMENT, id_type: FILEIDTYPE, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Get meta-data |tag| content from |document|.
	//
	//   document - handle to the document.
	//   tag      - the tag to retrieve. The tag can be one of:
	//                Title, Author, Subject, Keywords, Creator, Producer,
	//                CreationDate, or ModDate.
	//              For detailed explanations of these tags and their respective
	//              values, please refer to PDF Reference 1.6, section 10.2.1,
	//              'Document Information Dictionary'.
	//   buffer   - a buffer for the tag. May be NULL.
	//   buflen   - the length of the buffer, in bytes. May be 0.
	//
	// Returns the number of bytes in the tag, including trailing zeros.
	//
	// The |buffer| is always encoded in UTF-16LE. The |buffer| is followed by two
	// bytes of zeros indicating the end of the string.  If |buflen| is less than
	// the returned length, or |buffer| is NULL, |buffer| will not be modified.
	//
	// For linearized files, FPDFAvail_IsFormAvail must be called before this, and
	// it must have returned PDF_FORM_AVAIL or PDF_FORM_NOTEXIST. Before that, there
	// is no guarantee the metadata has been loaded.
	@(link_name = "FPDF_GetMetaText")
	get_meta_text :: proc(document: ^DOCUMENT, tag: BYTESTRING, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Get the page label for |page_index| from |document|.
	//
	//   document    - handle to the document.
	//   page_index  - the 0-based index of the page.
	//   buffer      - a buffer for the page label. May be NULL.
	//   buflen      - the length of the buffer, in bytes. May be 0.
	//
	// Returns the number of bytes in the page label, including trailing zeros.
	//
	// The |buffer| is always encoded in UTF-16LE. The |buffer| is followed by two
	// bytes of zeros indicating the end of the string.  If |buflen| is less than
	// the returned length, or |buffer| is NULL, |buffer| will not be modified.
	@(link_name = "FPDF_GetPageLabel")
	get_page_label :: proc(document: ^DOCUMENT, page_index: c.int, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	/*
	* Function: FPDF_SetFormFieldHighlightColor
	*       Set the highlight color of the specified (or all) form fields
	*       in the document.
	* Parameters:
	*       hHandle     -   Handle to the form fill module, as returned by
	*                       FPDFDOC_InitFormFillEnvironment().
	*       doc         -   Handle to the document, as returned by
	*                       FPDF_LoadDocument().
	*       fieldType   -   A 32-bit integer indicating the type of a form
	*                       field (defined above).
	*       color       -   The highlight color of the form field. Constructed by
	*                       0xxxrrggbb.
	* Return Value:
	*       None.
	* Comments:
	*       When the parameter fieldType is set to FPDF_FORMFIELD_UNKNOWN, the
	*       highlight color will be applied to all the form fields in the
	*       document.
	*       Please refresh the client window to show the highlight immediately
	*       if necessary.
	*/
	@(link_name = "FPDF_SetFormFieldHighlightColor")
	set_form_field_highlight_color :: proc(hHandle: ^FORMHANDLE, fieldType: c.int, color: c.ulong) ---

	/*
	* Function: FPDF_SetFormFieldHighlightAlpha
	*       Set the transparency of the form field highlight color in the
	*       document.
	* Parameters:
	*       hHandle     -   Handle to the form fill module, as returned by
	*                       FPDFDOC_InitFormFillEnvironment().
	*       doc         -   Handle to the document, as returaned by
	*                       FPDF_LoadDocument().
	*       alpha       -   The transparency of the form field highlight color,
	*                       between 0-255.
	* Return Value:
	*       None.
	*/
	@(link_name = "FPDF_SetFormFieldHighlightAlpha")
	set_form_field_highlight_alpha :: proc(hHandle: ^FORMHANDLE, alpha: c.uchar) ---

	/*
	* Function: FPDF_RemoveFormFieldHighlight
	*       Remove the form field highlight color in the document.
	* Parameters:
	*       hHandle     -   Handle to the form fill module, as returned by
	*                       FPDFDOC_InitFormFillEnvironment().
	* Return Value:
	*       None.
	* Comments:
	*       Please refresh the client window to remove the highlight immediately
	*       if necessary.
	*/
	@(link_name = "FPDF_RemoveFormFieldHighlight")
	remove_form :: proc(hHandle: ^FORMHANDLE) ---

	/*
	* Function: FPDF_FFLDraw
	*       Render FormFields and popup window on a page to a device independent
	*       bitmap.
	* Parameters:
	*       hHandle      -   Handle to the form fill module, as returned by
	*                        FPDFDOC_InitFormFillEnvironment().
	*       bitmap       -   Handle to the device independent bitmap (as the
	*                        output buffer). Bitmap handles can be created by
	*                        FPDFBitmap_Create().
	*       page         -   Handle to the page, as returned by FPDF_LoadPage().
	*       start_x      -   Left pixel position of the display area in the
	*                        device coordinates.
	*       start_y      -   Top pixel position of the display area in the device
	*                        coordinates.
	*       size_x       -   Horizontal size (in pixels) for displaying the page.
	*       size_y       -   Vertical size (in pixels) for displaying the page.
	*       rotate       -   Page orientation: 0 (normal), 1 (rotated 90 degrees
	*                        clockwise), 2 (rotated 180 degrees), 3 (rotated 90
	*                        degrees counter-clockwise).
	*       flags        -   0 for normal display, or combination of flags
	*                        defined above.
	* Return Value:
	*       None.
	* Comments:
	*       This function is designed to render annotations that are
	*       user-interactive, which are widget annotations (for FormFields) and
	*       popup annotations.
	*       With the FPDF_ANNOT flag, this function will render a popup annotation
	*       when users mouse-hover on a non-widget annotation. Regardless of
	*       FPDF_ANNOT flag, this function will always render widget annotations
	*       for FormFields.
	*       In order to implement the FormFill functions, implementation should
	*       call this function after rendering functions, such as
	*       FPDF_RenderPageBitmap() or FPDF_RenderPageBitmap_Start(), have
	*       finished rendering the page contents.
	*/
	@(link_name = "FPDF_FFLDraw")
	ffl_draw :: proc(hHandle: ^FORMHANDLE, bitmap: ^BITMAP, page: ^PAGE, start_x: c.int, start_y: c.int, size_x: c.int, size_y: c.int, rotate: c.int, flags: c.int) ---

	/*
	* Experimental API
	* Function: FPDF_GetFormType
	*           Returns the type of form contained in the PDF document.
	* Parameters:
	*           document - Handle to document.
	* Return Value:
	*           Integer value representing one of the FORMTYPE_ values.
	* Comments:
	*           If |document| is NULL, then the return value is FORMTYPE_NONE.
	*/
	@(link_name = "FPDF_GetFormType")
	get_form_type :: proc(document: ^DOCUMENT) -> c.int ---

	/*
	* Function: FPDF_LoadXFA
	*          If the document consists of XFA fields, call this method to
	*          attempt to load XFA fields.
	* Parameters:
	*          document     -   Handle to document from FPDF_LoadDocument().
	* Return Value:
	*          TRUE upon success, otherwise FALSE. If XFA support is not built
	*          into PDFium, performs no action and always returns FALSE.
	*/
	@(link_name = "FPDF_LoadXFA")
	load_xfa :: proc(document: ^DOCUMENT) -> BOOL ---

	// Experimental API.
	// Import pages to a FPDF_DOCUMENT.
	//
	//   dest_doc     - The destination document for the pages.
	//   src_doc      - The document to be imported.
	//   page_indices - An array of page indices to be imported. The first page is
	//                  zero. If |page_indices| is NULL, all pages from |src_doc|
	//                  are imported.
	//   length       - The length of the |page_indices| array.
	//   index        - The page index at which to insert the first imported page
	//                  into |dest_doc|. The first page is zero.
	//
	// Returns TRUE on success. Returns FALSE if any pages in |page_indices| is
	// invalid.
	@(link_name = "FPDF_ImportPagesByIndex")
	import_pages_by_index :: proc(dest_doc: ^DOCUMENT, src_doc: ^DOCUMENT, page_indices: ^c.int, length: c.ulong, index: c.int) -> BOOL ---

	// Import pages to a FPDF_DOCUMENT.
	//
	//   dest_doc  - The destination document for the pages.
	//   src_doc   - The document to be imported.
	//   pagerange - A page range string, Such as "1,3,5-7". The first page is one.
	//               If |pagerange| is NULL, all pages from |src_doc| are imported.
	//   index     - The page index at which to insert the first imported page into
	//               |dest_doc|. The first page is zero.
	//
	// Returns TRUE on success. Returns FALSE if any pages in |pagerange| is
	// invalid or if |pagerange| cannot be read.
	@(link_name = "FPDF_ImportPages")
	import_pages :: proc(dest_doc: ^DOCUMENT, src_doc: ^DOCUMENT, pagerange: BYTESTRING, index: c.int) -> BOOL ---

	// Experimental API.
	// Create a new document from |src_doc|.  The pages of |src_doc| will be
	// combined to provide |num_pages_on_x_axis x num_pages_on_y_axis| pages per
	// |output_doc| page.
	//
	//   src_doc             - The document to be imported.
	//   output_width        - The output page width in PDF "user space" units.
	//   output_height       - The output page height in PDF "user space" units.
	//   num_pages_on_x_axis - The number of pages on X Axis.
	//   num_pages_on_y_axis - The number of pages on Y Axis.
	//
	// Return value:
	//   A handle to the created document, or NULL on failure.
	//
	// Comments:
	//   number of pages per page = num_pages_on_x_axis * num_pages_on_y_axis
	//
	@(link_name = "FPDF_ImportNPagesToOne")
	import_n_pages_to_one :: proc(src_doc: ^DOCUMENT, output_width: c.float, output_height: c.float, num_pages_on_x_axis: c.size_t, num_pages_on_y_axis: c.size_t) -> ^DOCUMENT ---

	// Experimental API.
	// Create a template to generate form xobjects from |src_doc|'s page at
	// |src_page_index|, for use in |dest_doc|.
	//
	// Returns a handle on success, or NULL on failure. Caller owns the newly
	// created object.
	@(link_name = "FPDF_NewXObjectFromPage")
	new_xobject_from_page :: proc(dest_doc: ^DOCUMENT, src_doc: ^DOCUMENT, src_page_index: c.int) -> ^XOBJECT ---

	// Experimental API.
	// Close an FPDF_XOBJECT handle created by FPDF_NewXObjectFromPage().
	// FPDF_PAGEOBJECTs created from the FPDF_XOBJECT handle are not affected.
	@(link_name = "FPDF_CloseXObject")
	close_xobject :: proc(xobject: ^XOBJECT) ---

	// Experimental API.
	// Create a new form object from an FPDF_XOBJECT object.
	//
	// Returns a new form object on success, or NULL on failure. Caller owns the
	// newly created object.
	@(link_name = "FPDF_NewFormObjectFromXObject")
	new_form_object_from_xobject :: proc(xobject: ^XOBJECT) -> ^PAGEOBJECT ---

	// Copy the viewer preferences from |src_doc| into |dest_doc|.
	//
	//   dest_doc - Document to write the viewer preferences into.
	//   src_doc  - Document to read the viewer preferences from.
	//
	// Returns TRUE on success.
	@(link_name = "FPDF_CopyViewerPreferences")
	copy_viewer_preferences :: proc(dest_doc: ^DOCUMENT, src_doc: ^DOCUMENT) -> BOOL ---

	// Function: FPDF_RenderPage_Continue
	//          Continue rendering a PDF page.
	// Parameters:
	//          page        -   Handle to the page, as returned by FPDF_LoadPage().
	//          pause       -   The IFSDK_PAUSE interface (a callback mechanism
	//                          allowing the page rendering process to be paused
	//                          before it's finished). This can be NULL if you
	//                          don't want to pause.
	// Return value:
	//          The rendering status. See flags for progressive process status for
	//          the details.
	@(link_name = "FPDF_RenderPage_Continue")
	renderpage_continue :: proc(page: ^PAGE, pause: ^IFSDK_PAUSE) -> c.int ---

	// Function: FPDF_RenderPage_Close
	//          Release the resource allocate during page rendering. Need to be
	//          called after finishing rendering or
	//          cancel the rendering.
	// Parameters:
	//          page        -   Handle to the page, as returned by FPDF_LoadPage().
	// Return value:
	//          None.
	@(link_name = "FPDF_RenderPage_Close")
	renderpage_close :: proc(page: ^PAGE) ---

	// Function: FPDF_SaveAsCopy
	//          Saves the copy of specified document in custom way.
	// Parameters:
	//          document        -   Handle to document, as returned by
	//                              FPDF_LoadDocument() or FPDF_CreateNewDocument().
	//          pFileWrite      -   A pointer to a custom file write structure.
	//          flags           -   The creating flags.
	// Return value:
	//          TRUE for succeed, FALSE for failed.
	//
	@(link_name = "FPDF_SaveAsCopy")
	save_as_copy :: proc(document: ^DOCUMENT, pFileWrite: ^FILEWRITE, flags: DWORD) -> BOOL ---

	// Function: FPDF_SaveWithVersion
	//          Same as FPDF_SaveAsCopy(), except the file version of the
	//          saved document can be specified by the caller.
	// Parameters:
	//          document        -   Handle to document.
	//          pFileWrite      -   A pointer to a custom file write structure.
	//          flags           -   The creating flags.
	//          fileVersion     -   The PDF file version. File version: 14 for 1.4,
	//                              15 for 1.5, ...
	// Return value:
	//          TRUE if succeed, FALSE if failed.
	//
	@(link_name = "FPDF_SaveWithVersion")
	save_with_version :: proc(document: ^DOCUMENT, pFileWrite: ^FILEWRITE, flags: DWORD, fileVersion: c.int) -> BOOL ---

	// Experimental API.
	// Function: FPDF_GetSignatureCount
	//          Get total number of signatures in the document.
	// Parameters:
	//          document    -   Handle to document. Returned by FPDF_LoadDocument().
	// Return value:
	//          Total number of signatures in the document on success, -1 on error.
	@(link_name = "FPDF_GetSignatureCount")
	get_signature_count :: proc(document: ^DOCUMENT) -> c.int ---

	// Experimental API.
	// Function: FPDF_GetSignatureObject
	//          Get the Nth signature of the document.
	// Parameters:
	//          document    -   Handle to document. Returned by FPDF_LoadDocument().
	//          index       -   Index into the array of signatures of the document.
	// Return value:
	//          Returns the handle to the signature, or NULL on failure. The caller
	//          does not take ownership of the returned FPDF_SIGNATURE. Instead, it
	//          remains valid until FPDF_CloseDocument() is called for the document.
	@(link_name = "FPDF_GetSignatureObject")
	get_signature_object :: proc(document: ^DOCUMENT, index: c.int) -> ^SIGNATURE ---

	/*
	* Function: FPDF_GetDefaultTTFMap
	*    Returns a pointer to the default character set to TT Font name map. The
	*    map is an array of FPDF_CharsetFontMap structs, with its end indicated
	*    by a { -1, NULL } entry.
	* Parameters:
	*     None.
	* Return Value:
	*     Pointer to the Charset Font Map.
	*/
	@(link_name = "FPDF_GetDefaultTTFMap")
	get_default_ttf_map :: proc() -> ^CharsetFontMap ---

	/*
	* Function: FPDF_AddInstalledFont
	*          Add a system font to the list in PDFium.
	* Comments:
	*          This function is only called during the system font list building
	*          process.
	* Parameters:
	*          mapper          -   Opaque pointer to Foxit font mapper
	*          face            -   The font face name
	*          charset         -   Font character set. See above defined constants.
	* Return Value:
	*          None.
	*/
	@(link_name = "FPDF_AddInstalledFont")
	add_installed_font :: proc(mapper: rawptr, face: cstring, charset: c.int) ---

	/*
	* Function: FPDF_SetSystemFontInfo
	*          Set the system font info interface into PDFium
	* Parameters:
	*          pFontInfo       -   Pointer to a FPDF_SYSFONTINFO structure
	* Return Value:
	*          None
	* Comments:
	*          Platform support implementation should implement required methods of
	*          FFDF_SYSFONTINFO interface, then call this function during PDFium
	*          initialization process.
	*/
	@(link_name = "FPDF_SetSystemFontInfo")
	set_system_font_info :: proc(pFontInfo: ^SYSFONTINFO) ---

	/*
	* Function: FPDF_GetDefaultSystemFontInfo
	*          Get default system font info interface for current platform
	* Parameters:
	*          None
	* Return Value:
	*          Pointer to a FPDF_SYSFONTINFO structure describing the default
	*          interface, or NULL if the platform doesn't have a default interface.
	*          Application should call FPDF_FreeDefaultSystemFontInfo to free the
	*          returned pointer.
	* Comments:
	*          For some platforms, PDFium implements a default version of system
	*          font info interface. The default implementation can be passed to
	*          FPDF_SetSystemFontInfo().
	*/
	@(link_name = "FPDF_GetDefaultSystemFontInfo")
	get_default_system_font_info :: proc() -> ^SYSFONTINFO ---

	/*
	* Function: FPDF_FreeDefaultSystemFontInfo
	*           Free a default system font info interface
	* Parameters:
	*           pFontInfo       -   Pointer to a FPDF_SYSFONTINFO structure
	* Return Value:
	*           None
	* Comments:
	*           This function should be called on the output from
	*           FPDF_SetSystemFontInfo() once it is no longer needed.
	*/
	@(link_name = "FPDF_FreeDefaultSystemFontInfo")
	free_default_system_font_info :: proc(pFontInfo: ^SYSFONTINFO) ---

	/**
     * Create a new clip path, with a rectangle inserted.
     *
     * Caller takes ownership of the returned FPDF_CLIPPATH. It should be freed with
     * FPDF_DestroyClipPath().
     *
     * left   - The left of the clip box.
     * bottom - The bottom of the clip box.
     * right  - The right of the clip box.
     * top    - The top of the clip box.
     */
	@(link_name = "FPDF_CreateClipPath")
	create_clip_path :: proc(left: c.float, bottom: c.float, right: c.float, top: c.float) -> ^CLIPPATH ---

	/**
     * Destroy the clip path.
     *
     * clipPath - A handle to the clip path. It will be invalid after this call.
     */
	@(link_name = "FPDF_DestroyClipPath")
	destroy_clip_path :: proc(clipPath: ^CLIPPATH) ---
}

@(default_calling_convention = "c")
foreign lib {
	// Function: FPDFBitmap_Create
	//          Create a device independent bitmap (FXDIB).
	// Parameters:
	//          width       -   The number of pixels in width for the bitmap.
	//                          Must be greater than 0.
	//          height      -   The number of pixels in height for the bitmap.
	//                          Must be greater than 0.
	//          alpha       -   A flag indicating whether the alpha channel is used.
	//                          Non-zero for using alpha, zero for not using.
	// Return value:
	//          The created bitmap handle, or NULL if a parameter error or out of
	//          memory.
	// Comments:
	//          The bitmap always uses 4 bytes per pixel. The first byte is always
	//          double word aligned.
	//
	//          The byte order is BGRx (the last byte unused if no alpha channel) or
	//          BGRA.
	//
	//          The pixels in a horizontal line are stored side by side, with the
	//          left most pixel stored first (with lower memory address).
	//          Each line uses width * 4 bytes.
	//
	//          Lines are stored one after another, with the top most line stored
	//          first. There is no gap between adjacent lines.
	//
	//          This function allocates enough memory for holding all pixels in the
	//          bitmap, but it doesn't initialize the buffer. Applications can use
	//          FPDFBitmap_FillRect() to fill the bitmap using any color. If the OS
	//          allows it, this function can allocate up to 4 GB of memory.
	@(link_name = "FPDFBitmap_Create")
	bitmap_create :: proc(width: c.int, height: c.int, alpha: c.int) -> ^BITMAP ---

	// Function: FPDFBitmap_CreateEx
	//          Create a device independent bitmap (FXDIB)
	// Parameters:
	//          width       -   The number of pixels in width for the bitmap.
	//                          Must be greater than 0.
	//          height      -   The number of pixels in height for the bitmap.
	//                          Must be greater than 0.
	//          format      -   A number indicating for bitmap format, as defined
	//                          above.
	//          first_scan  -   A pointer to the first byte of the first line if
	//                          using an external buffer. If this parameter is NULL,
	//                          then a new buffer will be created.
	//          stride      -   Number of bytes for each scan line. The value must
	//                          be 0 or greater. When the value is 0,
	//                          FPDFBitmap_CreateEx() will automatically calculate
	//                          the appropriate value using |width| and |format|.
	//                          When using an external buffer, it is recommended for
	//                          the caller to pass in the value.
	//                          When not using an external buffer, it is recommended
	//                          for the caller to pass in 0.
	// Return value:
	//          The bitmap handle, or NULL if parameter error or out of memory.
	// Comments:
	//          Similar to FPDFBitmap_Create function, but allows for more formats
	//          and an external buffer is supported. The bitmap created by this
	//          function can be used in any place that a FPDF_BITMAP handle is
	//          required.
	//
	//          If an external buffer is used, then the caller should destroy the
	//          buffer. FPDFBitmap_Destroy() will not destroy the buffer.
	//
	//          It is recommended to use FPDFBitmap_GetStride() to get the stride
	//          value.
	@(link_name = "FPDFBitmap_CreateEx")
	bitmap_create_ex :: proc(width: c.int, height: c.int, format: c.int, first_scan: rawptr, stride: c.int) -> ^BITMAP ---

	// Function: FPDFBitmap_GetFormat
	//          Get the format of the bitmap.
	// Parameters:
	//          bitmap      -   Handle to the bitmap. Returned by FPDFBitmap_Create
	//                          or FPDFImageObj_GetBitmap.
	// Return value:
	//          The format of the bitmap.
	// Comments:
	//          Only formats supported by FPDFBitmap_CreateEx are supported by this
	//          function; see the list of such formats above.
	@(link_name = "FPDFBitmap_GetFormat")
	bitmap_get_format :: proc(bitmap: ^BITMAP) -> c.int ---

	// Function: FPDFBitmap_FillRect
	//          Fill a rectangle in a bitmap.
	// Parameters:
	//          bitmap      -   The handle to the bitmap. Returned by
	//                          FPDFBitmap_Create.
	//          left        -   The left position. Starting from 0 at the
	//                          left-most pixel.
	//          top         -   The top position. Starting from 0 at the
	//                          top-most line.
	//          width       -   Width in pixels to be filled.
	//          height      -   Height in pixels to be filled.
	//          color       -   A 32-bit value specifing the color, in 8888 ARGB
	//                          format.
	// Return value:
	//          None.
	// Comments:
	//          This function sets the color and (optionally) alpha value in the
	//          specified region of the bitmap.
	//
	//          NOTE: If the alpha channel is used, this function does NOT
	//          composite the background with the source color, instead the
	//          background will be replaced by the source color and the alpha.
	//
	//          If the alpha channel is not used, the alpha parameter is ignored.
	@(link_name = "FPDFBitmap_FillRect")
	bitmap_fill_rect :: proc(bitmap: ^BITMAP, left: c.int, top: c.int, width: c.int, height: c.int, color: DWORD) ---

	// Function: FPDFBitmap_GetBuffer
	//          Get data buffer of a bitmap.
	// Parameters:
	//          bitmap      -   Handle to the bitmap. Returned by FPDFBitmap_Create
	//                          or FPDFImageObj_GetBitmap.
	// Return value:
	//          The pointer to the first byte of the bitmap buffer.
	// Comments:
	//          The stride may be more than width * number of bytes per pixel
	//
	//          Applications can use this function to get the bitmap buffer pointer,
	//          then manipulate any color and/or alpha values for any pixels in the
	//          bitmap.
	//
	//          Use FPDFBitmap_GetFormat() to find out the format of the data.
	@(link_name = "FPDFBitmap_GetBuffer")
	bitmap_get_buffer :: proc(bitmap: ^BITMAP) -> rawptr ---

	// Function: FPDFBitmap_GetWidth
	//          Get width of a bitmap.
	// Parameters:
	//          bitmap      -   Handle to the bitmap. Returned by FPDFBitmap_Create
	//                          or FPDFImageObj_GetBitmap.
	// Return value:
	//          The width of the bitmap in pixels.
	@(link_name = "FPDFBitmap_GetWidth")
	bitmap_get_width :: proc(bitmap: ^BITMAP) -> c.int ---

	// Function: FPDFBitmap_GetHeight
	//          Get height of a bitmap.
	// Parameters:
	//          bitmap      -   Handle to the bitmap. Returned by FPDFBitmap_Create
	//                          or FPDFImageObj_GetBitmap.
	// Return value:
	//          The height of the bitmap in pixels.
	@(link_name = "FPDFBitmap_GetHeight")
	bitmap_get_height :: proc(bitmap: ^BITMAP) -> c.int ---

	// Function: FPDFBitmap_GetStride
	//          Get number of bytes for each line in the bitmap buffer.
	// Parameters:
	//          bitmap      -   Handle to the bitmap. Returned by FPDFBitmap_Create
	//                          or FPDFImageObj_GetBitmap.
	// Return value:
	//          The number of bytes for each line in the bitmap buffer.
	// Comments:
	//          The stride may be more than width * number of bytes per pixel.
	@(link_name = "FPDFBitmap_GetStride")
	bitmap_get_stride :: proc(bitmap: ^BITMAP) -> c.int ---

	// Function: FPDFBitmap_Destroy
	//          Destroy a bitmap and release all related buffers.
	// Parameters:
	//          bitmap      -   Handle to the bitmap. Returned by FPDFBitmap_Create
	//                          or FPDFImageObj_GetBitmap.
	// Return value:
	//          None.
	// Comments:
	//          This function will not destroy any external buffers provided when
	//          the bitmap was created.
	@(link_name = "FPDFBitmap_Destroy")
	bitmap_destroy :: proc(bitmap: ^BITMAP) ---
}

@(default_calling_convention = "c")
foreign lib {
	// Function: FPDF_VIEWERREF_GetPrintScaling
	//          Whether the PDF document prefers to be scaled or not.
	// Parameters:
	//          document    -   Handle to the loaded document.
	// Return value:
	//          None.
	@(link_name = "FPDF_VIEWERREF_GetPrintScaling")
	viewerref_get_print_scaling :: proc(document: ^DOCUMENT) -> BOOL ---

	// Function: FPDF_VIEWERREF_GetNumCopies
	//          Returns the number of copies to be printed.
	// Parameters:
	//          document    -   Handle to the loaded document.
	// Return value:
	//          The number of copies to be printed.
	@(link_name = "FPDF_VIEWERREF_GetNumCopies")
	viewerref_get_num_copies :: proc(document: ^DOCUMENT) -> c.int ---

	// Function: FPDF_VIEWERREF_GetPrintPageRange
	//          Page numbers to initialize print dialog box when file is printed.
	// Parameters:
	//          document    -   Handle to the loaded document.
	// Return value:
	//          The print page range to be used for printing.
	@(link_name = "FPDF_VIEWERREF_GetPrintPageRange")
	viewerref_get_print_page_range :: proc(document: ^DOCUMENT) -> ^PAGERANGE ---

	// Experimental API.
	// Function: FPDF_VIEWERREF_GetPrintPageRangeCount
	//          Returns the number of elements in a FPDF_PAGERANGE.
	// Parameters:
	//          pagerange   -   Handle to the page range.
	// Return value:
	//          The number of elements in the page range. Returns 0 on error.
	@(link_name = "FPDF_VIEWERREF_GetPrintPageRangeCount")
	viewerref_get_print_page_range_count :: proc(pagerange: ^PAGERANGE) -> c.int ---

	// Experimental API.
	// Function: FPDF_VIEWERREF_GetPrintPageRangeElement
	//          Returns an element from a FPDF_PAGERANGE.
	// Parameters:
	//          pagerange   -   Handle to the page range.
	//          index       -   Index of the element.
	// Return value:
	//          The value of the element in the page range at a given index.
	//          Returns -1 on error.
	@(link_name = "FPDF_VIEWERREF_GetPrintPageRangeElement")
	viewerref_get_print_page_range_element :: proc(pagerange: ^PAGERANGE, index: c.int) -> c.int ---

	// Function: FPDF_VIEWERREF_GetDuplex
	//          Returns the paper handling option to be used when printing from
	//          the print dialog.
	// Parameters:
	//          document    -   Handle to the loaded document.
	// Return value:
	//          The paper handling option to be used when printing.
	@(link_name = "FPDF_VIEWERREF_GetDuplex")
	viewerref_get_duplex :: proc(document: ^DOCUMENT) -> DUPLEXTYPE ---

	// Function: FPDF_VIEWERREF_GetName
	//          Gets the contents for a viewer ref, with a given key. The value must
	//          be of type "name".
	// Parameters:
	//          document    -   Handle to the loaded document.
	//          key         -   Name of the key in the viewer pref dictionary,
	//                          encoded in UTF-8.
	//          buffer      -   A string to write the contents of the key to.
	//          length      -   Length of the buffer.
	// Return value:
	//          The number of bytes in the contents, including the NULL terminator.
	//          Thus if the return value is 0, then that indicates an error, such
	//          as when |document| is invalid or |buffer| is NULL. If |length| is
	//          less than the returned length, or |buffer| is NULL, |buffer| will
	//          not be modified.
	@(link_name = "FPDF_VIEWERREF_GetName")
	viewerref_get_name :: proc(document: ^DOCUMENT, key: BYTESTRING, buffer: string, length: c.ulong) -> c.ulong ---
}

// PDF renderer types - Experimental.
// Selection of 2D graphics library to use for rendering to FPDF_BITMAPs.
RENDERER_TYPE :: enum {
	// Anti-Grain Geometry - https://sourceforge.net/projects/agg/
	AGG  = 0,
	// Skia - https://skia.org/
	SKIA = 1,
}

// Process-wide options for initializing the library.
LIBRARY_CONFIG :: struct {
	// Version number of the interface. Currently must be 2.
	// Support for version 1 will be deprecated in the future.
	version:          c.int,

	// Array of paths to scan in place of the defaults when using built-in
	// FXGE font loading code. The array is terminated by a NULL pointer.
	// The Array may be NULL itself to use the default paths. May be ignored
	// entirely depending upon the platform.
	m_pUserFontPaths: [dynamic]string,

	// Version 2.

	// Pointer to the v8::Isolate to use, or NULL to force PDFium to create one.
	m_pIsolate:       rawptr,

	// The embedder data slot to use in the v8::Isolate to store PDFium's
	// per-isolate data. The value needs to be in the range
	// [0, |v8::Internals::kNumIsolateDataLots|). Note that 0 is fine for most
	// embedders.
	m_v8EmbedderSlot: c.uint,

	// Version 3 - Experimental.

	// Pointer to the V8::Platform to use.
	m_pPlatform:      rawptr,

	// Version 4 - Experimental.

	// Explicit specification of core renderer to use. |m_RendererType| must be
	// a valid value for |FPDF_LIBRARY_CONFIG| versions of this level or higher,
	// or else the initialization will fail with an immediate crash.
	// Note that use of a specified |FPDF_RENDERER_TYPE| value for which the
	// corresponding render library is not included in the build will similarly
	// fail with an immediate crash.
	m_RendererType:   RENDERER_TYPE,
}

// Policy for accessing the local machine time.
POLICY_MACHINETIME_ACCESS :: 0

// Structure for custom file access.
FILEACCESS :: struct {
	// File length, in bytes.
	m_FileLen:  c.ulong,

	// A function pointer for getting a block of data from a specific position.
	// Position is specified by byte offset from the beginning of the file.
	// The pointer to the buffer is never NULL and the size is never 0.
	// The position and size will never go out of range of the file length.
	// It may be possible for FPDFSDK to call this function multiple times for
	// the same position.
	// Return value: should be non-zero if successful, zero for error.
	m_GetBlock: proc(param: rawptr, position: c.ulong, pBuf: cstring, size: c.ulong) -> c.int,

	// A custom pointer for all implementation specific data.  This pointer will
	// be used as the first parameter to the m_GetBlock callback.
	m_Param:    rawptr,
}

/*
 * Structure for file reading or writing (I/O).
 *
 * Note: This is a handler and should be implemented by callers,
 * and is only used from XFA.
 */
FILEHANDLER :: struct {
	/*
   * User-defined data.
   * Note: Callers can use this field to track controls.
   */
	clientData: rawptr,

	/*
	   * Callback function to release the current file stream object.
	   *
	   * Parameters:
	   *       clientData   -  Pointer to user-defined data.
	   * Returns:
	   *       None.
	   */
	Release:    proc(clientData: rawptr),

	/*
	   * Callback function to retrieve the current file stream size.
	   *
	   * Parameters:
	   *       clientData   -  Pointer to user-defined data.
	   * Returns:
	   *       Size of file stream.
	   */
	GetSize:    proc(clientData: rawptr) -> DWORD,

	/*
	   * Callback function to read data from the current file stream.
	   *
	   * Parameters:
	   *       clientData   -  Pointer to user-defined data.
	   *       offset       -  Offset position starts from the beginning of file
	   *                       stream. This parameter indicates reading position.
	   *       buffer       -  Memory buffer to store data which are read from
	   *                       file stream. This parameter should not be NULL.
	   *       size         -  Size of data which should be read from file stream,
	   *                       in bytes. The buffer indicated by |buffer| must be
	   *                       large enough to store specified data.
	   * Returns:
	   *       0 for success, other value for failure.
	   */
	ReadBlock:  proc(clientData: rawptr, offset: DWORD, buffer: rawptr, size: DWORD) -> RESULT,

	/*
	   * Callback function to write data into the current file stream.
	   *
	   * Parameters:
	   *       clientData   -  Pointer to user-defined data.
	   *       offset       -  Offset position starts from the beginning of file
	   *                       stream. This parameter indicates writing position.
	   *       buffer       -  Memory buffer contains data which is written into
	   *                       file stream. This parameter should not be NULL.
	   *       size         -  Size of data which should be written into file
	   *                       stream, in bytes.
	   * Returns:
	   *       0 for success, other value for failure.
	   */
	WriteBlock: proc(clientData: rawptr, offset: DWORD, buffer: rawptr, size: DWORD) -> RESULT,

	/*
	   * Callback function to flush all internal accessing buffers.
	   *
	   * Parameters:
	   *       clientData   -  Pointer to user-defined data.
	   * Returns:
	   *       0 for success, other value for failure.
	   */
	Flush:      proc(clientData: rawptr) -> RESULT,

	/*
	   * Callback function to change file size.
	   *
	   * Description:
	   *       This function is called under writing mode usually. Implementer
	   *       can determine whether to realize it based on application requests.
	   * Parameters:
	   *       clientData   -  Pointer to user-defined data.
	   *       size         -  New size of file stream, in bytes.
	   * Returns:
	   *       0 for success, other value for failure.
	   */
	Truncate:   proc(clientData: rawptr, size: DWORD) -> RESULT,
}

ERR_SUCCESS :: 0 // No error.
ERR_UNKNOWN :: 1 // Unknown error.
ERR_FILE :: 2 // File not found or could not be opened.
ERR_FORMAT :: 3 // File not in PDF format or corrupted.
ERR_PASSWORD :: 4 // Password required or incorrect password.
ERR_SECURITY :: 5 // Unsupported security scheme.
ERR_PAGE :: 6 // Page not found or content error.

// Page rendering flags. They can be combined with bit-wise OR.
//
// Set if annotations are to be rendered.
ANNOT :: 0x01
// Set if using text rendering optimized for LCD display. This flag will only
// take effect if anti-aliasing is enabled for text.
LCD_TEXT :: 0x02
// Don't use the native text output available on some platforms
NO_NATIVETEXT :: 0x04
// Grayscale output.
GRAYSCALE :: 0x08
// Obsolete, has no effect, retained for compatibility.
DEBUG_INFO :: 0x80
// Obsolete, has no effect, retained for compatibility.
NO_CATCH :: 0x100
// Limit image cache size.
RENDER_LIMITEDIMAGECACHE :: 0x200
// Always use halftone for image stretching.
RENDER_FORCEHALFTONE :: 0x400
// Render for printing.
PRINTING :: 0x800
// Set to disable anti-aliasing on text. This flag will also disable LCD
// optimization for text rendering.
RENDER_NO_SMOOTHTEXT :: 0x1000
// Set to disable anti-aliasing on images.
RENDER_NO_SMOOTHIMAGE :: 0x2000
// Set to disable anti-aliasing on paths.
RENDER_NO_SMOOTHPATH :: 0x4000
// Set whether to render in a reverse Byte order, this flag is only used when
// rendering to a bitmap.
REVERSE_BYTE_ORDER :: 0x10
// Set whether fill paths need to be stroked. This flag is only used when
// FPDF_COLORSCHEME is passed in, since with a single fill color for paths the
// boundaries of adjacent fill paths are less visible.
CONVERT_FILL_TO_STROKE :: 0x20

// Struct for color scheme.
// Each should be a 32-bit value specifying the color, in 8888 ARGB format.
COLORSCHEME :: struct {
	path_fill_color:   DWORD,
	path_stroke_color: DWORD,
	text_fill_color:   DWORD,
	text_stroke_color: DWORD,
}


// More DIB formats
// Unknown or unsupported format.
Unknown :: 0
// Gray scale bitmap, one byte per pixel.
Gray :: 1
// 3 bytes per pixel, byte order: blue, green, red.
BGR :: 2
// 4 bytes per pixel, byte order: blue, green, red, unused.
BGRx :: 3
// 4 bytes per pixel, byte order: blue, green, red, alpha.
BGRA :: 4
