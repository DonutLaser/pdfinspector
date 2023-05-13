package pdfium

import "core:c"

when ODIN_OS == .Windows {
	foreign import lib "lib/pdfium.dll.lib"
} else {
	foreign import lib "system:pdfium"
}

// Flags used by FPDFText_FindStart function.
//
// If not set, it will not match case by default.
MATCHCASE :: 0x00000001
// If not set, it will not match the whole word by default.
MATCHWHOLEWORD :: 0x00000002
// If not set, it will skip past the current match to look for the next match.
CONSECUTIVE :: 0x00000004

@(default_calling_convention = "c")
foreign lib {
	// Function: FPDFLink_LoadWebLinks
	//          Prepare information about weblinks in a page.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	// Return Value:
	//          A handle to the page's links information structure, or
	//          NULL if something goes wrong.
	// Comments:
	//          Weblinks are those links implicitly embedded in PDF pages. PDF also
	//          has a type of annotation called "link" (FPDFTEXT doesn't deal with
	//          that kind of link). FPDFTEXT weblink feature is useful for
	//          automatically detecting links in the page contents. For example,
	//          things like "https://www.example.com" will be detected, so
	//          applications can allow user to click on those characters to activate
	//          the link, even the PDF doesn't come with link annotations.
	//
	//          FPDFLink_CloseWebLinks must be called to release resources.
	//
	@(link_name = "FPDFLink_LoadWebLinks")
	link_load_web_links :: proc(text_page: ^TEXTPAGE) -> ^PAGELINK ---

	// Function: FPDFLink_CountWebLinks
	//          Count number of detected web links.
	// Parameters:
	//          link_page   -   Handle returned by FPDFLink_LoadWebLinks.
	// Return Value:
	//          Number of detected web links.
	//
	@(link_name = "FPDFLink_CountWebLinks")
	link_count_web_links :: proc(link_page: ^PAGELINK) -> c.int ---

	// Function: FPDFLink_GetURL
	//          Fetch the URL information for a detected web link.
	// Parameters:
	//          link_page   -   Handle returned by FPDFLink_LoadWebLinks.
	//          link_index  -   Zero-based index for the link.
	//          buffer      -   A unicode buffer for the result.
	//          buflen      -   Number of 16-bit code units (not bytes) for the
	//                          buffer, including an additional terminator.
	// Return Value:
	//          If |buffer| is NULL or |buflen| is zero, return the number of 16-bit
	//          code units (not bytes) needed to buffer the result (an additional
	//          terminator is included in this count).
	//          Otherwise, copy the result into |buffer|, truncating at |buflen| if
	//          the result is too large to fit, and return the number of 16-bit code
	//          units actually copied into the buffer (the additional terminator is
	//          also included in this count).
	//          If |link_index| does not correspond to a valid link, then the result
	//          is an empty string.
	//
	@(link_name = "FPDFLink_GetURL")
	link_get_url :: proc(link_page: ^PAGELINK, link_index: c.int, buffer: ^c.ushort, buflen: c.int) -> c.int ---

	// Function: FPDFLink_CountRects
	//          Count number of rectangular areas for the link.
	// Parameters:
	//          link_page   -   Handle returned by FPDFLink_LoadWebLinks.
	//          link_index  -   Zero-based index for the link.
	// Return Value:
	//          Number of rectangular areas for the link.  If |link_index| does
	//          not correspond to a valid link, then 0 is returned.
	//
	@(link_name = "FPDFLink_CountRects")
	link_count_rects :: proc(link_page: ^PAGELINK, link_index: c.int) -> c.int ---

	// Function: FPDFLink_GetRect
	//          Fetch the boundaries of a rectangle for a link.
	// Parameters:
	//          link_page   -   Handle returned by FPDFLink_LoadWebLinks.
	//          link_index  -   Zero-based index for the link.
	//          rect_index  -   Zero-based index for a rectangle.
	//          left        -   Pointer to a double value receiving the rectangle
	//                          left boundary.
	//          top         -   Pointer to a double value receiving the rectangle
	//                          top boundary.
	//          right       -   Pointer to a double value receiving the rectangle
	//                          right boundary.
	//          bottom      -   Pointer to a double value receiving the rectangle
	//                          bottom boundary.
	// Return Value:
	//          On success, return TRUE and fill in |left|, |top|, |right|, and
	//          |bottom|. If |link_page| is invalid or if |link_index| does not
	//          correspond to a valid link, then return FALSE, and the out
	//          parameters remain unmodified.
	//
	@(link_name = "FPDFLink_GetRect")
	link_get_rect :: proc(link_page: ^PAGELINK, link_index: c.int, rect_index: c.int, left: ^c.double, top: ^c.double, right: ^c.double, bottom: ^c.double) -> BOOL ---

	// Experimental API.
	// Function: FPDFLink_GetTextRange
	//          Fetch the start char index and char count for a link.
	// Parameters:
	//          link_page         -   Handle returned by FPDFLink_LoadWebLinks.
	//          link_index        -   Zero-based index for the link.
	//          start_char_index  -   pointer to int receiving the start char index
	//          char_count        -   pointer to int receiving the char count
	// Return Value:
	//          On success, return TRUE and fill in |start_char_index| and
	//          |char_count|. if |link_page| is invalid or if |link_index| does
	//          not correspond to a valid link, then return FALSE and the out
	//          parameters remain unmodified.
	//
	@(link_name = "FPDFLink_GetTextRange")
	link_get_text_rnage :: proc(link_page: ^PAGELINK, link_index: c.int, start_char_index: ^c.int, char_count: ^c.int) -> BOOL ---

	// Function: FPDFLink_CloseWebLinks
	//          Release resources used by weblink feature.
	// Parameters:
	//          link_page   -   Handle returned by FPDFLink_LoadWebLinks.
	// Return Value:
	//          None.
	//
	@(link_name = "FPDFLink_CloseWebLinks")
	link_close_web_links :: proc(link_page: ^PAGELINK) ---
}
