package pdfium

import "core:c"

when ODIN_OS == .Windows {
	foreign import lib "lib/pdfium.dll.lib"
} else {
	foreign import lib "system:pdfium"
}

ANNOT_UNKNOWN :: 0
ANNOT_TEXT :: 1
ANNOT_LINK :: 2
ANNOT_FREETEXT :: 3
ANNOT_LINE :: 4
ANNOT_SQUARE :: 5
ANNOT_CIRCLE :: 6
ANNOT_POLYGON :: 7
ANNOT_POLYLINE :: 8
ANNOT_HIGHLIGHT :: 9
ANNOT_UNDERLINE :: 10
ANNOT_SQUIGGLY :: 11
ANNOT_STRIKEOUT :: 12
ANNOT_STAMP :: 13
ANNOT_CARET :: 14
ANNOT_INK :: 15
ANNOT_POPUP :: 16
ANNOT_FILEATTACHMENT :: 17
ANNOT_SOUND :: 18
ANNOT_MOVIE :: 19
ANNOT_WIDGET :: 20
ANNOT_SCREEN :: 21
ANNOT_PRINTERMARK :: 22
ANNOT_TRAPNET :: 23
ANNOT_WATERMARK :: 24
ANNOT_THREED :: 25
ANNOT_RICHMEDIA :: 26
ANNOT_XFAWIDGET :: 27
ANNOT_REDACT :: 28

// Refer to PDF Reference (6th edition) table 8.16 for all annotation flags.
ANNOT_FLAG_NONE :: 0
ANNOT_FLAG_INVISIBLE :: (1 << 0)
ANNOT_FLAG_HIDDEN :: (1 << 1)
ANNOT_FLAG_PRINT :: (1 << 2)
ANNOT_FLAG_NOZOOM :: (1 << 3)
ANNOT_FLAG_NOROTATE :: (1 << 4)
ANNOT_FLAG_NOVIEW :: (1 << 5)
ANNOT_FLAG_READONLY :: (1 << 6)
ANNOT_FLAG_LOCKED :: (1 << 7)
ANNOT_FLAG_TOGGLENOVIEW :: (1 << 8)

ANNOT_APPEARANCEMODE_NORMAL :: 0
ANNOT_APPEARANCEMODE_ROLLOVER :: 1
ANNOT_APPEARANCEMODE_DOWN :: 2
ANNOT_APPEARANCEMODE_COUNT :: 3

// Refer to PDF Reference version 1.7 table 8.70 for field flags common to all
// interactive form field types.
FORMFLAG_NONE :: 0
FORMFLAG_READONLY :: (1 << 0)
FORMFLAG_REQUIRED :: (1 << 1)
FORMFLAG_NOEXPORT :: (1 << 2)

// Refer to PDF Reference version 1.7 table 8.77 for field flags specific to
// interactive form text fields.
FORMFLAG_TEXT_MULTILINE :: (1 << 12)
FORMFLAG_TEXT_PASSWORD :: (1 << 13)

// Refer to PDF Reference version 1.7 table 8.79 for field flags specific to
// interactive form choice fields.
FORMFLAG_CHOICE_COMBO :: (1 << 17)
FORMFLAG_CHOICE_EDIT :: (1 << 18)
FORMFLAG_CHOICE_MULTI_SELECT :: (1 << 21)

// Additional actions type of form field:
//   K, on key stroke, JavaScript action.
//   F, on format, JavaScript action.
//   V, on validate, JavaScript action.
//   C, on calculate, JavaScript action.
ANNOT_AACTION_KEY_STROKE :: 12
ANNOT_AACTION_FORMAT :: 13
ANNOT_AACTION_VALIDATE :: 14
ANNOT_AACTION_CALCULATE :: 15

FPDFANNOT_COLORTYPE :: enum {
	Color = 0,
	InteriorColor,
}

