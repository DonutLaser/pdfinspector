package pdfium

import "core:c"

when ODIN_OS == .Windows {
	foreign import lib "lib/pdfium.dll.lib"
} else {
	foreign import lib "system:pdfium"
}

// Unsupported action type.
PDFACTION_UNSUPPORTED :: 0
// Go to a destination within current document.
PDFACTION_GOTO :: 1
// Go to a destination within another document.
PDFACTION_REMOTEGOTO :: 2
// URI, including web pages and other Internet resources.
PDFACTION_URI :: 3
// Launch an application or open a file.
PDFACTION_LAUNCH :: 4
// Go to a destination in an embedded file.
PDFACTION_EMBEDDEDGOTO :: 5

// View destination fit types. See pdfmark reference v9, page 48.
PDFDEST_VIEW_UNKNOWN_MODE :: 0
PDFDEST_VIEW_XYZ :: 1
PDFDEST_VIEW_FIT :: 2
PDFDEST_VIEW_FITH :: 3
PDFDEST_VIEW_FITV :: 4
PDFDEST_VIEW_FITR :: 5
PDFDEST_VIEW_FITB :: 6
PDFDEST_VIEW_FITBH :: 7
PDFDEST_VIEW_FITBV :: 8

// The file identifier entry type. See section 14.4 "File Identifiers" of the
// ISO 32000-1:2008 spec.
FILEIDTYPE :: enum {
	PERMANENT = 0,
	CHANGING  = 1,
}

// @(link_name = "FPDF_VIEWERREF_GetName")

