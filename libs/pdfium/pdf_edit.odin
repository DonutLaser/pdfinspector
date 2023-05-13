package pdfium

import "core:c"

when ODIN_OS == .Windows {
	foreign import lib "lib/pdfium.dll.lib"
} else {
	foreign import lib "system:pdfium"
}

ARGB :: #force_inline proc(a: c.uint32_t, r: c.uint32_t, g: c.uint32_t, b: c.uint32_t) -> c.uint {
	return b & 0xff | g & 0xff << 8 | r & 0xff << 16 | a & 0xff << 24
}
GetBValue :: #force_inline proc(argb: c.uint) -> c.uint8_t {
	return cast(c.uint8_t)argb
}
GetGValue :: #force_inline proc(argb: c.uint) -> c.uint8_t {
	return cast(c.uint8_t)(cast(c.uint16_t)argb >> 8)
}
GetRValue :: #force_inline proc(argb: c.uint) -> c.uint8_t {
	return cast(c.uint8_t)argb >> 16
}
GetAValue :: #force_inline proc(argb: c.uint) -> c.uint8_t {
	return cast(c.uint8_t)argb >> 24
}

// Refer to PDF Reference version 1.7 table 4.12 for all color space families.
COLORSPACE_UNKNOWN :: 0
COLORSPACE_DEVICEGRAY :: 1
COLORSPACE_DEVICERGB :: 2
COLORSPACE_DEVICECMYK :: 3
COLORSPACE_CALGRAY :: 4
COLORSPACE_CALRGB :: 5
COLORSPACE_LAB :: 6
COLORSPACE_ICCBASED :: 7
COLORSPACE_SEPARATION :: 8
COLORSPACE_DEVICEN :: 9
COLORSPACE_INDEXED :: 10
COLORSPACE_PATTERN :: 11

// The page object constants.
PAGEOBJ_UNKNOWN :: 0
PAGEOBJ_TEXT :: 1
PAGEOBJ_PATH :: 2
PAGEOBJ_IMAGE :: 3
PAGEOBJ_SHADING :: 4
PAGEOBJ_FORM :: 5

// The path segment constants.
SEGMENT_UNKNOWN :: -1
SEGMENT_LINETO :: 0
SEGMENT_BEZIERTO :: 1
SEGMENT_MOVETO :: 2

FILLMODE_NONE :: 0
FILLMODE_ALTERNATE :: 1
FILLMODE_WINDING :: 2

FONT_TYPE1 :: 1
FONT_TRUETYPE :: 2

LINECAP_BUTT :: 0
LINECAP_ROUND :: 1
LINECAP_PROJECTING_SQUARE :: 2

LINEJOIN_MITER :: 0
LINEJOIN_ROUND :: 1
LINEJOIN_BEVEL :: 2

// See FPDF_SetPrintMode() for descriptions.
PRINTMODE_EMF :: 0
PRINTMODE_TEXTONLY :: 1
PRINTMODE_POSTSCRIPT2 :: 2
PRINTMODE_POSTSCRIPT3 :: 3
PRINTMODE_POSTSCRIPT2_PASSTHROUGH :: 4
PRINTMODE_POSTSCRIPT3_PASSTHROUGH :: 5
PRINTMODE_EMF_IMAGE_MASKS :: 6
PRINTMODE_POSTSCRIPT3_TYPE42 :: 7
PRINTMODE_POSTSCRIPT3_TYPE42_PASSTHROUGH :: 8

IMAGEOBJ_METADATA :: struct {
	// The image width in pixels.
	width:             c.uint,
	// The image height in pixels.
	height:            c.uint,
	// The image's horizontal pixel-per-inch.
	horizontal_dpi:    c.float,
	// The image's vertical pixel-per-inch.
	vertical_dpi:      c.float,
	// The number of bits used to represent each pixel.
	bits_per_pixel:    c.uint,
	// The image's colorspace. See above for the list of FPDF_COLORSPACE_*.
	colorspace:        c.int,
	// The image's marked content ID. Useful for pairing with associated alt-text.
	// A value of -1 indicates no ID.
	marked_content_id: c.int,
}

@(default_calling_convention = "c")
foreign lib {
	// TODO
	// Create a new PDF document.
	//
	// Returns a handle to a new document, or NULL on failure.
	@(link_name = "FPDF_CreateNewDocument")
	create_new_document :: proc() -> ^DOCUMENT ---
}