@(default_calling_convention = "c")
foreign lib {
	// Experimental API.
	// Check if an annotation subtype is currently supported for creation.
	// Currently supported subtypes:
	//    - circle
	//    - freetext
	//    - highlight
	//    - ink
	//    - link
	//    - popup
	//    - square,
	//    - squiggly
	//    - stamp
	//    - strikeout
	//    - text
	//    - underline
	//
	//   subtype   - the subtype to be checked.
	//
	// Returns true if this subtype supported.
	@(link_name = "FPDFAnnot_IsSupportedSubtype")
	annot_is_supprted_subtype :: proc(subtype: ANNOTATION_SUBTYPE) -> BOOL ---

	// Experimental API.
	// Get the subtype of an annotation.
	//
	//   annot  - handle to an annotation.
	//
	// Returns the annotation subtype.
	@(link_name = "FPDFAnnot_GetSubtype")
	annot_get_subtype :: proc(annot: ^ANNOTATION) -> ANNOTATION_SUBTYPE ---

	// Experimental API.
	// Check if an annotation subtype is currently supported for object extraction,
	// update, and removal.
	// Currently supported subtypes: ink and stamp.
	//
	//   subtype   - the subtype to be checked.
	//
	// Returns true if this subtype supported.
	@(link_name = "FPDFAnnot_IsObjectSupportedSubtype")
	annot_is_object_supprted_subtype :: proc(subtype: ANNOTATION_SUBTYPE) -> BOOL ---

	// Experimental API.
	// Update |obj| in |annot|. |obj| must be in |annot| already and must have
	// been retrieved by FPDFAnnot_GetObject(). Currently, only ink and stamp
	// annotations are supported by this API. Also note that only path, image, and
	// text objects have APIs for modification; see FPDFPath_*(), FPDFText_*(), and
	// FPDFImageObj_*().
	//
	//   annot  - handle to an annotation.
	//   obj    - handle to the object that |annot| needs to update.
	//
	// Return true if successful.
	@(link_name = "FPDFAnnot_UpdateObject")
	annot_update_object :: proc(annot: ^ANNOTATION, obj: ^PAGEOBJECT) -> BOOL ---

	// Experimental API.
	// Add a new InkStroke, represented by an array of points, to the InkList of
	// |annot|. The API creates an InkList if one doesn't already exist in |annot|.
	// This API works only for ink annotations. Please refer to ISO 32000-1:2008
	// spec, section 12.5.6.13.
	//
	//   annot       - handle to an annotation.
	//   points      - pointer to a FS_POINTF array representing input points.
	//   point_count - number of elements in |points| array. This should not exceed
	//                 the maximum value that can be represented by an int32_t).
	//
	// Returns the 0-based index at which the new InkStroke is added in the InkList
	// of the |annot|. Returns -1 on failure.
	@(link_name = "FPDFAnnot_AddInkStroke")
	annot_add_ink_stroke :: proc(annot: ^ANNOTATION, points: ^POINTF, point_count: c.size_t) -> c.int ---

	// Experimental API.
	// Removes an InkList in |annot|.
	// This API works only for ink annotations.
	//
	//   annot  - handle to an annotation.
	//
	// Return true on successful removal of /InkList entry from context of the
	// non-null ink |annot|. Returns false on failure.
	@(link_name = "FPDFAnnot_RemoveInkList")
	annot_remove_ink_list :: proc(annot: ^ANNOTATION) -> BOOL ---

	// Experimental API.
	// Add |obj| to |annot|. |obj| must have been created by
	// FPDFPageObj_CreateNew{Path|Rect}() or FPDFPageObj_New{Text|Image}Obj(), and
	// will be owned by |annot|. Note that an |obj| cannot belong to more than one
	// |annot|. Currently, only ink and stamp annotations are supported by this API.
	// Also note that only path, image, and text objects have APIs for creation.
	//
	//   annot  - handle to an annotation.
	//   obj    - handle to the object that is to be added to |annot|.
	//
	// Return true if successful.
	@(link_name = "FPDFAnnot_AppendObject")
	annot_append_object :: proc(annot: ^ANNOTATION, obj: ^PAGEOBJECT) -> BOOL ---

	// Experimental API.
	// Get the total number of objects in |annot|, including path objects, text
	// objects, external objects, image objects, and shading objects.
	//
	//   annot  - handle to an annotation.
	//
	// Returns the number of objects in |annot|.
	@(link_name = "FPDFAnnot_GetObjectCount")
	annot_get_object_count :: proc(annot: ^ANNOTATION) -> c.int ---

	// Experimental API.
	// Get the object in |annot| at |index|.
	//
	//   annot  - handle to an annotation.
	//   index  - the index of the object.
	//
	// Return a handle to the object, or NULL on failure.
	@(link_name = "FPDFAnnot_GetObject")
	annot_get_object :: proc(annot: ^ANNOTATION, index: c.int) -> ^PAGEOBJECT ---

	// Experimental API.
	// Remove the object in |annot| at |index|.
	//
	//   annot  - handle to an annotation.
	//   index  - the index of the object to be removed.
	//
	// Return true if successful.
	@(link_name = "FPDFAnnot_RemoveObject")
	annot_remove_object :: proc(annot: ^ANNOTATION, index: c.int) -> BOOL ---

	// Experimental API.
	// Set the color of an annotation. Fails when called on annotations with
	// appearance streams already defined; instead use
	// FPDFPath_Set{Stroke|Fill}Color().
	//
	//   annot    - handle to an annotation.
	//   type     - type of the color to be set.
	//   R, G, B  - buffer to hold the RGB value of the color. Ranges from 0 to 255.
	//   A        - buffer to hold the opacity. Ranges from 0 to 255.
	//
	// Returns true if successful.
	@(link_name = "FPDFAnnot_SetColor")
	annot_set_color :: proc(annot: ^ANNOTATION, color_type: FPDFANNOT_COLORTYPE, R: c.uint, G: c.uint, B: c.uint, A: c.uint) -> BOOL ---

	// Experimental API.
	// Get the color of an annotation. If no color is specified, default to yellow
	// for highlight annotation, black for all else. Fails when called on
	// annotations with appearance streams already defined; instead use
	// FPDFPath_Get{Stroke|Fill}Color().
	//
	//   annot    - handle to an annotation.
	//   type     - type of the color requested.
	//   R, G, B  - buffer to hold the RGB value of the color. Ranges from 0 to 255.
	//   A        - buffer to hold the opacity. Ranges from 0 to 255.
	//
	// Returns true if successful.
	@(link_name = "FPDFAnnot_GetColor")
	annot_get_color :: proc(annot: ^ANNOTATION, color_type: FPDFANNOT_COLORTYPE, R: ^c.uint, G: ^c.uint, B: ^c.uint, A: ^c.uint) -> BOOL ---

	// Experimental API.
	// Check if the annotation is of a type that has attachment points
	// (i.e. quadpoints). Quadpoints are the vertices of the rectangle that
	// encompasses the texts affected by the annotation. They provide the
	// coordinates in the page where the annotation is attached. Only text markup
	// annotations (i.e. highlight, strikeout, squiggly, and underline) and link
	// annotations have quadpoints.
	//
	//   annot  - handle to an annotation.
	//
	// Returns true if the annotation is of a type that has quadpoints, false
	// otherwise.
	@(link_name = "FPDFAnnot_HasAttachmentPoints")
	annot_has_attachment_points :: proc(annot: ^ANNOTATION) -> BOOL ---

	// Experimental API.
	// Replace the attachment points (i.e. quadpoints) set of an annotation at
	// |quad_index|. This index needs to be within the result of
	// FPDFAnnot_CountAttachmentPoints().
	// If the annotation's appearance stream is defined and this annotation is of a
	// type with quadpoints, then update the bounding box too if the new quadpoints
	// define a bigger one.
	//
	//   annot       - handle to an annotation.
	//   quad_index  - index of the set of quadpoints.
	//   quad_points - the quadpoints to be set.
	//
	// Returns true if successful.
	@(link_name = "FPDFAnnot_SetAttachmentPoints")
	annot_set_attachment_points :: proc(annot: ^ANNOTATION, quad_index: c.size_t, quad_points: ^QUADPOINTSF) -> BOOL ---

	// Experimental API.
	// Append to the list of attachment points (i.e. quadpoints) of an annotation.
	// If the annotation's appearance stream is defined and this annotation is of a
	// type with quadpoints, then update the bounding box too if the new quadpoints
	// define a bigger one.
	//
	//   annot       - handle to an annotation.
	//   quad_points - the quadpoints to be set.
	//
	// Returns true if successful.
	@(link_name = "FPDFAnnot_AppendAttachmentPoints")
	annot_append_attachment_points :: proc(annot: ^ANNOTATION, quad_points: ^QUADPOINTSF) -> BOOL ---

	// Experimental API.
	// Get the number of sets of quadpoints of an annotation.
	//
	//   annot  - handle to an annotation.
	//
	// Returns the number of sets of quadpoints, or 0 on failure.
	@(link_name = "FPDFAnnot_CountAttachmentPoints")
	annot_count_attachment_points :: proc(annot: ^ANNOTATION) -> c.size_t ---

	// Experimental API.
	// Get the attachment points (i.e. quadpoints) of an annotation.
	//
	//   annot       - handle to an annotation.
	//   quad_index  - index of the set of quadpoints.
	//   quad_points - receives the quadpoints; must not be NULL.
	//
	// Returns true if successful.
	@(link_name = "FPDFAnnot_GetAttachmentPoints")
	annot_get_attachment_points :: proc(annot: ^ANNOTATION, quad_index: c.size_t, quad_points: ^QUADPOINTSF) -> BOOL ---

	// Experimental API.
	// Set the annotation rectangle defining the location of the annotation. If the
	// annotation's appearance stream is defined and this annotation is of a type
	// without quadpoints, then update the bounding box too if the new rectangle
	// defines a bigger one.
	//
	//   annot  - handle to an annotation.
	//   rect   - the annotation rectangle to be set.
	//
	// Returns true if successful.
	@(link_name = "FPDFAnnot_SetRect")
	annot_set_rect :: proc(annot: ^ANNOTATION, rect: ^RECTF) -> BOOL ---

	// Experimental API.
	// Get the annotation rectangle defining the location of the annotation.
	//
	//   annot  - handle to an annotation.
	//   rect   - receives the rectangle; must not be NULL.
	//
	// Returns true if successful.
	@(link_name = "FPDFAnnot_GetRect")
	annot_get_rect :: proc(annot: ^ANNOTATION, rect: ^RECTF) -> BOOL ---

	// Experimental API.
	// Get the vertices of a polygon or polyline annotation. |buffer| is an array of
	// points of the annotation. If |length| is less than the returned length, or
	// |annot| or |buffer| is NULL, |buffer| will not be modified.
	//
	//   annot  - handle to an annotation, as returned by e.g. FPDFPage_GetAnnot()
	//   buffer - buffer for holding the points.
	//   length - length of the buffer in points.
	//
	// Returns the number of points if the annotation is of type polygon or
	// polyline, 0 otherwise.
	@(link_name = "FPDFAnnot_GetVertices")
	annot_get_vertices :: proc(annot: ^ANNOTATION, buffer: ^POINTF, length: c.ulong) -> c.ulong ---

	// Experimental API.
	// Get the number of paths in the ink list of an ink annotation.
	//
	//   annot  - handle to an annotation, as returned by e.g. FPDFPage_GetAnnot()
	//
	// Returns the number of paths in the ink list if the annotation is of type ink,
	// 0 otherwise.
	@(link_name = "FPDFAnnot_GetInkListCount")
	annot_get_ink_list_count :: proc(annot: ^ANNOTATION) -> c.ulong ---

	// Experimental API.
	// Get a path in the ink list of an ink annotation. |buffer| is an array of
	// points of the path. If |length| is less than the returned length, or |annot|
	// or |buffer| is NULL, |buffer| will not be modified.
	//
	//   annot  - handle to an annotation, as returned by e.g. FPDFPage_GetAnnot()
	//   path_index - index of the path
	//   buffer - buffer for holding the points.
	//   length - length of the buffer in points.
	//
	// Returns the number of points of the path if the annotation is of type ink, 0
	// otherwise.
	@(link_name = "FPDFAnnot_GetInkListPath")
	annot_get_ink_list_path :: proc(annot: ^ANNOTATION, path_index: c.ulong, buffer: ^POINTF, length: c.ulong) -> c.ulong ---

	// Experimental API.
	// Get the starting and ending coordinates of a line annotation.
	//
	//   annot  - handle to an annotation, as returned by e.g. FPDFPage_GetAnnot()
	//   start - starting point
	//   end - ending point
	//
	// Returns true if the annotation is of type line, |start| and |end| are not
	// NULL, false otherwise.
	@(link_name = "FPDFAnnot_GetLine")
	annot_get_line :: proc(annot: ^ANNOTATION, start: ^POINTF, end: ^POINTF) -> BOOL ---

	// Experimental API.
	// Set the characteristics of the annotation's border (rounded rectangle).
	//
	//   annot              - handle to an annotation
	//   horizontal_radius  - horizontal corner radius, in default user space units
	//   vertical_radius    - vertical corner radius, in default user space units
	//   border_width       - border width, in default user space units
	//
	// Returns true if setting the border for |annot| succeeds, false otherwise.
	//
	// If |annot| contains an appearance stream that overrides the border values,
	// then the appearance stream will be removed on success.
	@(link_name = "FPDFAnnot_SetBorder")
	annot_set_border :: proc(annot: ^ANNOTATION, horizontal_radius: c.float, vertical_radius: c.float, border_width: c.float) -> BOOL ---

	// Experimental API.
	// Get the characteristics of the annotation's border (rounded rectangle).
	//
	//   annot              - handle to an annotation
	//   horizontal_radius  - horizontal corner radius, in default user space units
	//   vertical_radius    - vertical corner radius, in default user space units
	//   border_width       - border width, in default user space units
	//
	// Returns true if |horizontal_radius|, |vertical_radius| and |border_width| are
	// not NULL, false otherwise.
	@(link_name = "FPDFAnnot_GetBorder")
	annot_get_border :: proc(annot: ^ANNOTATION, horizontal_radius: ^c.float, vertical_radius: ^c.float, border_width: ^c.float) -> BOOL ---

	// Experimental API.
	// Get the JavaScript of an event of the annotation's additional actions.
	// |buffer| is only modified if |buflen| is large enough to hold the whole
	// JavaScript string. If |buflen| is smaller, the total size of the JavaScript
	// is still returned, but nothing is copied.  If there is no JavaScript for
	// |event| in |annot|, an empty string is written to |buf| and 2 is returned,
	// denoting the size of the null terminator in the buffer.  On other errors,
	// nothing is written to |buffer| and 0 is returned.
	//
	//    hHandle     -   handle to the form fill module, returned by
	//                    FPDFDOC_InitFormFillEnvironment().
	//    annot       -   handle to an interactive form annotation.
	//    event       -   event type, one of the FPDF_ANNOT_AACTION_* values.
	//    buffer      -   buffer for holding the value string, encoded in UTF-16LE.
	//    buflen      -   length of the buffer in bytes.
	//
	// Returns the length of the string value in bytes, including the 2-byte
	// null terminator.
	@(link_name = "FPDFAnnot_GetFormAdditionalActionJavaScript")
	annot_get_form_additional_action_javascript :: proc(hHandle: ^FORMHANDLE, annot: ^ANNOTATION, event: c.int, buffer: ^WCHAR, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Check if |annot|'s dictionary has |key| as a key.
	//
	//   annot  - handle to an annotation.
	//   key    - the key to look for, encoded in UTF-8.
	//
	// Returns true if |key| exists.
	@(link_name = "FPDFAnnot_HasKey")
	annot_has_key :: proc(annot: ^ANNOTATION, key: BYTESTRING) -> BOOL ---

	// Experimental API.
	// Get the type of the value corresponding to |key| in |annot|'s dictionary.
	//
	//   annot  - handle to an annotation.
	//   key    - the key to look for, encoded in UTF-8.
	//
	// Returns the type of the dictionary value.
	@(link_name = "FPDFAnnot_GetValueType")
	annot_get_value_type :: proc(annot: ^ANNOTATION, key: BYTESTRING) -> OBJECT_TYPE ---

	// Experimental API.
	// Set the string value corresponding to |key| in |annot|'s dictionary,
	// overwriting the existing value if any. The value type would be
	// FPDF_OBJECT_STRING after this function call succeeds.
	//
	//   annot  - handle to an annotation.
	//   key    - the key to the dictionary entry to be set, encoded in UTF-8.
	//   value  - the string value to be set, encoded in UTF-16LE.
	//
	// Returns true if successful.
	@(link_name = "FPDFAnnot_SetStringValue")
	annot_set_string_value :: proc(annot: ^ANNOTATION, key: BYTESTRING, value: WIDESTRING) -> BOOL ---

	// Experimental API.
	// Get the string value corresponding to |key| in |annot|'s dictionary. |buffer|
	// is only modified if |buflen| is longer than the length of contents. Note that
	// if |key| does not exist in the dictionary or if |key|'s corresponding value
	// in the dictionary is not a string (i.e. the value is not of type
	// FPDF_OBJECT_STRING or FPDF_OBJECT_NAME), then an empty string would be copied
	// to |buffer| and the return value would be 2. On other errors, nothing would
	// be added to |buffer| and the return value would be 0.
	//
	//   annot  - handle to an annotation.
	//   key    - the key to the requested dictionary entry, encoded in UTF-8.
	//   buffer - buffer for holding the value string, encoded in UTF-16LE.
	//   buflen - length of the buffer in bytes.
	//
	// Returns the length of the string value in bytes.
	@(link_name = "FPDFAnnot_GetStringValue")
	annot_get_string_value :: proc(annot: ^ANNOTATION, key: BYTESTRING, buffer: ^WCHAR, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Get the float value corresponding to |key| in |annot|'s dictionary. Writes
	// value to |value| and returns True if |key| exists in the dictionary and
	// |key|'s corresponding value is a number (FPDF_OBJECT_NUMBER), False
	// otherwise.
	//
	//   annot  - handle to an annotation.
	//   key    - the key to the requested dictionary entry, encoded in UTF-8.
	//   value  - receives the value, must not be NULL.
	//
	// Returns True if value found, False otherwise.
	@(link_name = "FPDFAnnot_GetNumberValue")
	annot_get_number_value :: proc(annot: ^ANNOTATION, key: BYTESTRING, value: ^c.float) -> BOOL ---

	// Experimental API.
	// Set the AP (appearance string) in |annot|'s dictionary for a given
	// |appearanceMode|.
	//
	//   annot          - handle to an annotation.
	//   appearanceMode - the appearance mode (normal, rollover or down) for which
	//                    to get the AP.
	//   value          - the string value to be set, encoded in UTF-16LE. If
	//                    nullptr is passed, the AP is cleared for that mode. If the
	//                    mode is Normal, APs for all modes are cleared.
	//
	// Returns true if successful.
	@(link_name = "FPDFAnnot_SetAP")
	annot_set_ap :: proc(annot: ^ANNOTATION, appearanceMode: ANNOT_APPEARANCEMODE, value: WIDESTRING) -> BOOL ---

	// Experimental API.
	// Get the AP (appearance string) from |annot|'s dictionary for a given
	// |appearanceMode|.
	// |buffer| is only modified if |buflen| is large enough to hold the whole AP
	// string. If |buflen| is smaller, the total size of the AP is still returned,
	// but nothing is copied.
	// If there is no appearance stream for |annot| in |appearanceMode|, an empty
	// string is written to |buf| and 2 is returned.
	// On other errors, nothing is written to |buffer| and 0 is returned.
	//
	//   annot          - handle to an annotation.
	//   appearanceMode - the appearance mode (normal, rollover or down) for which
	//                    to get the AP.
	//   buffer         - buffer for holding the value string, encoded in UTF-16LE.
	//   buflen         - length of the buffer in bytes.
	//
	// Returns the length of the string value in bytes.
	@(link_name = "FPDFAnnot_GetAP")
	annot_get_ap :: proc(annot: ^ANNOTATION, appearanceMode: ANNOT_APPEARANCEMODE, buffer: ^WCHAR, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Get the annotation corresponding to |key| in |annot|'s dictionary. Common
	// keys for linking annotations include "IRT" and "Popup". Must call
	// FPDFPage_CloseAnnot() when the annotation returned by this function is no
	// longer needed.
	//
	//   annot  - handle to an annotation.
	//   key    - the key to the requested dictionary entry, encoded in UTF-8.
	//
	// Returns a handle to the linked annotation object, or NULL on failure.
	@(link_name = "FPDFAnnot_GetLinkedAnnot")
	annot_get_linked_annot :: proc(annot: ^ANNOTATION, key: BYTESTRING) -> ^ANNOTATION ---

	// Experimental API.
	// Get the annotation flags of |annot|.
	//
	//   annot    - handle to an annotation.
	//
	// Returns the annotation flags.
	@(link_name = "FPDFAnnot_GetFlags")
	annot_get_flags :: proc(annot: ^ANNOTATION) -> c.int ---

	// Experimental API.
	// Set the |annot|'s flags to be of the value |flags|.
	//
	//   annot      - handle to an annotation.
	//   flags      - the flag values to be set.
	//
	// Returns true if successful.
	@(link_name = "FPDFAnnot_SetFlags")
	annot_set_flags :: proc(annot: ^ANNOTATION, flags: c.int) -> BOOL ---

	// Experimental API.
	// Get the annotation flags of |annot|.
	//
	//    hHandle     -   handle to the form fill module, returned by
	//                    FPDFDOC_InitFormFillEnvironment().
	//    annot       -   handle to an interactive form annotation.
	//
	// Returns the annotation flags specific to interactive forms.
	@(link_name = "FPDFAnnot_GetFormFieldFlags")
	annot_get_form_field_flags :: proc(handle: ^FORMHANDLE, annot: ^ANNOTATION) -> c.int ---

	// Experimental API.
	// Retrieves an interactive form annotation whose rectangle contains a given
	// point on a page. Must call FPDFPage_CloseAnnot() when the annotation returned
	// is no longer needed.
	//
	//
	//    hHandle     -   handle to the form fill module, returned by
	//                    FPDFDOC_InitFormFillEnvironment().
	//    page        -   handle to the page, returned by FPDF_LoadPage function.
	//    point       -   position in PDF "user space".
	//
	// Returns the interactive form annotation whose rectangle contains the given
	// coordinates on the page. If there is no such annotation, return NULL.
	@(link_name = "FPDFAnnot_GetFormFieldAtPoint")
	annot_get_form_field_at_point :: proc(hHandle: ^FORMHANDLE, page: ^PAGE, point: ^POINTF) -> ^ANNOTATION ---

	// Experimental API.
	// Gets the name of |annot|, which is an interactive form annotation.
	// |buffer| is only modified if |buflen| is longer than the length of contents.
	// In case of error, nothing will be added to |buffer| and the return value will
	// be 0. Note that return value of empty string is 2 for "\0\0".
	//
	//    hHandle     -   handle to the form fill module, returned by
	//                    FPDFDOC_InitFormFillEnvironment().
	//    annot       -   handle to an interactive form annotation.
	//    buffer      -   buffer for holding the name string, encoded in UTF-16LE.
	//    buflen      -   length of the buffer in bytes.
	//
	// Returns the length of the string value in bytes.
	@(link_name = "FPDFAnnot_GetFormFieldName")
	annot_get_form_field_name :: proc(hHandle: ^FORMHANDLE, annot: ^ANNOTATION, buffer: ^WCHAR, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Gets the alternate name of |annot|, which is an interactive form annotation.
	// |buffer| is only modified if |buflen| is longer than the length of contents.
	// In case of error, nothing will be added to |buffer| and the return value will
	// be 0. Note that return value of empty string is 2 for "\0\0".
	//
	//    hHandle     -   handle to the form fill module, returned by
	//                    FPDFDOC_InitFormFillEnvironment().
	//    annot       -   handle to an interactive form annotation.
	//    buffer      -   buffer for holding the alternate name string, encoded in
	//                    UTF-16LE.
	//    buflen      -   length of the buffer in bytes.
	//
	// Returns the length of the string value in bytes.
	@(link_name = "FPDFAnnot_GetFormFieldAlternateName")
	annot_get_form_field_alternate_name :: proc(hHandle: ^FORMHANDLE, annot: ^ANNOTATION, buffer: ^WCHAR, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Gets the form field type of |annot|, which is an interactive form annotation.
	//
	//    hHandle     -   handle to the form fill module, returned by
	//                    FPDFDOC_InitFormFillEnvironment().
	//    annot       -   handle to an interactive form annotation.
	//
	// Returns the type of the form field (one of the FPDF_FORMFIELD_* values) on
	// success. Returns -1 on error.
	// See field types in fpdf_formfill.h.
	@(link_name = "FPDFAnnot_GetFormFieldType")
	annot_get_form_field_type :: proc(hHandle: ^FORMHANDLE, annot: ^ANNOTATION) -> c.int ---

	// Experimental API.
	// Gets the value of |annot|, which is an interactive form annotation.
	// |buffer| is only modified if |buflen| is longer than the length of contents.
	// In case of error, nothing will be added to |buffer| and the return value will
	// be 0. Note that return value of empty string is 2 for "\0\0".
	//
	//    hHandle     -   handle to the form fill module, returned by
	//                    FPDFDOC_InitFormFillEnvironment().
	//    annot       -   handle to an interactive form annotation.
	//    buffer      -   buffer for holding the value string, encoded in UTF-16LE.
	//    buflen      -   length of the buffer in bytes.
	//
	// Returns the length of the string value in bytes.
	@(link_name = "FPDFAnnot_GetFormFieldValue")
	annot_get_form_field_value :: proc(hHandle: ^FORMHANDLE, annot: ^ANNOTATION, buffer: ^WCHAR, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Get the number of options in the |annot|'s "Opt" dictionary. Intended for
	// use with listbox and combobox widget annotations.
	//
	//   hHandle - handle to the form fill module, returned by
	//             FPDFDOC_InitFormFillEnvironment.
	//   annot   - handle to an annotation.
	//
	// Returns the number of options in "Opt" dictionary on success. Return value
	// will be -1 if annotation does not have an "Opt" dictionary or other error.
	@(link_name = "FPDFAnnot_GetOptionCount")
	annot_get_option_count :: proc(hHandle: ^FORMHANDLE, annot: ^ANNOTATION) -> c.int ---

	// Experimental API.
	// Get the string value for the label of the option at |index| in |annot|'s
	// "Opt" dictionary. Intended for use with listbox and combobox widget
	// annotations. |buffer| is only modified if |buflen| is longer than the length
	// of contents. If index is out of range or in case of other error, nothing
	// will be added to |buffer| and the return value will be 0. Note that
	// return value of empty string is 2 for "\0\0".
	//
	//   hHandle - handle to the form fill module, returned by
	//             FPDFDOC_InitFormFillEnvironment.
	//   annot   - handle to an annotation.
	//   index   - numeric index of the option in the "Opt" array
	//   buffer  - buffer for holding the value string, encoded in UTF-16LE.
	//   buflen  - length of the buffer in bytes.
	//
	// Returns the length of the string value in bytes.
	// If |annot| does not have an "Opt" array, |index| is out of range or if any
	// other error occurs, returns 0.
	@(link_name = "FPDFAnnot_GetOptionLabel")
	annot_get_option_label :: proc(hHandle: ^FORMHANDLE, annot: ^ANNOTATION, index: c.int, buffer: ^WCHAR, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Determine whether or not the option at |index| in |annot|'s "Opt" dictionary
	// is selected. Intended for use with listbox and combobox widget annotations.
	//
	//   handle  - handle to the form fill module, returned by
	//             FPDFDOC_InitFormFillEnvironment.
	//   annot   - handle to an annotation.
	//   index   - numeric index of the option in the "Opt" array.
	//
	// Returns true if the option at |index| in |annot|'s "Opt" dictionary is
	// selected, false otherwise.
	@(link_name = "FPDFAnnot_IsOptionSelected")
	annot_is_option_selected :: proc(handle: ^FORMHANDLE, annot: ^ANNOTATION, index: c.int) -> BOOL ---

	// Experimental API.
	// Get the float value of the font size for an |annot| with variable text.
	// If 0, the font is to be auto-sized: its size is computed as a function of
	// the height of the annotation rectangle.
	//
	//   hHandle - handle to the form fill module, returned by
	//             FPDFDOC_InitFormFillEnvironment.
	//   annot   - handle to an annotation.
	//   value   - Required. Float which will be set to font size on success.
	//
	// Returns true if the font size was set in |value|, false on error or if
	// |value| not provided.
	@(link_name = "FPDFAnnot_GetFontSize")
	annot_get_font_size :: proc(hHandle: ^FORMHANDLE, annot: ^ANNOTATION, value: ^c.float) -> BOOL ---

	// Experimental API.
	// Determine if |annot| is a form widget that is checked. Intended for use with
	// checkbox and radio button widgets.
	//
	//   hHandle - handle to the form fill module, returned by
	//             FPDFDOC_InitFormFillEnvironment.
	//   annot   - handle to an annotation.
	//
	// Returns true if |annot| is a form widget and is checked, false otherwise.
	@(link_name = "FPDFAnnot_IsChecked")
	annot_is_checked :: proc(hHandle: ^FORMHANDLE, annot: ^ANNOTATION) -> BOOL ---

	// Experimental API.
	// Set the list of focusable annotation subtypes. Annotations of subtype
	// FPDF_ANNOT_WIDGET are by default focusable. New subtypes set using this API
	// will override the existing subtypes.
	//
	//   hHandle  - handle to the form fill module, returned by
	//              FPDFDOC_InitFormFillEnvironment.
	//   subtypes - list of annotation subtype which can be tabbed over.
	//   count    - total number of annotation subtype in list.
	// Returns true if list of annotation subtype is set successfully, false
	// otherwise.
	@(link_name = "FPDFAnnot_SetFocusableSubtypes")
	annot_set_focusable_subtypes :: proc(hHandle: ^FORMHANDLE, subtypes: ^ANNOTATION_SUBTYPE, count: c.size_t) -> BOOL ---

	// Experimental API.
	// Get the count of focusable annotation subtypes as set by host
	// for a |hHandle|.
	//
	//   hHandle  - handle to the form fill module, returned by
	//              FPDFDOC_InitFormFillEnvironment.
	// Returns the count of focusable annotation subtypes or -1 on error.
	// Note : Annotations of type FPDF_ANNOT_WIDGET are by default focusable.
	@(link_name = "FPDFAnnot_GetFocusableSubtypesCount")
	annot_get_focusable_subtypes_count :: proc(hHandle: ^FORMHANDLE) -> c.int ---

	// Experimental API.
	// Get the list of focusable annotation subtype as set by host.
	//
	//   hHandle  - handle to the form fill module, returned by
	//              FPDFDOC_InitFormFillEnvironment.
	//   subtypes - receives the list of annotation subtype which can be tabbed
	//              over. Caller must have allocated |subtypes| more than or
	//              equal to the count obtained from
	//              FPDFAnnot_GetFocusableSubtypesCount() API.
	//   count    - size of |subtypes|.
	// Returns true on success and set list of annotation subtype to |subtypes|,
	// false otherwise.
	// Note : Annotations of type FPDF_ANNOT_WIDGET are by default focusable.
	@(link_name = "FPDFAnnot_GetFocusableSubtypes")
	annot_get_focusable_subtypes :: proc(hHandle: ^FORMHANDLE, subtypes: ANNOTATION_SUBTYPE, count: c.size_t) -> BOOL ---

	// Experimental API.
	// Gets FPDF_LINK object for |annot|. Intended to use for link annotations.
	//
	//   annot   - handle to an annotation.
	//
	// Returns FPDF_LINK from the FPDF_ANNOTATION and NULL on failure,
	// if the input annot is NULL or input annot's subtype is not link.
	@(link_name = "FPDFAnnot_GetLink")
	annot_get_link :: proc(annot: ^ANNOTATION) -> ^LINK ---

	// Experimental API.
	// Gets the count of annotations in the |annot|'s control group.
	// A group of interactive form annotations is collectively called a form
	// control group. Here, |annot|, an interactive form annotation, should be
	// either a radio button or a checkbox.
	//
	//   hHandle - handle to the form fill module, returned by
	//             FPDFDOC_InitFormFillEnvironment.
	//   annot   - handle to an annotation.
	//
	// Returns number of controls in its control group or -1 on error.
	@(link_name = "PDFAnnot_GetFormControlCount")
	annot_get_form_control_count :: proc(hHandle: ^FORMHANDLE, annot: ^ANNOTATION) -> c.int ---

	// Experimental API.
	// Gets the index of |annot| in |annot|'s control group.
	// A group of interactive form annotations is collectively called a form
	// control group. Here, |annot|, an interactive form annotation, should be
	// either a radio button or a checkbox.
	//
	//   hHandle - handle to the form fill module, returned by
	//             FPDFDOC_InitFormFillEnvironment.
	//   annot   - handle to an annotation.
	//
	// Returns index of a given |annot| in its control group or -1 on error.
	@(link_name = "FPDFAnnot_GetFormControlIndex")
	annot_get_form_control_index :: proc(hHandle: ^FORMHANDLE, annot: ^ANNOTATION) -> c.int ---

	// Experimental API.
	// Gets the export value of |annot| which is an interactive form annotation.
	// Intended for use with radio button and checkbox widget annotations.
	// |buffer| is only modified if |buflen| is longer than the length of contents.
	// In case of error, nothing will be added to |buffer| and the return value
	// will be 0. Note that return value of empty string is 2 for "\0\0".
	//
	//    hHandle     -   handle to the form fill module, returned by
	//                    FPDFDOC_InitFormFillEnvironment().
	//    annot       -   handle to an interactive form annotation.
	//    buffer      -   buffer for holding the value string, encoded in UTF-16LE.
	//    buflen      -   length of the buffer in bytes.
	//
	// Returns the length of the string value in bytes.
	@(link_name = "FPDFAnnot_GetFormFieldExportValue")
	annot_get_form_field_export_value :: proc(hHandle: ^FORMHANDLE, annot: ^ANNOTATION, buffer: ^WCHAR, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Add a URI action to |annot|, overwriting the existing action, if any.
	//
	//   annot  - handle to a link annotation.
	//   uri    - the URI to be set, encoded in 7-bit ASCII.
	//
	// Returns true if successful.
	@(link_name = "FPDFAnnot_SetURI")
	annot_set_uri :: proc(annot: ^ANNOTATION, uri: cstring) -> BOOL ---
}

@(default_calling_convention = "c")
foreign lib {
	// Experimental API.
	// Create an annotation in |page| of the subtype |subtype|. If the specified
	// subtype is illegal or unsupported, then a new annotation will not be created.
	// Must call FPDFPage_CloseAnnot() when the annotation returned by this
	// function is no longer needed.
	//
	//   page      - handle to a page.
	//   subtype   - the subtype of the new annotation.
	//
	// Returns a handle to the new annotation object, or NULL on failure.
	@(link_name = "FPDFPage_CreateAnnot")
	page_create_annot :: proc(page: ^PAGE, subtype: ANNOTATION_SUBTYPE) -> ^ANNOTATION ---

	// Experimental API.
	// Get the number of annotations in |page|.
	//
	//   page   - handle to a page.
	//
	// Returns the number of annotations in |page|.
	@(link_name = "FPDFPage_GetAnnotCount")
	page_get_annot_count :: proc(page: ^PAGE) -> c.int ---

	// Experimental API.
	// Get annotation in |page| at |index|. Must call FPDFPage_CloseAnnot() when the
	// annotation returned by this function is no longer needed.
	//
	//   page  - handle to a page.
	//   index - the index of the annotation.
	//
	// Returns a handle to the annotation object, or NULL on failure.
	@(link_name = "FPDFPage_GetAnnot")
	page_get_annot :: proc(page: ^PAGE, index: c.int) -> ^ANNOTATION ---

	// Experimental API.
	// Get the index of |annot| in |page|. This is the opposite of
	// FPDFPage_GetAnnot().
	//
	//   page  - handle to the page that the annotation is on.
	//   annot - handle to an annotation.
	//
	// Returns the index of |annot|, or -1 on failure.
	@(link_name = "FPDFPage_GetAnnotIndex")
	page_annot_index :: proc(page: ^PAGE, annot: ^ANNOTATION) -> c.int ---

	// Experimental API.
	// Close an annotation. Must be called when the annotation returned by
	// FPDFPage_CreateAnnot() or FPDFPage_GetAnnot() is no longer needed. This
	// function does not remove the annotation from the document.
	//
	//   annot  - handle to an annotation.
	@(link_name = "FPDFPage_CloseAnnot")
	page_close_annot :: proc(annot: ^ANNOTATION) ---

	// Experimental API.
	// Remove the annotation in |page| at |index|.
	//
	//   page  - handle to a page.
	//   index - the index of the annotation.
	//
	// Returns true if successful.
	@(link_name = "FPDFPage_RemoveAnnot")
	page_remove_annot :: proc(page: ^PAGE, index: c.int) -> BOOL ---
}