@(default_calling_convention = "c")
foreign lib {
	// Get the first child of |bookmark|, or the first top-level bookmark item.
	//
	//   document - handle to the document.
	//   bookmark - handle to the current bookmark. Pass NULL for the first top
	//              level item.
	//
	// Returns a handle to the first child of |bookmark| or the first top-level
	// bookmark item. NULL if no child or top-level bookmark found.
	@(link_name = "FPDFBookmark_GetFirstChild")
	bookmark_get_first_child :: proc(document: ^DOCUMENT, bookmark: ^BOOKMARK) -> ^BOOKMARK ---

	// Get the next sibling of |bookmark|.
	//
	//   document - handle to the document.
	//   bookmark - handle to the current bookmark.
	//
	// Returns a handle to the next sibling of |bookmark|, or NULL if this is the
	// last bookmark at this level.
	//
	// Note that the caller is responsible for handling circular bookmark
	// references, as may arise from malformed documents.
	@(link_name = "FPDFBookmark_GetNextSibling")
	bookmark_get_next_sibling :: proc(document: ^DOCUMENT, bookmark: ^BOOKMARK) -> ^BOOKMARK ---

	// Get the title of |bookmark|.
	//
	//   bookmark - handle to the bookmark.
	//   buffer   - buffer for the title. May be NULL.
	//   buflen   - the length of the buffer in bytes. May be 0.
	//
	// Returns the number of bytes in the title, including the terminating NUL
	// character. The number of bytes is returned regardless of the |buffer| and
	// |buflen| parameters.
	//
	// Regardless of the platform, the |buffer| is always in UTF-16LE encoding. The
	// string is terminated by a UTF16 NUL character. If |buflen| is less than the
	// required length, or |buffer| is NULL, |buffer| will not be modified.
	@(link_name = "FPDFBookmark_GetTitle")
	bookmark_get_title :: proc(bookmark: ^BOOKMARK, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Get the number of chlidren of |bookmark|.
	//
	//   bookmark - handle to the bookmark.
	//
	// Returns a signed integer that represents the number of sub-items the given
	// bookmark has. If the value is positive, child items shall be shown by default
	// (open state). If the value is negative, child items shall be hidden by
	// default (closed state). Please refer to PDF 32000-1:2008, Table 153.
	// Returns 0 if the bookmark has no children or is invalid.
	@(link_name = "FPDFBookmark_GetCount")
	bookmark_get_count :: proc(bookmark: ^BOOKMARK) -> c.int ---

	// Find the bookmark with |title| in |document|.
	//
	//   document - handle to the document.
	//   title    - the UTF-16LE encoded Unicode title for which to search.
	//
	// Returns the handle to the bookmark, or NULL if |title| can't be found.
	//
	// FPDFBookmark_Find() will always return the first bookmark found even if
	// multiple bookmarks have the same |title|.
	@(link_name = "FPDFBookmark_Find")
	bookmark_find :: proc(document: ^DOCUMENT, title: WIDESTRING) -> ^BOOKMARK ---

	// Get the destination associated with |bookmark|.
	//
	//   document - handle to the document.
	//   bookmark - handle to the bookmark.
	//
	// Returns the handle to the destination data, or NULL if no destination is
	// associated with |bookmark|.
	@(link_name = "FPDFBookmark_GetDest")
	bookmark_get_dest :: proc(document: ^DOCUMENT, bookmark: ^BOOKMARK) -> ^DEST ---

	// Get the action associated with |bookmark|.
	//
	//   bookmark - handle to the bookmark.
	//
	// Returns the handle to the action data, or NULL if no action is associated
	// with |bookmark|.
	// If this function returns a valid handle, it is valid as long as |bookmark| is
	// valid.
	// If this function returns NULL, FPDFBookmark_GetDest() should be called to get
	// the |bookmark| destination data.
	@(link_name = "FPDFBookmark_GetAction")
	bookmark_get_action :: proc(bookmark: ^BOOKMARK) -> ^ACTION ---
}

@(default_calling_convention = "c")
foreign lib {
	// Get the type of |action|.
	//
	//   action - handle to the action.
	//
	// Returns one of:
	//   PDFACTION_UNSUPPORTED
	//   PDFACTION_GOTO
	//   PDFACTION_REMOTEGOTO
	//   PDFACTION_URI
	//   PDFACTION_LAUNCH
	@(link_name = "FPDFAction_GetType")
	action_get_type :: proc(action: ^ACTION) -> c.ulong ---

	// Get the destination of |action|.
	//
	//   document - handle to the document.
	//   action   - handle to the action. |action| must be a |PDFACTION_GOTO| or
	//              |PDFACTION_REMOTEGOTO|.
	//
	// Returns a handle to the destination data, or NULL on error, typically
	// because the arguments were bad or the action was of the wrong type.
	//
	// In the case of |PDFACTION_REMOTEGOTO|, you must first call
	// FPDFAction_GetFilePath(), then load the document at that path, then pass
	// the document handle from that document as |document| to FPDFAction_GetDest().
	@(link_name = "FPDFAction_GetDest")
	action_get_dest :: proc(document: ^DOCUMENT, action: ^ACTION) -> ^DEST ---

	// Get the file path of |action|.
	//
	//   action - handle to the action. |action| must be a |PDFACTION_LAUNCH| or
	//            |PDFACTION_REMOTEGOTO|.
	//   buffer - a buffer for output the path string. May be NULL.
	//   buflen - the length of the buffer, in bytes. May be 0.
	//
	// Returns the number of bytes in the file path, including the trailing NUL
	// character, or 0 on error, typically because the arguments were bad or the
	// action was of the wrong type.
	//
	// Regardless of the platform, the |buffer| is always in UTF-8 encoding.
	// If |buflen| is less than the returned length, or |buffer| is NULL, |buffer|
	// will not be modified.
	@(link_name = "FPDFAction_GetFilePath")
	action_get_file_path :: proc(action: ^ACTION, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Get the URI path of |action|.
	//
	//   document - handle to the document.
	//   action   - handle to the action. Must be a |PDFACTION_URI|.
	//   buffer   - a buffer for the path string. May be NULL.
	//   buflen   - the length of the buffer, in bytes. May be 0.
	//
	// Returns the number of bytes in the URI path, including the trailing NUL
	// character, or 0 on error, typically because the arguments were bad or the
	// action was of the wrong type.
	//
	// The |buffer| may contain badly encoded data. The caller should validate the
	// output. e.g. Check to see if it is UTF-8.
	//
	// If |buflen| is less than the returned length, or |buffer| is NULL, |buffer|
	// will not be modified.
	//
	// Historically, the documentation for this API claimed |buffer| is always
	// encoded in 7-bit ASCII, but did not actually enforce it.
	// https://pdfium.googlesource.com/pdfium.git/+/d609e84cee2e14a18333247485af91df48a40592
	// added that enforcement, but that did not work well for real world PDFs that
	// used UTF-8. As of this writing, this API reverted back to its original
	// behavior prior to commit d609e84cee.
	@(link_name = "FPDFAction_GetURIPath")
	action_get_uri_path :: proc(document: ^DOCUMENT, action: ^ACTION, buffer: rawptr, buflen: c.ulong) -> c.ulong ---
}

@(default_calling_convention = "c")
foreign lib {
	// Get the page index of |dest|.
	//
	//   document - handle to the document.
	//   dest     - handle to the destination.
	//
	// Returns the 0-based page index containing |dest|. Returns -1 on error.
	@(link_name = "FPDFDest_GetDestPageIndex")
	dest_get_dest_page_index :: proc(document: ^DOCUMENT, dest: ^DEST) -> c.int ---

	// Experimental API.
	// Get the view (fit type) specified by |dest|.
	//
	//   dest         - handle to the destination.
	//   pNumParams   - receives the number of view parameters, which is at most 4.
	//   pParams      - buffer to write the view parameters. Must be at least 4
	//                  FS_FLOATs long.
	// Returns one of the PDFDEST_VIEW_* constants, PDFDEST_VIEW_UNKNOWN_MODE if
	// |dest| does not specify a view.
	@(link_name = "FPDFDest_GetView")
	dest_get_view :: proc(dest: ^DEST, pNumParams: ^c.ulong, pParams: ^FLOAT) -> c.ulong ---

	// Get the (x, y, zoom) location of |dest| in the destination page, if the
	// destination is in [page /XYZ x y zoom] syntax.
	//
	//   dest       - handle to the destination.
	//   hasXVal    - out parameter; true if the x value is not null
	//   hasYVal    - out parameter; true if the y value is not null
	//   hasZoomVal - out parameter; true if the zoom value is not null
	//   x          - out parameter; the x coordinate, in page coordinates.
	//   y          - out parameter; the y coordinate, in page coordinates.
	//   zoom       - out parameter; the zoom value.
	// Returns TRUE on successfully reading the /XYZ value.
	//
	// Note the [x, y, zoom] values are only set if the corresponding hasXVal,
	// hasYVal or hasZoomVal flags are true.
	@(link_name = "FPDFDest_GetLocationInPage")
	dest_get_location_in_page :: proc(dest: ^DEST, hasXVal: ^BOOL, hasYVal: ^BOOL, hasZoomVal: ^BOOL, x: ^FLOAT, y: ^FLOAT, zoom: ^FLOAT) -> BOOL ---
}

@(default_calling_convention = "c")
foreign lib {
	// Find a link at point (|x|,|y|) on |page|.
	//
	//   page - handle to the document page.
	//   x    - the x coordinate, in the page coordinate system.
	//   y    - the y coordinate, in the page coordinate system.
	//
	// Returns a handle to the link, or NULL if no link found at the given point.
	//
	// You can convert coordinates from screen coordinates to page coordinates using
	// FPDF_DeviceToPage().
	@(link_name = "FPDFLink_GetLinkAtPoint")
	link_get_link_at_point :: proc(page: ^PAGE, x: c.double, y: c.double) -> ^LINK ---

	// Find the Z-order of link at point (|x|,|y|) on |page|.
	//
	//   page - handle to the document page.
	//   x    - the x coordinate, in the page coordinate system.
	//   y    - the y coordinate, in the page coordinate system.
	//
	// Returns the Z-order of the link, or -1 if no link found at the given point.
	// Larger Z-order numbers are closer to the front.
	//
	// You can convert coordinates from screen coordinates to page coordinates using
	// FPDF_DeviceToPage().
	@(link_name = "FPDFLink_GetLinkZOrderAtPoint")
	link_get_link_z_order_at_point :: proc(page: ^PAGE, x: c.double, y: c.double) -> c.int ---

	// Get destination info for |link|.
	//
	//   document - handle to the document.
	//   link     - handle to the link.
	//
	// Returns a handle to the destination, or NULL if there is no destination
	// associated with the link. In this case, you should call FPDFLink_GetAction()
	// to retrieve the action associated with |link|.
	@(link_name = "FPDFLink_GetDest")
	link_get_dest :: proc(document: ^DOCUMENT, link: ^LINK) -> ^DEST ---

	// Get action info for |link|.
	//
	//   link - handle to the link.
	//
	// Returns a handle to the action associated to |link|, or NULL if no action.
	// If this function returns a valid handle, it is valid as long as |link| is
	// valid.
	@(link_name = "FPDFLink_GetAction")
	link_get_action :: proc(link: ^LINK) -> ^ACTION ---

	// Enumerates all the link annotations in |page|.
	//
	//   page       - handle to the page.
	//   start_pos  - the start position, should initially be 0 and is updated with
	//                the next start position on return.
	//   link_annot - the link handle for |startPos|.
	//
	// Returns TRUE on success.
	@(link_name = "FPDFLink_Enumerate")
	link_enumerate :: proc(page: ^PAGE, start_pos: ^c.int, link_annot: ^^LINK) -> BOOL ---

	// Experimental API.
	// Gets FPDF_ANNOTATION object for |link_annot|.
	//
	//   page       - handle to the page in which FPDF_LINK object is present.
	//   link_annot - handle to link annotation.
	//
	// Returns FPDF_ANNOTATION from the FPDF_LINK and NULL on failure,
	// if the input link annot or page is NULL.
	@(link_name = "FPDFLink_GetAnnot")
	link_get_annot :: proc(page: ^PAGE, link_annot: ^LINK) -> ^ANNOTATION ---

	// Get the rectangle for |link_annot|.
	//
	//   link_annot - handle to the link annotation.
	//   rect       - the annotation rectangle.
	//
	// Returns true on success.
	@(link_name = "FPDFLink_GetAnnotRect")
	link_get_annot_rect :: proc(link_annot: ^LINK, rect: ^RECTF) -> BOOL ---

	// Get the count of quadrilateral points to the |link_annot|.
	//
	//   link_annot - handle to the link annotation.
	//
	// Returns the count of quadrilateral points.
	@(link_name = "FPDFLink_CountQuadPoints")
	link_count_quad_points :: proc(link_annot: ^LINK) -> c.int ---

	// Get the quadrilateral points for the specified |quad_index| in |link_annot|.
	//
	//   link_annot  - handle to the link annotation.
	//   quad_index  - the specified quad point index.
	//   quad_points - receives the quadrilateral points.
	//
	// Returns true on success.
	@(link_name = "FPDFLink_GetQuadPoints")
	link_get_quad_points :: proc(link_annot: ^LINK, quad_index: c.int, quad_points: ^QUADPOINTSF) -> BOOL ---
}