@(default_calling_convention = "c")
foreign lib {
	// Create a new PDF page.
	//
	//   document   - handle to document.
	//   page_index - suggested 0-based index of the page to create. If it is larger
	//                than document's current last index(L), the created page index
	//                is the next available index -- L+1.
	//   width      - the page width in points.
	//   height     - the page height in points.
	//
	// Returns the handle to the new page or NULL on failure.
	//
	// The page should be closed with FPDF_ClosePage() when finished as
	// with any other page in the document.
	@(link_name = "FPDFPage_New")
	page_new :: proc(document: ^DOCUMENT, page_index: c.int, width: c.double, height: c.double) -> ^PAGE ---

	// Delete the page at |page_index|.
	//
	//   document   - handle to document.
	//   page_index - the index of the page to delete.
	@(link_name = "FPDFPage_Delete")
	page_delete :: proc(document: ^DOCUMENT, page_index: c.int) ---

	// Get the rotation of |page|.
	//
	//   page - handle to a page
	//
	// Returns one of the following indicating the page rotation:
	//   0 - No rotation.
	//   1 - Rotated 90 degrees clockwise.
	//   2 - Rotated 180 degrees clockwise.
	//   3 - Rotated 270 degrees clockwise.
	@(link_name = "FPDFPage_GetRotation")
	page_get_rotation :: proc(page: ^PAGE) -> c.int ---

	// Set rotation for |page|.
	//
	//   page   - handle to a page.
	//   rotate - the rotation value, one of:
	//              0 - No rotation.
	//              1 - Rotated 90 degrees clockwise.
	//              2 - Rotated 180 degrees clockwise.
	//              3 - Rotated 270 degrees clockwise.
	@(link_name = "FPDFPage_SetRotation")
	page_set_rotation :: proc(page: ^PAGE, rotate: c.int) ---

	// Insert |page_obj| into |page|.
	//
	//   page     - handle to a page
	//   page_obj - handle to a page object. The |page_obj| will be automatically
	//              freed.
	@(link_name = "FPDFPage_InsertObject")
	page_insert_object :: proc(page: ^PAGE, page_obj: ^PAGEOBJECT) ---

	// Experimental API.
	// Remove |page_obj| from |page|.
	//
	//   page     - handle to a page
	//   page_obj - handle to a page object to be removed.
	//
	// Returns TRUE on success.
	//
	// Ownership is transferred to the caller. Call FPDFPageObj_Destroy() to free
	// it.
	@(link_name = "FPDFPage_RemoveObject")
	page_remove_object :: proc(page: ^PAGE, page_obj: ^PAGEOBJECT) -> BOOL ---

	// Get number of page objects inside |page|.
	//
	//   page - handle to a page.
	//
	// Returns the number of objects in |page|.
	@(link_name = "FPDFPage_CountObjects")
	page_count_objects :: proc(page: ^PAGE) -> c.int ---

	// Get object in |page| at |index|.
	//
	//   page  - handle to a page.
	//   index - the index of a page object.
	//
	// Returns the handle to the page object, or NULL on failed.
	@(link_name = "FPDFPage_GetObject")
	page_get_object :: proc(page: ^PAGE, index: c.int) -> ^PAGEOBJECT ---

	// Checks if |page| contains transparency.
	//
	//   page - handle to a page.
	//
	// Returns TRUE if |page| contains transparency.
	@(link_name = "FPDFPage_HasTransparency")
	page_has_transparency :: proc(page: ^PAGE) -> BOOL ---

	// Generate the content of |page|.
	//
	//   page - handle to a page.
	//
	// Returns TRUE on success.
	//
	// Before you save the page to a file, or reload the page, you must call
	// |FPDFPage_GenerateContent| or any changes to |page| will be lost.
	@(link_name = "FPDFPage_GenerateContent")
	page_generate_content :: proc(page: ^PAGE) -> BOOL ---

	// Transform all annotations in |page|.
	//
	//   page - handle to a page.
	//   a    - matrix value.
	//   b    - matrix value.
	//   c    - matrix value.
	//   d    - matrix value.
	//   e    - matrix value.
	//   f    - matrix value.
	//
	// The matrix is composed as:
	//   |a c e|
	//   |b d f|
	// and can be used to scale, rotate, shear and translate the |page| annotations.
	@(link_name = "FPDFPage_TransformAnnots")
	page_transform_annots :: proc(page: ^PAGE, a: c.double, b: c.double, cc: c.double, d: c.double, e: c.double, f: c.double) ---

	// Flatten annotations and form fields into the page contents.
	//
	//   page  - handle to the page.
	//   nFlag - One of the |FLAT_*| values denoting the page usage.
	//
	// Returns one of the |FLATTEN_*| values.
	//
	// Currently, all failures return |FLATTEN_FAIL| with no indication of the
	// cause.
	@(link_name = "FPDFPage_Flatten")
	page_flatten :: proc(page: ^PAGE, nFlag: c.int) -> c.int ---

	/*
	* Function: FPDFPage_HasFormFieldAtPoint
	*     Get the form field type by point.
	* Parameters:
	*     hHandle     -   Handle to the form fill module. Returned by
	*                     FPDFDOC_InitFormFillEnvironment().
	*     page        -   Handle to the page. Returned by FPDF_LoadPage().
	*     page_x      -   X position in PDF "user space".
	*     page_y      -   Y position in PDF "user space".
	* Return Value:
	*     Return the type of the form field; -1 indicates no field.
	*     See field types above.
	*/
	@(link_name = "FPDFPage_HasFormFieldAtPoint")
	page_has_form_field_at_point :: proc(hHandle: ^FORMHANDLE, page: ^PAGE, page_x: c.double, page_y: c.double) -> c.int ---

	/*
	* Function: FPDFPage_FormFieldZOrderAtPoint
	*     Get the form field z-order by point.
	* Parameters:
	*     hHandle     -   Handle to the form fill module. Returned by
	*                     FPDFDOC_InitFormFillEnvironment().
	*     page        -   Handle to the page. Returned by FPDF_LoadPage().
	*     page_x      -   X position in PDF "user space".
	*     page_y      -   Y position in PDF "user space".
	* Return Value:
	*     Return the z-order of the form field; -1 indicates no field.
	*     Higher numbers are closer to the front.
	*/
	@(link_name = "FPDFPage_FormFieldZOrderAtPoint")
	page_form_field_z_order_at_point :: proc(hHandle: ^FORMHANDLE, page: ^PAGE, page_x: c.double, page_y: c.double) -> c.int ---

	// Experimental API.
	// Gets the decoded data from the thumbnail of |page| if it exists.
	// This only modifies |buffer| if |buflen| less than or equal to the
	// size of the decoded data. Returns the size of the decoded
	// data or 0 if thumbnail DNE. Optional, pass null to just retrieve
	// the size of the buffer needed.
	//
	//   page    - handle to a page.
	//   buffer  - buffer for holding the decoded image data.
	//   buflen  - length of the buffer in bytes.
	@(link_name = "FPDFPage_GetDecodedThumbnailData")
	page_get_decoded_thumbnail_data :: proc(page: ^PAGE, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Gets the raw data from the thumbnail of |page| if it exists.
	// This only modifies |buffer| if |buflen| is less than or equal to
	// the size of the raw data. Returns the size of the raw data or 0
	// if thumbnail DNE. Optional, pass null to just retrieve the size
	// of the buffer needed.
	//
	//   page    - handle to a page.
	//   buffer  - buffer for holding the raw image data.
	//   buflen  - length of the buffer in bytes.
	@(link_name = "FPDFPage_GetRawThumbnailData")
	page_get_raw_thumbnail_data :: proc(page: ^PAGE, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Returns the thumbnail of |page| as a FPDF_BITMAP. Returns a nullptr
	// if unable to access the thumbnail's stream.
	//
	//   page - handle to a page.
	@(link_name = "FPDFPage_GetThumbnailAsBitmap")
	page_get_thumbnail_as_bitmap :: proc(page: ^PAGE) -> ^BITMAP ---

	/**
     * Set "MediaBox" entry to the page dictionary.
     *
     * page   - Handle to a page.
     * left   - The left of the rectangle.
     * bottom - The bottom of the rectangle.
     * right  - The right of the rectangle.
     * top    - The top of the rectangle.
     */
	@(link_name = "FPDFPage_SetMediaBox")
	page_set_media_box :: proc(page: ^PAGE, left: c.float, bottom: c.float, right: c.float, top: c.float) ---

	/**
     * Set "CropBox" entry to the page dictionary.
     *
     * page   - Handle to a page.
     * left   - The left of the rectangle.
     * bottom - The bottom of the rectangle.
     * right  - The right of the rectangle.
     * top    - The top of the rectangle.
     */
	@(link_name = "FPDFPage_SetCropBox")
	page_set_crop_box :: proc(page: ^PAGE, left: c.float, bottom: c.float, right: c.float, top: c.float) ---

	/**
     * Set "BleedBox" entry to the page dictionary.
     *
     * page   - Handle to a page.
     * left   - The left of the rectangle.
     * bottom - The bottom of the rectangle.
     * right  - The right of the rectangle.
     * top    - The top of the rectangle.
     */
	@(link_name = "FPDFPage_SetBleedBox")
	page_set_bleed_box :: proc(page: ^PAGE, left: c.float, bottom: c.float, right: c.float, top: c.float) ---

	/**
     * Set "TrimBox" entry to the page dictionary.
     *
     * page   - Handle to a page.
     * left   - The left of the rectangle.
     * bottom - The bottom of the rectangle.
     * right  - The right of the rectangle.
     * top    - The top of the rectangle.
     */
	@(link_name = "FPDFPage_SetTrimBox")
	page_set_trim_box :: proc(page: ^PAGE, left: c.float, bottom: c.float, right: c.float, top: c.float) ---

	/**
     * Set "ArtBox" entry to the page dictionary.
     *
     * page   - Handle to a page.
     * left   - The left of the rectangle.
     * bottom - The bottom of the rectangle.
     * right  - The right of the rectangle.
     * top    - The top of the rectangle.
     */
	@(link_name = "FPDFPage_SetArtBox")
	page_set_art_box :: proc(page: ^PAGE, left: c.float, bottom: c.float, right: c.float, top: c.float) ---

	/**
     * Get "MediaBox" entry from the page dictionary.
     *
     * page   - Handle to a page.
     * left   - Pointer to a float value receiving the left of the rectangle.
     * bottom - Pointer to a float value receiving the bottom of the rectangle.
     * right  - Pointer to a float value receiving the right of the rectangle.
     * top    - Pointer to a float value receiving the top of the rectangle.
     *
     * On success, return true and write to the out parameters. Otherwise return
     * false and leave the out parameters unmodified.
     */
	@(link_name = "FPDFPage_GetMediaBox")
	page_get_media_box :: proc(page: ^PAGE, left: ^c.float, bottom: ^c.float, right: ^c.float, top: ^c.float) -> BOOL ---

	/**
     * Get "CropBox" entry from the page dictionary.
     *
     * page   - Handle to a page.
     * left   - Pointer to a float value receiving the left of the rectangle.
     * bottom - Pointer to a float value receiving the bottom of the rectangle.
     * right  - Pointer to a float value receiving the right of the rectangle.
     * top    - Pointer to a float value receiving the top of the rectangle.
     *
     * On success, return true and write to the out parameters. Otherwise return
     * false and leave the out parameters unmodified.
     */
	@(link_name = "FPDFPage_GetCropBox")
	page_get_crop_box :: proc(page: ^PAGE, left: ^c.float, bottom: ^c.float, right: ^c.float, top: ^c.float) -> BOOL ---

	/**
     * Get "BleedBox" entry from the page dictionary.
     *
     * page   - Handle to a page.
     * left   - Pointer to a float value receiving the left of the rectangle.
     * bottom - Pointer to a float value receiving the bottom of the rectangle.
     * right  - Pointer to a float value receiving the right of the rectangle.
     * top    - Pointer to a float value receiving the top of the rectangle.
     *
     * On success, return true and write to the out parameters. Otherwise return
     * false and leave the out parameters unmodified.
     */
	@(link_name = "FPDFPage_GetBleedBox")
	page_get_bleed_box :: proc(page: ^PAGE, left: ^c.float, bottom: ^c.float, right: ^c.float, top: ^c.float) -> BOOL ---

	/**
     * Get "TrimBox" entry from the page dictionary.
     *
     * page   - Handle to a page.
     * left   - Pointer to a float value receiving the left of the rectangle.
     * bottom - Pointer to a float value receiving the bottom of the rectangle.
     * right  - Pointer to a float value receiving the right of the rectangle.
     * top    - Pointer to a float value receiving the top of the rectangle.
     *
     * On success, return true and write to the out parameters. Otherwise return
     * false and leave the out parameters unmodified.
     */
	@(link_name = "FPDFPage_GetTrimBox")
	page_get_trim_box :: proc(page: ^PAGE, left: ^c.float, bottom: ^c.float, right: ^c.float, top: ^c.float) -> BOOL ---

	/**
     * Get "ArtBox" entry from the page dictionary.
     *
     * page   - Handle to a page.
     * left   - Pointer to a float value receiving the left of the rectangle.
     * bottom - Pointer to a float value receiving the bottom of the rectangle.
     * right  - Pointer to a float value receiving the right of the rectangle.
     * top    - Pointer to a float value receiving the top of the rectangle.
     *
     * On success, return true and write to the out parameters. Otherwise return
     * false and leave the out parameters unmodified.
     */
	@(link_name = "FPDFPage_GetArtBox")
	page_get_art_box :: proc(page: ^PAGE, left: ^c.float, bottom: ^c.float, right: ^c.float, top: ^c.float) -> BOOL ---

	/**
     * Apply transforms to |page|.
     *
     * If |matrix| is provided it will be applied to transform the page.
     * If |clipRect| is provided it will be used to clip the resulting page.
     * If neither |matrix| or |clipRect| are provided this method returns |false|.
     * Returns |true| if transforms are applied.
     *
     * This function will transform the whole page, and would take effect to all the
     * objects in the page.
     *
     * page        - Page handle.
     * matrix      - Transform matrix.
     * clipRect    - Clipping rectangle.
     */
	@(link_name = "FPDFPage_TransFormWithClip")
	page_transform_with_clip :: proc(page: ^PAGE, mat: ^MATRIX, clipRect: ^RECTF) -> BOOL ---

	/**
     * Clip the page content, the page content that outside the clipping region
     * become invisible.
     *
     * A clip path will be inserted before the page content stream or content array.
     * In this way, the page content will be clipped by this clip path.
     *
     * page        - A page handle.
     * clipPath    - A handle to the clip path. (Does not take ownership.)
     */
	@(link_name = "FPDFPage_InsertClipPath")
	page_insert_clip_path :: proc(page: ^PAGE, clipPath: ^CLIPPATH) ---

}

@(default_calling_convention = "c")
foreign lib {
	// Destroy |page_obj| by releasing its resources. |page_obj| must have been
	// created by FPDFPageObj_CreateNew{Path|Rect}() or
	// FPDFPageObj_New{Text|Image}Obj(). This function must be called on
	// newly-created objects if they are not added to a page through
	// FPDFPage_InsertObject() or to an annotation through FPDFAnnot_AppendObject().
	//
	//   page_obj - handle to a page object.
	@(link_name = "FPDFPageObj_Destroy")
	pageobj_destroy :: proc(page_obj: ^PAGEOBJECT) ---

	// Checks if |page_object| contains transparency.
	//
	//   page_object - handle to a page object.
	//
	// Returns TRUE if |page_object| contains transparency.
	@(link_name = "FPDFPageObj_HasTransparency")
	pageobj_has_transparency :: proc(page_object: ^PAGEOBJECT) -> BOOL ---

	// Get type of |page_object|.
	//
	//   page_object - handle to a page object.
	//
	// Returns one of the FPDF_PAGEOBJ_* values on success, FPDF_PAGEOBJ_UNKNOWN on
	// error.
	@(link_name = "FPDFPageObj_GetType")
	pageobj_get_type :: proc(page_object: ^PAGEOBJECT) -> c.int ---

	// Transform |page_object| by the given matrix.
	//
	//   page_object - handle to a page object.
	//   a           - matrix value.
	//   b           - matrix value.
	//   c           - matrix value.
	//   d           - matrix value.
	//   e           - matrix value.
	//   f           - matrix value.
	//
	// The matrix is composed as:
	//   |a c e|
	//   |b d f|
	// and can be used to scale, rotate, shear and translate the |page_object|.
	@(link_name = "FPDFPageObj_Transform")
	pageobj_transform :: proc(page_object: ^PAGEOBJECT, a: c.double, b: c.double, cc: c.double, d: c.double, e: c.double, f: c.double) ---

	// Experimental API.
	// Get the transform matrix of a page object.
	//
	//   page_object - handle to a page object.
	//   matrix      - pointer to struct to receive the matrix value.
	//
	// The matrix is composed as:
	//   |a c e|
	//   |b d f|
	// and used to scale, rotate, shear and translate the page object.
	//
	// Returns TRUE on success.
	@(link_name = "FPDFPageObj_GetMatrix")
	pageobj_get_matrix :: proc(page_object: ^PAGEOBJECT, mat: ^MATRIX) -> BOOL ---

	// Experimental API.
	// Set the transform matrix of a page object.
	//
	//   page_object - handle to a page object.
	//   matrix      - pointer to struct with the matrix value.
	//
	// The matrix is composed as:
	//   |a c e|
	//   |b d f|
	// and can be used to scale, rotate, shear and translate the page object.
	//
	// Returns TRUE on success.
	@(link_name = "FPDFPageObj_SetMatrix")
	pageobj_set_matrix :: proc(path: ^PAGEOBJECT, mat: ^MATRIX) -> BOOL ---

	// Create a new image object.
	//
	//   document - handle to a document.
	//
	// Returns a handle to a new image object.
	@(link_name = "FPDFPageObj_NewImageObj")
	pageobj_new_image_obj :: proc(document: ^DOCUMENT) -> ^PAGEOBJECT ---

	// Experimental API.
	// Get number of content marks in |page_object|.
	//
	//   page_object - handle to a page object.
	//
	// Returns the number of content marks in |page_object|, or -1 in case of
	// failure.
	@(link_name = "FPDFPageObj_CountMarks")
	pageobj_count_marks :: proc(page_object: ^PAGEOBJECT) -> c.int ---

	// Experimental API.
	// Get content mark in |page_object| at |index|.
	//
	//   page_object - handle to a page object.
	//   index       - the index of a page object.
	//
	// Returns the handle to the content mark, or NULL on failure. The handle is
	// still owned by the library, and it should not be freed directly. It becomes
	// invalid if the page object is destroyed, either directly or indirectly by
	// unloading the page.
	@(link_name = "FPDFPageObj_GetMark")
	pageobj_get_mark :: proc(page_object: ^PAGEOBJECT, index: c.ulong) -> ^PAGEOBJECTMARK ---

	// Experimental API.
	// Add a new content mark to a |page_object|.
	//
	//   page_object - handle to a page object.
	//   name        - the name (tag) of the mark.
	//
	// Returns the handle to the content mark, or NULL on failure. The handle is
	// still owned by the library, and it should not be freed directly. It becomes
	// invalid if the page object is destroyed, either directly or indirectly by
	// unloading the page.
	@(link_name = "FPDFPageObj_AddMark")
	pageobj_add_mark :: proc(page_object: ^PAGEOBJECT, name: BYTESTRING) -> ^PAGEOBJECTMARK ---

	// Experimental API.
	// Removes a content |mark| from a |page_object|.
	// The mark handle will be invalid after the removal.
	//
	//   page_object - handle to a page object.
	//   mark        - handle to a content mark in that object to remove.
	//
	// Returns TRUE if the operation succeeded, FALSE if it failed.
	@(link_name = "FPDFPageObj_RemoveMark")
	pageobj_remove_mark :: proc(page_object: ^PAGEOBJECT, mark: ^PAGEOBJECTMARK) -> BOOL ---

	// Create a new path object at an initial position.
	//
	//   x - initial horizontal position.
	//   y - initial vertical position.
	//
	// Returns a handle to a new path object.
	@(link_name = "FPDFPageObj_CreateNewPath")
	pageobj_create_new_path :: proc(x: c.float, y: c.float) -> ^PAGEOBJECT ---

	// Create a closed path consisting of a rectangle.
	//
	//   x - horizontal position for the left boundary of the rectangle.
	//   y - vertical position for the bottom boundary of the rectangle.
	//   w - width of the rectangle.
	//   h - height of the rectangle.
	//
	// Returns a handle to the new path object.
	@(link_name = "FPDFPageObj_CreateNewRect")
	pageobj_create_new_rect :: proc(x: c.float, y: c.float, w: c.float, h: c.float) -> ^PAGEOBJECT ---

	// Get the bounding box of |page_object|.
	//
	// page_object  - handle to a page object.
	// left         - pointer where the left coordinate will be stored
	// bottom       - pointer where the bottom coordinate will be stored
	// right        - pointer where the right coordinate will be stored
	// top          - pointer where the top coordinate will be stored
	//
	// On success, returns TRUE and fills in the 4 coordinates.
	@(link_name = "FPDFPageObj_GetBounds")
	pageobj_get_bounds :: proc(page_object: ^PAGEOBJECT, left: ^c.float, bottom: ^c.float, right: ^c.float, top: ^c.float) -> BOOL ---

	// Experimental API.
	// Get the quad points that bounds |page_object|.
	//
	// page_object  - handle to a page object.
	// quad_points  - pointer where the quadrilateral points will be stored.
	//
	// On success, returns TRUE and fills in |quad_points|.
	//
	// Similar to FPDFPageObj_GetBounds(), this returns the bounds of a page
	// object. When the object is rotated by a non-multiple of 90 degrees, this API
	// returns a tighter bound that cannot be represented with just the 4 sides of
	// a rectangle.
	//
	// Currently only works the following |page_object| types: FPDF_PAGEOBJ_TEXT and
	// FPDF_PAGEOBJ_IMAGE.
	@(link_name = "FPDFPageObj_GetRotatedBounds")
	pageobj_get_rotated_bounds :: proc(page_object: ^PAGEOBJECT, quad_points: ^QUADPOINTSF) -> BOOL ---

	// Set the blend mode of |page_object|.
	//
	// page_object  - handle to a page object.
	// blend_mode   - string containing the blend mode.
	//
	// Blend mode can be one of following: Color, ColorBurn, ColorDodge, Darken,
	// Difference, Exclusion, HardLight, Hue, Lighten, Luminosity, Multiply, Normal,
	// Overlay, Saturation, Screen, SoftLight
	@(link_name = "FPDFPageObj_SetBlendMode")
	pageobj_set_blend_mode :: proc(page_object: ^PAGEOBJECT, blend_mode: BYTESTRING) ---

	// Set the stroke RGBA of a page object. Range of values: 0 - 255.
	//
	// page_object  - the handle to the page object.
	// R            - the red component for the object's stroke color.
	// G            - the green component for the object's stroke color.
	// B            - the blue component for the object's stroke color.
	// A            - the stroke alpha for the object.
	//
	// Returns TRUE on success.
	@(link_name = "FPDFPageObj_SetStrokeColor")
	pageobj_set_stroke_color :: proc(page_object: ^PAGEOBJECT, R: c.uint, G: c.uint, B: c.uint, A: c.uint) -> BOOL ---

	// Get the stroke RGBA of a page object. Range of values: 0 - 255.
	//
	// page_object  - the handle to the page object.
	// R            - the red component of the path stroke color.
	// G            - the green component of the object's stroke color.
	// B            - the blue component of the object's stroke color.
	// A            - the stroke alpha of the object.
	//
	// Returns TRUE on success.
	@(link_name = "FPDFPageObj_GetStrokeColor")
	pageobj_get_stroke_color :: proc(page_object: ^PAGEOBJECT, R: ^c.uint, G: ^c.uint, B: ^c.uint, A: ^c.uint) -> BOOL ---

	// Set the stroke width of a page object.
	//
	// path   - the handle to the page object.
	// width  - the width of the stroke.
	//
	// Returns TRUE on success
	@(link_name = "FPDFPageObj_SetStrokeWidth")
	pageobj_set_stroke_width :: proc(page_object: ^PAGEOBJECT, width: c.float) -> BOOL ---

	// Get the stroke width of a page object.
	//
	// path   - the handle to the page object.
	// width  - the width of the stroke.
	//
	// Returns TRUE on success
	@(link_name = "FPDFPageObj_GetStrokeWidth")
	pageobj_get_stroke_width :: proc(page_object: ^PAGEOBJECT, width: ^c.float) -> BOOL ---

	// Get the line join of |page_object|.
	//
	// page_object  - handle to a page object.
	//
	// Returns the line join, or -1 on failure.
	// Line join can be one of following: FPDF_LINEJOIN_MITER, FPDF_LINEJOIN_ROUND,
	// FPDF_LINEJOIN_BEVEL
	@(link_name = "FPDFPageObj_GetLineJoin")
	pageobj_get_line_join :: proc(page_object: ^PAGEOBJECT) -> c.int ---

	// Set the line join of |page_object|.
	//
	// page_object  - handle to a page object.
	// line_join    - line join
	//
	// Line join can be one of following: FPDF_LINEJOIN_MITER, FPDF_LINEJOIN_ROUND,
	// FPDF_LINEJOIN_BEVEL
	@(link_name = "FPDFPageObj_SetLineJoin")
	pageobj_set_line_join :: proc(page_object: ^PAGEOBJECT, line_join: c.int) -> BOOL ---

	// Get the line cap of |page_object|.
	//
	// page_object - handle to a page object.
	//
	// Returns the line cap, or -1 on failure.
	// Line cap can be one of following: FPDF_LINECAP_BUTT, FPDF_LINECAP_ROUND,
	// FPDF_LINECAP_PROJECTING_SQUARE
	@(link_name = "FPDFPageObj_GetLineCap")
	pageobj_get_line_cap :: proc(page_object: ^PAGEOBJECT) -> c.int ---

	// Set the line cap of |page_object|.
	//
	// page_object - handle to a page object.
	// line_cap    - line cap
	//
	// Line cap can be one of following: FPDF_LINECAP_BUTT, FPDF_LINECAP_ROUND,
	// FPDF_LINECAP_PROJECTING_SQUARE
	@(link_name = "FPDFPageObj_SetLineCap")
	pageobj_set_line_cap :: proc(page_object: ^PAGEOBJECT, line_cap: c.int) -> BOOL ---

	// Set the fill RGBA of a page object. Range of values: 0 - 255.
	//
	// page_object  - the handle to the page object.
	// R            - the red component for the object's fill color.
	// G            - the green component for the object's fill color.
	// B            - the blue component for the object's fill color.
	// A            - the fill alpha for the object.
	//
	// Returns TRUE on success.
	@(link_name = "FPDFPageObj_SetFillColor")
	pageobj_set_fill_color :: proc(page_object: ^PAGEOBJECT, R: c.uint, G: c.uint, B: c.uint, A: c.uint) -> BOOL ---

	// Get the fill RGBA of a page object. Range of values: 0 - 255.
	//
	// page_object  - the handle to the page object.
	// R            - the red component of the object's fill color.
	// G            - the green component of the object's fill color.
	// B            - the blue component of the object's fill color.
	// A            - the fill alpha of the object.
	//
	// Returns TRUE on success.
	@(link_name = "FPDFPageObj_GetFillColor")
	pageboj_get_fill_color :: proc(page_object: ^PAGEOBJECT, R: ^c.uint, G: ^c.uint, B: ^c.uint, A: ^c.uint) -> BOOL ---

	// Experimental API.
	// Get the line dash |phase| of |page_object|.
	//
	// page_object - handle to a page object.
	// phase - pointer where the dashing phase will be stored.
	//
	// Returns TRUE on success.
	@(link_name = "FPDFPageObj_GetDashPhase")
	pageobj_get_dash_phase :: proc(page_object: ^PAGEOBJECT, phase: ^c.float) -> BOOL ---

	// Experimental API.
	// Set the line dash phase of |page_object|.
	//
	// page_object - handle to a page object.
	// phase - line dash phase.
	//
	// Returns TRUE on success.
	@(link_name = "FPDFPageObj_SetDashPhase")
	pageobj_set_dash_phase :: proc(page_object: ^PAGEOBJECT, phase: c.float) -> BOOL ---

	// Experimental API.
	// Get the line dash array of |page_object|.
	//
	// page_object - handle to a page object.
	//
	// Returns the line dash array size or -1 on failure.
	@(link_name = "FPDFPageObj_GetDashCount")
	pageobj_get_dash_count :: proc(page_object: ^PAGEOBJECT) -> c.int ---

	// Experimental API.
	// Get the line dash array of |page_object|.
	//
	// page_object - handle to a page object.
	// dash_array - pointer where the dashing array will be stored.
	// dash_count - number of elements in |dash_array|.
	//
	// Returns TRUE on success.
	@(link_name = "FPDFPageObj_GetDashArray")
	pageobj_get_dash_array :: proc(page_object: ^PAGEOBJECT, dash_array: ^c.float, dash_count: c.size_t) -> BOOL ---

	// Experimental API.
	// Set the line dash array of |page_object|.
	//
	// page_object - handle to a page object.
	// dash_array - the dash array.
	// dash_count - number of elements in |dash_array|.
	// phase - the line dash phase.
	//
	// Returns TRUE on success.
	@(link_name = "FPDFPageObj_SetDashArray")
	pageobj_set_dash_array :: proc(page_object: ^PAGEOBJECT, dash_array: ^c.float, dash_count: c.size_t, phase: c.float) -> BOOL ---

	// Create a new text object using one of the standard PDF fonts.
	//
	// document   - handle to the document.
	// font       - string containing the font name, without spaces.
	// font_size  - the font size for the new text object.
	//
	// Returns a handle to a new text object, or NULL on failure
	@(link_name = "FPDFPageObj_NewTextObj")
	pageobj_new_text_obj :: proc(document: ^DOCUMENT, font: BYTESTRING, font_size: c.float) -> ^PAGEOBJECT ---

	// Create a new text object using a loaded font.
	//
	// document   - handle to the document.
	// font       - handle to the font object.
	// font_size  - the font size for the new text object.
	//
	// Returns a handle to a new text object, or NULL on failure
	@(link_name = "FPDFPageObj_CreateTextObj")
	pageobj_create_text_obj :: proc(document: ^DOCUMENT, font: ^FONT, font_size: c.float) -> ^PAGEOBJECT ---

	/**
     * Transform (scale, rotate, shear, move) the clip path of page object.
     * page_object - Handle to a page object. Returned by
     * FPDFPageObj_NewImageObj().
     *
     * a  - The coefficient "a" of the matrix.
     * b  - The coefficient "b" of the matrix.
     * c  - The coefficient "c" of the matrix.
     * d  - The coefficient "d" of the matrix.
     * e  - The coefficient "e" of the matrix.
     * f  - The coefficient "f" of the matrix.
     */
	@(link_name = "FPDFPageObj_TransformClipPath")
	pageobj_transform_clip_path :: proc(page_object: ^PAGEOBJECT, a: c.double, b: c.double, cc: c.double, d: c.double, e: c.double, f: c.double) ---

	// Experimental API.
	// Get the clip path of the page object.
	//
	//   page object - Handle to a page object. Returned by e.g.
	//                 FPDFPage_GetObject().
	//
	// Returns the handle to the clip path, or NULL on failure. The caller does not
	// take ownership of the returned FPDF_CLIPPATH. Instead, it remains valid until
	// FPDF_ClosePage() is called for the page containing |page_object|.
	@(link_name = "FPDFPageObj_GetClipPath")
	pageobj_get_clip_path :: proc(page_object: ^PAGEOBJECT) -> ^CLIPPATH ---
}

@(default_calling_convention = "c")
foreign lib {
	// Experimental API.
	// Get the name of a content mark.
	//
	//   mark       - handle to a content mark.
	//   buffer     - buffer for holding the returned name in UTF-16LE. This is only
	//                modified if |buflen| is longer than the length of the name.
	//                Optional, pass null to just retrieve the size of the buffer
	//                needed.
	//   buflen     - length of the buffer.
	//   out_buflen - pointer to variable that will receive the minimum buffer size
	//                to contain the name. Not filled if FALSE is returned.
	//
	// Returns TRUE if the operation succeeded, FALSE if it failed.
	@(link_name = "FPDFPageObjMark_GetName")
	pageobjmark_get_name :: proc(mark: ^PAGEOBJECTMARK, buffer: rawptr, buflen: c.ulong, out_buflen: ^c.ulong) -> BOOL ---

	// Experimental API.
	// Get the number of key/value pair parameters in |mark|.
	//
	//   mark   - handle to a content mark.
	//
	// Returns the number of key/value pair parameters |mark|, or -1 in case of
	// failure.
	@(link_name = "FPDFPageObjMark_CountParams")
	pageobjmark_count_params :: proc(mark: ^PAGEOBJECTMARK) -> c.int ---

	// Experimental API.
	// Get the key of a property in a content mark.
	//
	//   mark       - handle to a content mark.
	//   index      - index of the property.
	//   buffer     - buffer for holding the returned key in UTF-16LE. This is only
	//                modified if |buflen| is longer than the length of the key.
	//                Optional, pass null to just retrieve the size of the buffer
	//                needed.
	//   buflen     - length of the buffer.
	//   out_buflen - pointer to variable that will receive the minimum buffer size
	//                to contain the key. Not filled if FALSE is returned.
	//
	// Returns TRUE if the operation was successful, FALSE otherwise.
	@(link_name = "FPDFPageObjMark_GetParamKey")
	pageobjmark_get_param_key :: proc(mark: ^PAGEOBJECTMARK, index: c.ulong, buffer: rawptr, buflen: c.ulong, out_buflen: ^c.ulong) -> BOOL ---

	// Experimental API.
	// Get the type of the value of a property in a content mark by key.
	//
	//   mark   - handle to a content mark.
	//   key    - string key of the property.
	//
	// Returns the type of the value, or FPDF_OBJECT_UNKNOWN in case of failure.
	@(link_name = "FPDFPageObjMark_GetParamValueType")
	pageobjmark_get_param_value_type :: proc(mark: ^PAGEOBJECTMARK, key: BYTESTRING) -> OBJECT_TYPE ---

	// Experimental API.
	// Get the value of a number property in a content mark by key as int.
	// FPDFPageObjMark_GetParamValueType() should have returned FPDF_OBJECT_NUMBER
	// for this property.
	//
	//   mark      - handle to a content mark.
	//   key       - string key of the property.
	//   out_value - pointer to variable that will receive the value. Not filled if
	//               false is returned.
	//
	// Returns TRUE if the key maps to a number value, FALSE otherwise.
	@(link_name = "FPDFPageObjMark_GetParamIntValue")
	pageobjmark_get_param_int_value :: proc(mark: ^PAGEOBJECTMARK, key: BYTESTRING, out_value: ^c.int) -> BOOL ---

	// Experimental API.
	// Get the value of a string property in a content mark by key.
	//
	//   mark       - handle to a content mark.
	//   key        - string key of the property.
	//   buffer     - buffer for holding the returned value in UTF-16LE. This is
	//                only modified if |buflen| is longer than the length of the
	//                value.
	//                Optional, pass null to just retrieve the size of the buffer
	//                needed.
	//   buflen     - length of the buffer.
	//   out_buflen - pointer to variable that will receive the minimum buffer size
	//                to contain the value. Not filled if FALSE is returned.
	//
	// Returns TRUE if the key maps to a string/blob value, FALSE otherwise.
	@(link_name = "FPDFPageObjMark_GetParamStringValue")
	pageobjmark_get_param_string_value :: proc(mark: ^PAGEOBJECTMARK, key: BYTESTRING, buffer: rawptr, buflen: c.ulong, out_buflen: ^c.ulong) -> BOOL ---

	// Experimental API.
	// Get the value of a blob property in a content mark by key.
	//
	//   mark       - handle to a content mark.
	//   key        - string key of the property.
	//   buffer     - buffer for holding the returned value. This is only modified
	//                if |buflen| is at least as long as the length of the value.
	//                Optional, pass null to just retrieve the size of the buffer
	//                needed.
	//   buflen     - length of the buffer.
	//   out_buflen - pointer to variable that will receive the minimum buffer size
	//                to contain the value. Not filled if FALSE is returned.
	//
	// Returns TRUE if the key maps to a string/blob value, FALSE otherwise.
	@(link_name = "FPDFPageObjMark_GetParamBlobValue")
	pageobjmark_get_param_blob_value :: proc(mark: ^PAGEOBJECTMARK, key: BYTESTRING, buffer: rawptr, buflen: c.ulong, out_buflen: ^c.ulong) -> BOOL ---

	// Experimental API.
	// Set the value of an int property in a content mark by key. If a parameter
	// with key |key| exists, its value is set to |value|. Otherwise, it is added as
	// a new parameter.
	//
	//   document    - handle to the document.
	//   page_object - handle to the page object with the mark.
	//   mark        - handle to a content mark.
	//   key         - string key of the property.
	//   value       - int value to set.
	//
	// Returns TRUE if the operation succeeded, FALSE otherwise.
	@(link_name = "FPDFPageObjMark_SetIntParam")
	pageobjmark_set_int_param :: proc(document: ^DOCUMENT, page_object: ^PAGEOBJECT, mark: ^PAGEOBJECTMARK, key: BYTESTRING, value: c.int) -> BOOL ---

	// Experimental API.
	// Set the value of a string property in a content mark by key. If a parameter
	// with key |key| exists, its value is set to |value|. Otherwise, it is added as
	// a new parameter.
	//
	//   document    - handle to the document.
	//   page_object - handle to the page object with the mark.
	//   mark        - handle to a content mark.
	//   key         - string key of the property.
	//   value       - string value to set.
	//
	// Returns TRUE if the operation succeeded, FALSE otherwise.
	@(link_name = "FPDFPageObjMark_SetStringParam")
	pageobjmark_set_string_param :: proc(document: ^DOCUMENT, page_object: ^PAGEOBJECT, mark: ^PAGEOBJECTMARK, key: BYTESTRING, value: BYTESTRING) -> BOOL ---

	// Experimental API.
	// Set the value of a blob property in a content mark by key. If a parameter
	// with key |key| exists, its value is set to |value|. Otherwise, it is added as
	// a new parameter.
	//
	//   document    - handle to the document.
	//   page_object - handle to the page object with the mark.
	//   mark        - handle to a content mark.
	//   key         - string key of the property.
	//   value       - pointer to blob value to set.
	//   value_len   - size in bytes of |value|.
	//
	// Returns TRUE if the operation succeeded, FALSE otherwise.
	@(link_name = "FPDFPageObjMark_SetBlobParam")
	pageobjmark_set_blob_param :: proc(document: ^DOCUMENT, page_object: ^PAGEOBJECT, mark: ^PAGEOBJECTMARK, key: BYTESTRING, value: rawptr, value_len: c.ulong) -> BOOL ---

	// Experimental API.
	// Removes a property from a content mark by key.
	//
	//   page_object - handle to the page object with the mark.
	//   mark        - handle to a content mark.
	//   key         - string key of the property.
	//
	// Returns TRUE if the operation succeeded, FALSE otherwise.
	@(link_name = "FPDFPageObjMark_RemoveParam")
	pageobjmark_remove_param :: proc(page_object: ^PAGEOBJECT, mark: ^PAGEOBJECTMARK, key: BYTESTRING) -> BOOL ---
}

@(default_calling_convention = "c")
foreign lib {
	// Load an image from a JPEG image file and then set it into |image_object|.
	//
	//   pages        - pointer to the start of all loaded pages, may be NULL.
	//   count        - number of |pages|, may be 0.
	//   image_object - handle to an image object.
	//   file_access  - file access handler which specifies the JPEG image file.
	//
	// Returns TRUE on success.
	//
	// The image object might already have an associated image, which is shared and
	// cached by the loaded pages. In that case, we need to clear the cached image
	// for all the loaded pages. Pass |pages| and page count (|count|) to this API
	// to clear the image cache. If the image is not previously shared, or NULL is a
	// valid |pages| value.
	@(link_name = "FPDFImageObj_LoadJpegFile")
	imageobj_load_jpeg_file :: proc(pages: ^^PAGE, count: c.int, image_object: ^PAGEOBJECT, file_access: ^FILEACCESS) -> BOOL ---

	// Load an image from a JPEG image file and then set it into |image_object|.
	//
	//   pages        - pointer to the start of all loaded pages, may be NULL.
	//   count        - number of |pages|, may be 0.
	//   image_object - handle to an image object.
	//   file_access  - file access handler which specifies the JPEG image file.
	//
	// Returns TRUE on success.
	//
	// The image object might already have an associated image, which is shared and
	// cached by the loaded pages. In that case, we need to clear the cached image
	// for all the loaded pages. Pass |pages| and page count (|count|) to this API
	// to clear the image cache. If the image is not previously shared, or NULL is a
	// valid |pages| value. This function loads the JPEG image inline, so the image
	// content is copied to the file. This allows |file_access| and its associated
	// data to be deleted after this function returns.
	@(link_name = "FPDFImageObj_LoadJpegFileInline")
	imageobj_load_jpeg_file_inline :: proc(pages: ^^PAGE, count: c.int, image_object: ^PAGEOBJECT, file_access: ^FILEACCESS) -> BOOL ---

	// TODO(thestig): Start deprecating this once FPDFPageObj_SetMatrix() is stable.
	//
	// Set the transform matrix of |image_object|.
	//
	//   image_object - handle to an image object.
	//   a            - matrix value.
	//   b            - matrix value.
	//   c            - matrix value.
	//   d            - matrix value.
	//   e            - matrix value.
	//   f            - matrix value.
	//
	// The matrix is composed as:
	//   |a c e|
	//   |b d f|
	// and can be used to scale, rotate, shear and translate the |image_object|.
	//
	// Returns TRUE on success.
	@(link_name = "FPDFImageObj_SetMatrix")
	imageobj_set_matrix :: proc(image_object: ^PAGEOBJECT, a: c.double, b: c.double, cc: c.double, d: c.double, e: c.double, f: c.double) -> BOOL ---

	// Set |bitmap| to |image_object|.
	//
	//   pages        - pointer to the start of all loaded pages, may be NULL.
	//   count        - number of |pages|, may be 0.
	//   image_object - handle to an image object.
	//   bitmap       - handle of the bitmap.
	//
	// Returns TRUE on success.
	@(link_name = "FPDFImageObj_SetBitmap")
	imageobj_set_bitmap :: proc(pages: ^^PAGE, count: c.int, image_object: ^PAGEOBJECT, bitmap: ^BITMAP) -> BOOL ---

	// Get a bitmap rasterization of |image_object|. FPDFImageObj_GetBitmap() only
	// operates on |image_object| and does not take the associated image mask into
	// account. It also ignores the matrix for |image_object|.
	// The returned bitmap will be owned by the caller, and FPDFBitmap_Destroy()
	// must be called on the returned bitmap when it is no longer needed.
	//
	//   image_object - handle to an image object.
	//
	// Returns the bitmap.
	@(link_name = "FPDFImageObj_GetBitmap")
	imageobj_get_bitmap :: proc(image_object: ^PAGEOBJECT) -> ^BITMAP ---

	// Experimental API.
	// Get a bitmap rasterization of |image_object| that takes the image mask and
	// image matrix into account. To render correctly, the caller must provide the
	// |document| associated with |image_object|. If there is a |page| associated
	// with |image_object|, the caller should provide that as well.
	// The returned bitmap will be owned by the caller, and FPDFBitmap_Destroy()
	// must be called on the returned bitmap when it is no longer needed.
	//
	//   document     - handle to a document associated with |image_object|.
	//   page         - handle to an optional page associated with |image_object|.
	//   image_object - handle to an image object.
	//
	// Returns the bitmap or NULL on failure.
	@(link_name = "FPDFImageObj_GetRenderedBitmap")
	imageobj_get_rendered_bitmap :: proc(document: ^DOCUMENT, page: ^PAGE, image_object: ^PAGEOBJECT) -> ^BITMAP ---

	// Get the decoded image data of |image_object|. The decoded data is the
	// uncompressed image data, i.e. the raw image data after having all filters
	// applied. |buffer| is only modified if |buflen| is longer than the length of
	// the decoded image data.
	//
	//   image_object - handle to an image object.
	//   buffer       - buffer for holding the decoded image data.
	//   buflen       - length of the buffer in bytes.
	//
	// Returns the length of the decoded image data.
	@(link_name = "FPDFImageObj_GetImageDataDecoded")
	imageobj_get_image_data_decoded :: proc(image_object: ^PAGEOBJECT, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Get the raw image data of |image_object|. The raw data is the image data as
	// stored in the PDF without applying any filters. |buffer| is only modified if
	// |buflen| is longer than the length of the raw image data.
	//
	//   image_object - handle to an image object.
	//   buffer       - buffer for holding the raw image data.
	//   buflen       - length of the buffer in bytes.
	//
	// Returns the length of the raw image data.
	@(link_name = "FPDFImageObj_GetImageDataRaw")
	imageobj_get_image_data_raw :: proc(image_object: ^PAGEOBJECT, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Get the number of filters (i.e. decoders) of the image in |image_object|.
	//
	//   image_object - handle to an image object.
	//
	// Returns the number of |image_object|'s filters.
	@(link_name = "FPDFImageObj_GetImageFilterCount")
	imageobj_get_image_filter_count :: proc(image_object: ^PAGEOBJECT) -> c.int ---

	// Get the filter at |index| of |image_object|'s list of filters. Note that the
	// filters need to be applied in order, i.e. the first filter should be applied
	// first, then the second, etc. |buffer| is only modified if |buflen| is longer
	// than the length of the filter string.
	//
	//   image_object - handle to an image object.
	//   index        - the index of the filter requested.
	//   buffer       - buffer for holding filter string, encoded in UTF-8.
	//   buflen       - length of the buffer.
	//
	// Returns the length of the filter string.
	@(link_name = "FPDFImageObj_GetImageFilter")
	imageobj_get_image_filter :: proc(image_object: ^PAGEOBJECT, index: c.int, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Get the image metadata of |image_object|, including dimension, DPI, bits per
	// pixel, and colorspace. If the |image_object| is not an image object or if it
	// does not have an image, then the return value will be false. Otherwise,
	// failure to retrieve any specific parameter would result in its value being 0.
	//
	//   image_object - handle to an image object.
	//   page         - handle to the page that |image_object| is on. Required for
	//                  retrieving the image's bits per pixel and colorspace.
	//   metadata     - receives the image metadata; must not be NULL.
	//
	// Returns true if successful.
	@(link_name = "FPDFImageObj_GetImageMetadata")
	imageobj_get_image_metadata :: proc(image_object: ^PAGEOBJECT, page: ^PAGE, metadata: ^IMAGEOBJ_METADATA) -> BOOL ---

	// Experimental API.
	// Get the image size in pixels. Faster method to get only image size.
	//
	//   image_object - handle to an image object.
	//   width        - receives the image width in pixels; must not be NULL.
	//   height       - receives the image height in pixels; must not be NULL.
	//
	// Returns true if successful.
	@(link_name = "FPDFImageObj_GetImagePixelSize")
	imageobj_get_image_pixel_size :: proc(image_object: ^PAGEOBJECT, width: ^c.uint, height: ^c.uint) -> BOOL ---
}

@(default_calling_convention = "c")
foreign lib {
	// Get number of segments inside |path|.
	//
	//   path - handle to a path.
	//
	// A segment is a command, created by e.g. FPDFPath_MoveTo(),
	// FPDFPath_LineTo() or FPDFPath_BezierTo().
	//
	// Returns the number of objects in |path| or -1 on failure.
	@(link_name = "FPDFPath_CountSegments")
	path_count_segments :: proc(path: ^PAGEOBJECT) -> c.int ---

	// Get segment in |path| at |index|.
	//
	//   path  - handle to a path.
	//   index - the index of a segment.
	//
	// Returns the handle to the segment, or NULL on faiure.
	@(link_name = "FPDFPath_GetPathSegment")
	path_get_path_segments :: proc(path: ^PAGEOBJECT, index: c.int) -> ^PATHSEGMENT ---

	// Move a path's current point.
	//
	// path   - the handle to the path object.
	// x      - the horizontal position of the new current point.
	// y      - the vertical position of the new current point.
	//
	// Note that no line will be created between the previous current point and the
	// new one.
	//
	// Returns TRUE on success
	@(link_name = "FPDFPath_MoveTo")
	path_move_to :: proc(path: ^PAGEOBJECT, x: c.float, y: c.float) -> BOOL ---

	// Add a line between the current point and a new point in the path.
	//
	// path   - the handle to the path object.
	// x      - the horizontal position of the new point.
	// y      - the vertical position of the new point.
	//
	// The path's current point is changed to (x, y).
	//
	// Returns TRUE on success
	@(link_name = "FPDFPath_LineTo")
	path_line_to :: proc(path: ^PAGEOBJECT, x: c.float, y: c.float) -> BOOL ---

	// Add a cubic Bezier curve to the given path, starting at the current point.
	//
	// path   - the handle to the path object.
	// x1     - the horizontal position of the first Bezier control point.
	// y1     - the vertical position of the first Bezier control point.
	// x2     - the horizontal position of the second Bezier control point.
	// y2     - the vertical position of the second Bezier control point.
	// x3     - the horizontal position of the ending point of the Bezier curve.
	// y3     - the vertical position of the ending point of the Bezier curve.
	//
	// Returns TRUE on success
	@(link_name = "FPDFPath_BezierTo")
	path_bezier_to :: proc(path: ^PAGEOBJECT, x1: c.float, y1: c.float, x2: c.float, y2: c.float, x3: c.float, y3: c.float) -> BOOL ---

	// Close the current subpath of a given path.
	//
	// path   - the handle to the path object.
	//
	// This will add a line between the current point and the initial point of the
	// subpath, thus terminating the current subpath.
	//
	// Returns TRUE on success
	@(link_name = "FPDFPath_Close")
	path_close :: proc(path: ^PAGEOBJECT) -> BOOL ---

	// Set the drawing mode of a path.
	//
	// path     - the handle to the path object.
	// fillmode - the filling mode to be set: one of the FPDF_FILLMODE_* flags.
	// stroke   - a boolean specifying if the path should be stroked or not.
	//
	// Returns TRUE on success
	@(link_name = "FPDFPath_SetDrawMode")
	path_set_draw_move :: proc(path: ^PAGEOBJECT, fillmode: c.int, stroke: BOOL) -> BOOL ---

	// Get the drawing mode of a path.
	//
	// path     - the handle to the path object.
	// fillmode - the filling mode of the path: one of the FPDF_FILLMODE_* flags.
	// stroke   - a boolean specifying if the path is stroked or not.
	//
	// Returns TRUE on success
	@(link_name = "FPDFPath_GetDrawMode")
	path_get_draw_mode :: proc(path: ^PAGEOBJECT, fillmode: ^c.int, stroke: ^BOOL) -> BOOL ---
}

@(default_calling_convention = "c")
foreign lib {
	// Get coordinates of |segment|.
	//
	//   segment  - handle to a segment.
	//   x      - the horizontal position of the segment.
	//   y      - the vertical position of the segment.
	//
	// Returns TRUE on success, otherwise |x| and |y| is not set.
	@(link_name = "FPDFPathSegment_GetPoint")
	pathsegment_get_point :: proc(segment: ^PATHSEGMENT, x: ^c.float, y: ^c.float) -> BOOL ---

	// Get type of |segment|.
	//
	//   segment - handle to a segment.
	//
	// Returns one of the FPDF_SEGMENT_* values on success,
	// FPDF_SEGMENT_UNKNOWN on error.
	@(link_name = "FPDFPathSegment_GetType")
	pathsegment_get_type :: proc(segment: ^PATHSEGMENT) -> c.int ---

	// Gets if the |segment| closes the current subpath of a given path.
	//
	//   segment - handle to a segment.
	//
	// Returns close flag for non-NULL segment, FALSE otherwise.
	@(link_name = "FPDFPathSegment_GetClose")
	pathsegment_get_close :: proc(segment: ^PATHSEGMENT) -> BOOL ---
}

@(default_calling_convention = "c")
foreign lib {
	// Set the text for a text object. If it had text, it will be replaced.
	//
	// text_object  - handle to the text object.
	// text         - the UTF-16LE encoded string containing the text to be added.
	//
	// Returns TRUE on success
	@(link_name = "FPDFText_SetText")
	text_set_text :: proc(text_object: ^PAGEOBJECT, text: WIDESTRING) -> BOOL ---

	// Experimental API.
	// Set the text using charcodes for a text object. If it had text, it will be
	// replaced.
	//
	// text_object  - handle to the text object.
	// charcodes    - pointer to an array of charcodes to be added.
	// count        - number of elements in |charcodes|.
	//
	// Returns TRUE on success
	@(link_name = "FPDFText_SetCharcodes")
	text_set_charcodes :: proc(text_object: ^PAGEOBJECT, charcodes: ^c.uint32_t, count: c.size_t) -> BOOL ---

	// Returns a font object loaded from a stream of data. The font is loaded
	// into the document.
	//
	// document   - handle to the document.
	// data       - the stream of data, which will be copied by the font object.
	// size       - size of the stream, in bytes.
	// font_type  - FPDF_FONT_TYPE1 or FPDF_FONT_TRUETYPE depending on the font
	// type.
	// cid        - a boolean specifying if the font is a CID font or not.
	//
	// The loaded font can be closed using FPDFFont_Close.
	//
	// Returns NULL on failure
	@(link_name = "FPDFText_LoadFont")
	text_load_font :: proc(document: ^DOCUMENT, data: ^c.uint8_t, size: c.uint32_t, font_type: c.int, cid: BOOL) -> ^FONT ---

	// Experimental API.
	// Loads one of the standard 14 fonts per PDF spec 1.7 page 416. The preferred
	// way of using font style is using a dash to separate the name from the style,
	// for example 'Helvetica-BoldItalic'.
	//
	// document   - handle to the document.
	// font       - string containing the font name, without spaces.
	//
	// The loaded font can be closed using FPDFFont_Close.
	//
	// Returns NULL on failure.
	@(link_name = "FPDFText_LoadStandardFont")
	text_load_standard_font :: proc(document: ^DOCUMENT, font: BYTESTRING) -> ^FONT ---

	// Get the character index in |text_page| internal character list.
	//
	//   text_page  - a text page information structure.
	//   nTextIndex - index of the text returned from FPDFText_GetText().
	//
	// Returns the index of the character in internal character list. -1 for error.
	@(link_name = "FPDFText_GetCharIndexFromTextIndex")
	text_get_char_index_from_text_index :: proc(text_page: ^TEXTPAGE, nTextIndex: c.int) -> c.int ---

	// Get the text index in |text_page| internal character list.
	//
	//   text_page  - a text page information structure.
	//   nCharIndex - index of the character in internal character list.
	//
	// Returns the index of the text returned from FPDFText_GetText(). -1 for error.
	@(link_name = "FPDFText_GetTextIndexFromCharIndex")
	text_get_text_index_from_char_index :: proc(text_page: ^TEXTPAGE, nCharIndex: c.int) -> c.int ---

	// Function: FPDFText_LoadPage
	//          Prepare information about all characters in a page.
	// Parameters:
	//          page    -   Handle to the page. Returned by FPDF_LoadPage function
	//                      (in FPDFVIEW module).
	// Return value:
	//          A handle to the text page information structure.
	//          NULL if something goes wrong.
	// Comments:
	//          Application must call FPDFText_ClosePage to release the text page
	//          information.
	//
	@(link_name = "FPDFText_LoadPage")
	text_load_page :: proc(page: ^PAGE) -> ^TEXTPAGE ---

	// Function: FPDFText_ClosePage
	//          Release all resources allocated for a text page information
	//          structure.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	// Return Value:
	//          None.
	//
	@(link_name = "FPDFText_ClosePage")
	text_close_page :: proc(text_page: ^TEXTPAGE) ---

	// Function: FPDFText_CountChars
	//          Get number of characters in a page.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	// Return value:
	//          Number of characters in the page. Return -1 for error.
	//          Generated characters, like additional space characters, new line
	//          characters, are also counted.
	// Comments:
	//          Characters in a page form a "stream", inside the stream, each
	//          character has an index.
	//          We will use the index parameters in many of FPDFTEXT functions. The
	//          first character in the page
	//          has an index value of zero.
	//
	@(link_name = "FPDFText_CountChars")
	text_count_chars :: proc(text_page: ^TEXTPAGE) -> c.int ---

	// Function: FPDFText_GetUnicode
	//          Get Unicode of a character in a page.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	//          index       -   Zero-based index of the character.
	// Return value:
	//          The Unicode of the particular character.
	//          If a character is not encoded in Unicode and Foxit engine can't
	//          convert to Unicode,
	//          the return value will be zero.
	//
	@(link_name = "FPDFText_GetUnicode")
	text_get_unicode :: proc(text_page: ^TEXTPAGE, index: c.int) -> c.uint ---

	// Experimental API.
	// Function: FPDFText_IsGenerated
	//          Get if a character in a page is generated by PDFium.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	//          index       -   Zero-based index of the character.
	// Return value:
	//          1 if the character is generated by PDFium.
	//          0 if the character is not generated by PDFium.
	//          -1 if there was an error.
	//
	@(link_name = "FPDFText_IsGenerated")
	text_is_generated :: proc(text_page: ^TEXTPAGE, index: c.int) -> c.int ---

	// Experimental API.
	// Function: FPDFText_HasUnicodeMapError
	//          Get if a character in a page has an invalid unicode mapping.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	//          index       -   Zero-based index of the character.
	// Return value:
	//          1 if the character has an invalid unicode mapping.
	//          0 if the character has no known unicode mapping issues.
	//          -1 if there was an error.
	//
	@(link_name = "FPDFText_HasUnicodeMapError")
	text_has_unicode_map_error :: proc(text_page: ^TEXTPAGE, index: c.int) -> c.int ---

	// Function: FPDFText_GetFontSize
	//          Get the font size of a particular character.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	//          index       -   Zero-based index of the character.
	// Return value:
	//          The font size of the particular character, measured in points (about
	//          1/72 inch). This is the typographic size of the font (so called
	//          "em size").
	//
	@(link_name = "FPDFText_GetFontSize")
	text_get_font_size :: proc(text_page: ^TEXTPAGE, index: c.int) -> c.double ---

	// Experimental API.
	// Function: FPDFText_GetFontInfo
	//          Get the font name and flags of a particular character.
	// Parameters:
	//          text_page - Handle to a text page information structure.
	//                      Returned by FPDFText_LoadPage function.
	//          index     - Zero-based index of the character.
	//          buffer    - A buffer receiving the font name.
	//          buflen    - The length of |buffer| in bytes.
	//          flags     - Optional pointer to an int receiving the font flags.
	//                      These flags should be interpreted per PDF spec 1.7
	//                      Section 5.7.1 Font Descriptor Flags.
	// Return value:
	//          On success, return the length of the font name, including the
	//          trailing NUL character, in bytes. If this length is less than or
	//          equal to |length|, |buffer| is set to the font name, |flags| is
	//          set to the font flags. |buffer| is in UTF-8 encoding. Return 0 on
	//          failure.
	//
	@(link_name = "FPDFText_GetFontInfo")
	text_get_font_info :: proc(text_page: ^TEXTPAGE, index: c.int, buffer: rawptr, buflen: c.ulong, flags: ^c.int) -> c.ulong ---

	// Experimental API.
	// Function: FPDFText_GetFontWeight
	//          Get the font weight of a particular character.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	//          index       -   Zero-based index of the character.
	// Return value:
	//          On success, return the font weight of the particular character. If
	//          |text_page| is invalid, if |index| is out of bounds, or if the
	//          character's text object is undefined, return -1.
	//
	@(link_name = "FPDFText_GetFontWeight")
	txt_get_font_weight :: proc(text_page: ^TEXTPAGE, index: c.int) -> c.int ---

	// Experimental API.
	// Function: FPDFText_GetTextRenderMode
	//          Get text rendering mode of character.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	//          index       -   Zero-based index of the character.
	// Return Value:
	//          On success, return the render mode value. A valid value is of type
	//          FPDF_TEXT_RENDERMODE. If |text_page| is invalid, if |index| is out
	//          of bounds, or if the text object is undefined, then return
	//          FPDF_TEXTRENDERMODE_UNKNOWN.
	//
	@(link_name = "FPDFText_GetTextRenderMode")
	text_get_text_render_mode :: proc(text_page: ^TEXTPAGE, index: c.int) -> TEXT_RENDERMODE ---

	// Experimental API.
	// Function: FPDFText_GetFillColor
	//          Get the fill color of a particular character.
	// Parameters:
	//          text_page      -   Handle to a text page information structure.
	//                             Returned by FPDFText_LoadPage function.
	//          index          -   Zero-based index of the character.
	//          R              -   Pointer to an unsigned int number receiving the
	//                             red value of the fill color.
	//          G              -   Pointer to an unsigned int number receiving the
	//                             green value of the fill color.
	//          B              -   Pointer to an unsigned int number receiving the
	//                             blue value of the fill color.
	//          A              -   Pointer to an unsigned int number receiving the
	//                             alpha value of the fill color.
	// Return value:
	//          Whether the call succeeded. If false, |R|, |G|, |B| and |A| are
	//          unchanged.
	//
	@(link_name = "FPDFText_GetFillColor")
	text_get_fill_color :: proc(text_page: ^TEXTPAGE, index: c.int, R: ^c.uint, G: ^c.uint, B: ^c.uint, A: ^c.uint) -> BOOL ---

	// Experimental API.
	// Function: FPDFText_GetStrokeColor
	//          Get the stroke color of a particular character.
	// Parameters:
	//          text_page      -   Handle to a text page information structure.
	//                             Returned by FPDFText_LoadPage function.
	//          index          -   Zero-based index of the character.
	//          R              -   Pointer to an unsigned int number receiving the
	//                             red value of the stroke color.
	//          G              -   Pointer to an unsigned int number receiving the
	//                             green value of the stroke color.
	//          B              -   Pointer to an unsigned int number receiving the
	//                             blue value of the stroke color.
	//          A              -   Pointer to an unsigned int number receiving the
	//                             alpha value of the stroke color.
	// Return value:
	//          Whether the call succeeded. If false, |R|, |G|, |B| and |A| are
	//          unchanged.
	//
	@(link_name = "FPDFText_GetStrokeColor")
	text_get_stroke_color :: proc(text_page: ^TEXTPAGE, index: c.int, R: ^c.uint, G: ^c.uint, B: ^c.uint, A: ^c.uint) -> BOOL ---

	// Experimental API.
	// Function: FPDFText_GetCharAngle
	//          Get character rotation angle.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	//          index       -   Zero-based index of the character.
	// Return Value:
	//          On success, return the angle value in radian. Value will always be
	//          greater or equal to 0. If |text_page| is invalid, or if |index| is
	//          out of bounds, then return -1.
	//
	@(link_name = "FPDFText_GetCharAngle")
	text_get_char_angle :: proc(text_page: ^TEXTPAGE, index: c.int) -> c.float ---

	// Function: FPDFText_GetCharBox
	//          Get bounding box of a particular character.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	//          index       -   Zero-based index of the character.
	//          left        -   Pointer to a double number receiving left position
	//                          of the character box.
	//          right       -   Pointer to a double number receiving right position
	//                          of the character box.
	//          bottom      -   Pointer to a double number receiving bottom position
	//                          of the character box.
	//          top         -   Pointer to a double number receiving top position of
	//                          the character box.
	// Return Value:
	//          On success, return TRUE and fill in |left|, |right|, |bottom|, and
	//          |top|. If |text_page| is invalid, or if |index| is out of bounds,
	//          then return FALSE, and the out parameters remain unmodified.
	// Comments:
	//          All positions are measured in PDF "user space".
	//
	@(link_name = "FPDFText_GetCharBox")
	text_get_char_box :: proc(text_page: ^TEXTPAGE, index: c.int, left: ^c.double, right: ^c.double, bottom: ^c.double, top: ^c.double) -> BOOL ---

	// Experimental API.
	// Function: FPDFText_GetLooseCharBox
	//          Get a "loose" bounding box of a particular character, i.e., covering
	//          the entire glyph bounds, without taking the actual glyph shape into
	//          account.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	//          index       -   Zero-based index of the character.
	//          rect        -   Pointer to a FS_RECTF receiving the character box.
	// Return Value:
	//          On success, return TRUE and fill in |rect|. If |text_page| is
	//          invalid, or if |index| is out of bounds, then return FALSE, and the
	//          |rect| out parameter remains unmodified.
	// Comments:
	//          All positions are measured in PDF "user space".
	//
	@(link_name = "FPDFText_GetLooseCharBox")
	text_get_loose_char_box :: proc(text_page: ^TEXTPAGE, index: c.int, rect: ^RECTF) -> BOOL ---

	// Experimental API.
	// Function: FPDFText_GetMatrix
	//          Get the effective transformation matrix for a particular character.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage().
	//          index       -   Zero-based index of the character.
	//          matrix      -   Pointer to a FS_MATRIX receiving the transformation
	//                          matrix.
	// Return Value:
	//          On success, return TRUE and fill in |matrix|. If |text_page| is
	//          invalid, or if |index| is out of bounds, or if |matrix| is NULL,
	//          then return FALSE, and |matrix| remains unmodified.
	//
	@(link_name = "FPDFText_GetMatrix")
	text_get_matrix :: proc(text_page: ^TEXTPAGE, index: c.int, mat: ^MATRIX) -> BOOL ---

	// Function: FPDFText_GetCharOrigin
	//          Get origin of a particular character.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	//          index       -   Zero-based index of the character.
	//          x           -   Pointer to a double number receiving x coordinate of
	//                          the character origin.
	//          y           -   Pointer to a double number receiving y coordinate of
	//                          the character origin.
	// Return Value:
	//          Whether the call succeeded. If false, x and y are unchanged.
	// Comments:
	//          All positions are measured in PDF "user space".
	//
	@(link_name = "FPDFText_GetCharOrigin")
	text_get_char_origin :: proc(text_page: ^TEXTPAGE, index: c.int, x: ^c.double, y: ^c.double) -> BOOL ---

	// Function: FPDFText_GetCharIndexAtPos
	//          Get the index of a character at or nearby a certain position on the
	//          page.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	//          x           -   X position in PDF "user space".
	//          y           -   Y position in PDF "user space".
	//          xTolerance  -   An x-axis tolerance value for character hit
	//                          detection, in point units.
	//          yTolerance  -   A y-axis tolerance value for character hit
	//                          detection, in point units.
	// Return Value:
	//          The zero-based index of the character at, or nearby the point (x,y).
	//          If there is no character at or nearby the point, return value will
	//          be -1. If an error occurs, -3 will be returned.
	//
	@(link_name = "FPDFText_GetCharIndexAtPos")
	text_get_char_index_at_pos :: proc(text_page: ^TEXTPAGE, x: c.double, y: c.double, xTolerance: c.double, yTolerance: c.double) -> c.int ---

	// Function: FPDFText_GetText
	//          Extract unicode text string from the page.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	//          start_index -   Index for the start characters.
	//          count       -   Number of characters to be extracted.
	//          result      -   A buffer (allocated by application) receiving the
	//                          extracted unicodes. The size of the buffer must be
	//                          able to hold the number of characters plus a
	//                          terminator.
	// Return Value:
	//          Number of characters written into the result buffer, including the
	//          trailing terminator.
	// Comments:
	//          This function ignores characters without unicode information.
	//          It returns all characters on the page, even those that are not
	//          visible when the page has a cropbox. To filter out the characters
	//          outside of the cropbox, use FPDF_GetPageBoundingBox() and
	//          FPDFText_GetCharBox().
	//
	@(link_name = "FPDFText_GetText")
	text_get_text :: proc(text_page: ^TEXTPAGE, start_index: c.int, count: c.int, result: ^c.ushort) -> c.int ---

	// Function: FPDFText_CountRects
	//          Counts number of rectangular areas occupied by a segment of text,
	//          and caches the result for subsequent FPDFText_GetRect() calls.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	//          start_index -   Index for the start character.
	//          count       -   Number of characters, or -1 for all remaining.
	// Return value:
	//          Number of rectangles, 0 if text_page is null, or -1 on bad
	//          start_index.
	// Comments:
	//          This function, along with FPDFText_GetRect can be used by
	//          applications to detect the position on the page for a text segment,
	//          so proper areas can be highlighted. The FPDFText_* functions will
	//          automatically merge small character boxes into bigger one if those
	//          characters are on the same line and use same font settings.
	//
	@(link_name = "FPDFText_CountRects")
	text_count_rects :: proc(text_page: ^TEXTPAGE, start_index: c.int, count: c.int) -> c.int ---

	// Function: FPDFText_GetRect
	//          Get a rectangular area from the result generated by
	//          FPDFText_CountRects.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	//          rect_index  -   Zero-based index for the rectangle.
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
	//          |bottom|. If |text_page| is invalid then return FALSE, and the out
	//          parameters remain unmodified. If |text_page| is valid but
	//          |rect_index| is out of bounds, then return FALSE and set the out
	//          parameters to 0.
	//
	@(link_name = "FPDFText_GetRect")
	text_get_rect :: proc(text_page: ^TEXTPAGE, rect_index: c.int, left: ^c.double, top: ^c.double, right: ^c.double, bottom: ^c.double) -> BOOL ---

	// Function: FPDFText_GetBoundedText
	//          Extract unicode text within a rectangular boundary on the page.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	//          left        -   Left boundary.
	//          top         -   Top boundary.
	//          right       -   Right boundary.
	//          bottom      -   Bottom boundary.
	//          buffer      -   A unicode buffer.
	//          buflen      -   Number of characters (not bytes) for the buffer,
	//                          excluding an additional terminator.
	// Return Value:
	//          If buffer is NULL or buflen is zero, return number of characters
	//          (not bytes) of text present within the rectangle, excluding a
	//          terminating NUL. Generally you should pass a buffer at least one
	//          larger than this if you want a terminating NUL, which will be
	//          provided if space is available. Otherwise, return number of
	//          characters copied into the buffer, including the terminating NUL
	//          when space for it is available.
	// Comment:
	//          If the buffer is too small, as much text as will fit is copied into
	//          it.
	//
	@(link_name = "FPDFText_GetBoundedText")
	text_get_bounded_text :: proc(text_page: ^TEXTPAGE, left: c.double, top: c.double, right: c.double, bottom: c.double, buffer: ^c.ushort, buflen: c.int) -> c.int ---

	// Function: FPDFText_FindStart
	//          Start a search.
	// Parameters:
	//          text_page   -   Handle to a text page information structure.
	//                          Returned by FPDFText_LoadPage function.
	//          findwhat    -   A unicode match pattern.
	//          flags       -   Option flags.
	//          start_index -   Start from this character. -1 for end of the page.
	// Return Value:
	//          A handle for the search context. FPDFText_FindClose must be called
	//          to release this handle.
	//
	@(link_name = "FPDFText_FindStart")
	text_find_start :: proc(text_page: ^TEXTPAGE, findwhat: WIDESTRING, flags: c.ulong, start_index: c.int) -> SCHANDLE ---

	// Function: FPDFText_FindNext
	//          Search in the direction from page start to end.
	// Parameters:
	//          handle      -   A search context handle returned by
	//                          FPDFText_FindStart.
	// Return Value:
	//          Whether a match is found.
	//
	@(link_name = "FPDFText_FindNext")
	text_find_next :: proc(handle: SCHANDLE) -> BOOL ---

	// Function: FPDFText_FindPrev
	//          Search in the direction from page end to start.
	// Parameters:
	//          handle      -   A search context handle returned by
	//                          FPDFText_FindStart.
	// Return Value:
	//          Whether a match is found.
	//
	@(link_name = "FPDFText_FindPrev")
	text_find_prev :: proc(handle: SCHANDLE) -> BOOL ---

	// Function: FPDFText_GetSchResultIndex
	//          Get the starting character index of the search result.
	// Parameters:
	//          handle      -   A search context handle returned by
	//                          FPDFText_FindStart.
	// Return Value:
	//          Index for the starting character.
	//
	@(link_name = "FPDFText_GetSchResultIndex")
	text_get_sch_result_index :: proc(handle: SCHANDLE) -> c.int ---

	// Function: FPDFText_GetSchCount
	//          Get the number of matched characters in the search result.
	// Parameters:
	//          handle      -   A search context handle returned by
	//                          FPDFText_FindStart.
	// Return Value:
	//          Number of matched characters.
	//
	@(link_name = "FPDFText_GetSchCount")
	text_get_sch_count :: proc(handle: SCHANDLE) -> c.int ---

	// Function: FPDFText_FindClose
	//          Release a search context.
	// Parameters:
	//          handle      -   A search context handle returned by
	//                          FPDFText_FindStart.
	// Return Value:
	//          None.
	//
	@(link_name = "FPDFText_FindClose")
	text_find_close :: proc(handle: SCHANDLE) ---
}

@(default_calling_convention = "c")
foreign lib {
	// Get the font size of a text object.
	//
	//   text - handle to a text.
	//   size - pointer to the font size of the text object, measured in points
	//   (about 1/72 inch)
	//
	// Returns TRUE on success.
	@(link_name = "FPDFTextObj_GetFontSize")
	textobj_get_font_size :: proc(text: ^PAGEOBJECT, size: ^c.float) -> BOOL ---

	// Get the text rendering mode of a text object.
	//
	// text     - the handle to the text object.
	//
	// Returns one of the known FPDF_TEXT_RENDERMODE enum values on success,
	// FPDF_TEXTRENDERMODE_UNKNOWN on error.
	@(link_name = "FPDFTextObj_GetTextRenderMode")
	textobj_get_text_render_mode :: proc(text: ^PAGEOBJECT) -> TEXT_RENDERMODE ---

	// Experimental API.
	// Set the text rendering mode of a text object.
	//
	// text         - the handle to the text object.
	// render_mode  - the FPDF_TEXT_RENDERMODE enum value to be set (cannot set to
	//                FPDF_TEXTRENDERMODE_UNKNOWN).
	//
	// Returns TRUE on success.
	@(link_name = "FPDFTextObj_SetTextRenderMode")
	textobj_set_text_render_mode :: proc(text: ^PAGEOBJECT, render_mode: TEXT_RENDERMODE) -> BOOL ---

	// Get the text of a text object.
	//
	// text_object      - the handle to the text object.
	// text_page        - the handle to the text page.
	// buffer           - the address of a buffer that receives the text.
	// length           - the size, in bytes, of |buffer|.
	//
	// Returns the number of bytes in the text (including the trailing NUL
	// character) on success, 0 on error.
	//
	// Regardless of the platform, the |buffer| is always in UTF-16LE encoding.
	// If |length| is less than the returned length, or |buffer| is NULL, |buffer|
	// will not be modified.
	@(link_name = "FPDFTextObj_GetText")
	textobj_get_text :: proc(text_object: ^PAGEOBJECT, text_page: ^TEXTPAGE, buffer: ^WCHAR, length: c.ulong) -> c.ulong ---

	// Experimental API.
	// Get a bitmap rasterization of |text_object|. To render correctly, the caller
	// must provide the |document| associated with |text_object|. If there is a
	// |page| associated with |text_object|, the caller should provide that as well.
	// The returned bitmap will be owned by the caller, and FPDFBitmap_Destroy()
	// must be called on the returned bitmap when it is no longer needed.
	//
	//   document    - handle to a document associated with |text_object|.
	//   page        - handle to an optional page associated with |text_object|.
	//   text_object - handle to a text object.
	//   scale       - the scaling factor, which must be greater than 0.
	//
	// Returns the bitmap or NULL on failure.
	@(link_name = "FPDFTextObj_GetRenderedBitmap")
	textobj_get_rendered_bitmap :: proc(document: ^DOCUMENT, page: ^PAGE, text_object: ^PAGEOBJECT, scale: c.float) -> ^BITMAP ---

	// Experimental API.
	// Get the font of a text object.
	//
	// text - the handle to the text object.
	//
	// Returns a handle to the font object held by |text| which retains ownership.
	@(link_name = "FPDFTextObj_GetFont")
	textobj_get_font :: proc(text: ^PAGEOBJECT) -> ^FONT ---
}

@(default_calling_convention = "c")
foreign lib {
	// Close a loaded PDF font.
	//
	// font   - Handle to the loaded font.
	@(link_name = "FPDFFont_Close")
	font_close :: proc(font: ^FONT) ---

	// Experimental API.
	// Get the font name of a font.
	//
	// font   - the handle to the font object.
	// buffer - the address of a buffer that receives the font name.
	// length - the size, in bytes, of |buffer|.
	//
	// Returns the number of bytes in the font name (including the trailing NUL
	// character) on success, 0 on error.
	//
	// Regardless of the platform, the |buffer| is always in UTF-8 encoding.
	// If |length| is less than the returned length, or |buffer| is NULL, |buffer|
	// will not be modified.
	@(link_name = "FPDFFont_GetFontName")
	font_get_font_name :: proc(font: ^FONT, buffer: [^]byte, length: c.ulong) -> c.ulong ---

	// Experimental API.
	// Get the decoded data from the |font| object.
	//
	// font       - The handle to the font object. (Required)
	// buffer     - The address of a buffer that receives the font data.
	// buflen     - Length of the buffer.
	// out_buflen - Pointer to variable that will receive the minimum buffer size
	//              to contain the font data. Not filled if the return value is
	//              FALSE. (Required)
	//
	// Returns TRUE on success. In which case, |out_buflen| will be filled, and
	// |buffer| will be filled if it is large enough. Returns FALSE if any of the
	// required parameters are null.
	//
	// The decoded data is the uncompressed font data. i.e. the raw font data after
	// having all stream filters applied, when the data is embedded.
	//
	// If the font is not embedded, then this API will instead return the data for
	// the substitution font it is using.
	@(link_name = "FPDFFont_GetFontData")
	font_get_font_data :: proc(font: ^FONT, buffer: ^c.uint8_t, buflen: c.size_t, out_buflen: ^c.size_t) -> BOOL ---

	// Experimental API.
	// Get whether |font| is embedded or not.
	//
	// font - the handle to the font object.
	//
	// Returns 1 if the font is embedded, 0 if it not, and -1 on failure.
	@(link_name = "FPDFFont_GetIsEmbedded")
	font_get_is_embedded :: proc(font: ^FONT) -> c.int ---

	// Experimental API.
	// Get the descriptor flags of a font.
	//
	// font - the handle to the font object.
	//
	// Returns the bit flags specifying various characteristics of the font as
	// defined in ISO 32000-1:2008, table 123, -1 on failure.
	@(link_name = "FPDFFont_GetFlags")
	font_get_flags :: proc(font: ^FONT) -> c.int ---

	// Experimental API.
	// Get the font weight of a font.
	//
	// font - the handle to the font object.
	//
	// Returns the font weight, -1 on failure.
	// Typical values are 400 (normal) and 700 (bold).
	@(link_name = "FPDFFont_GetWeight")
	font_get_weight :: proc(font: ^FONT) -> c.int ---

	// Experimental API.
	// Get the italic angle of a font.
	//
	// font  - the handle to the font object.
	// angle - pointer where the italic angle will be stored
	//
	// The italic angle of a |font| is defined as degrees counterclockwise
	// from vertical. For a font that slopes to the right, this will be negative.
	//
	// Returns TRUE on success; |angle| unmodified on failure.
	@(link_name = "FPDFFont_GetItalicAngle")
	font_get_italic_angle :: proc(font: ^FONT, angle: ^c.int) -> BOOL ---

	// Experimental API.
	// Get ascent distance of a font.
	//
	// font       - the handle to the font object.
	// font_size  - the size of the |font|.
	// ascent     - pointer where the font ascent will be stored
	//
	// Ascent is the maximum distance in points above the baseline reached by the
	// glyphs of the |font|. One point is 1/72 inch (around 0.3528 mm).
	//
	// Returns TRUE on success; |ascent| unmodified on failure.
	@(link_name = "FPDFFont_GetAscent")
	font_get_ascent :: proc(font: ^FONT, font_size: c.float, ascent: ^c.float) -> BOOL ---

	// Experimental API.
	// Get descent distance of a font.
	//
	// font       - the handle to the font object.
	// font_size  - the size of the |font|.
	// descent    - pointer where the font descent will be stored
	//
	// Descent is the maximum distance in points below the baseline reached by the
	// glyphs of the |font|. One point is 1/72 inch (around 0.3528 mm).
	//
	// Returns TRUE on success; |descent| unmodified on failure.
	@(link_name = "FPDFFont_GetDescent")
	font_get_descent :: proc(font: ^FONT, font_size: c.float, descent: ^c.float) -> BOOL ---

	// Experimental API.
	// Get the width of a glyph in a font.
	//
	// font       - the handle to the font object.
	// glyph      - the glyph.
	// font_size  - the size of the font.
	// width      - pointer where the glyph width will be stored
	//
	// Glyph width is the distance from the end of the prior glyph to the next
	// glyph. This will be the vertical distance for vertical writing.
	//
	// Returns TRUE on success; |width| unmodified on failure.
	@(link_name = "FPDFFont_GetGlyphWidth")
	font_get_glyp_width :: proc(font: ^FONT, glyph: c.uint32_t, font_size: c.float, width: ^c.float) -> BOOL ---

	// Experimental API.
	// Get the glyphpath describing how to draw a font glyph.
	//
	// font       - the handle to the font object.
	// glyph      - the glyph being drawn.
	// font_size  - the size of the font.
	//
	// Returns the handle to the segment, or NULL on faiure.
	@(link_name = "FPDFFont_GetGlyphPath")
	font_get_glyph_path :: proc(font: ^FONT, glyph: c.uint32_t, font_size: c.float) -> ^GLYPHPATH ---
}

@(default_calling_convention = "c")
foreign lib {
	// Experimental API.
	// Get number of segments inside glyphpath.
	//
	// glyphpath - handle to a glyph path.
	//
	// Returns the number of objects in |glyphpath| or -1 on failure.
	@(link_name = "FPDFGlyphPath_CountGlyphSegments")
	glyphpath_count_glyph_segments :: proc(glyphpath: ^GLYPHPATH) -> c.int ---

	// Experimental API.
	// Get segment in glyphpath at index.
	//
	// glyphpath  - handle to a glyph path.
	// index      - the index of a segment.
	//
	// Returns the handle to the segment, or NULL on faiure.
	@(link_name = "FPDFGlyphPath_GetGlyphPathSegment")
	glyphpath_get_glyph_path_segment :: proc(glyphpath: ^GLYPHPATH, index: c.int) -> ^PATHSEGMENT ---
}

@(default_calling_convention = "c")
foreign lib {
	// Get number of page objects inside |form_object|.
	//
	//   form_object - handle to a form object.
	//
	// Returns the number of objects in |form_object| on success, -1 on error.
	@(link_name = "FPDFFormObj_CountObjects")
	formobj_count_objects :: proc(form_object: ^PAGEOBJECT) -> c.int ---

	// Get page object in |form_object| at |index|.
	//
	//   form_object - handle to a form object.
	//   index       - the 0-based index of a page object.
	//
	// Returns the handle to the page object, or NULL on error.
	@(link_name = "FPDFFormObj_GetObject")
	formobj_get_objects :: proc(form_object: ^PAGEOBJECT, index: c.ulong) -> ^PAGEOBJECT ---
}
