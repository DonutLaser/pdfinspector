package pdfium

import "core:c"

when ODIN_OS == .Windows {
	foreign import lib "lib/pdfium.dll.lib"
} else {
	foreign import lib "system:pdfium"
}

@(default_calling_convention = "c")
foreign lib {
	// Function: FPDF_StructTree_GetForPage
	//          Get the structure tree for a page.
	// Parameters:
	//          page        -   Handle to the page, as returned by FPDF_LoadPage().
	// Return value:
	//          A handle to the structure tree or NULL on error.
	@(link_name = "FPDF_StructTree_GetForPage")
	structree_get_for_page :: proc(page: ^PAGE) -> ^STRUCTTREE ---

	// Function: FPDF_StructTree_Close
	//          Release a resource allocated by FPDF_StructTree_GetForPage().
	// Parameters:
	//          struct_tree -   Handle to the structure tree, as returned by
	//                          FPDF_StructTree_LoadPage().
	// Return value:
	//          None.
	@(link_name = "FPDF_StructTree_Close")
	structree_close :: proc(struct_tree: ^STRUCTTREE) ---

	// Function: FPDF_StructTree_CountChildren
	//          Count the number of children for the structure tree.
	// Parameters:
	//          struct_tree -   Handle to the structure tree, as returned by
	//                          FPDF_StructTree_LoadPage().
	// Return value:
	//          The number of children, or -1 on error.
	@(link_name = "FPDF_StructTree_CountChildren")
	structtree_count_children :: proc(struct_tree: ^STRUCTTREE) -> c.int ---

	// Function: FPDF_StructTree_GetChildAtIndex
	//          Get a child in the structure tree.
	// Parameters:
	//          struct_tree -   Handle to the structure tree, as returned by
	//                          FPDF_StructTree_LoadPage().
	//          index       -   The index for the child, 0-based.
	// Return value:
	//          The child at the n-th index or NULL on error.
	@(link_name = "FPDF_StructTree_GetChildAtIndex")
	structtree_get_child_at_index :: proc(struct_tree: ^STRUCTTREE, index: c.int) -> ^STRUCTELEMENT ---
}

@(default_calling_convention = "c")
foreign lib {
	// Function: FPDF_StructElement_GetAltText
	//          Get the alt text for a given element.
	// Parameters:
	//          struct_element -   Handle to the struct element.
	//          buffer         -   A buffer for output the alt text. May be NULL.
	//          buflen         -   The length of the buffer, in bytes. May be 0.
	// Return value:
	//          The number of bytes in the alt text, including the terminating NUL
	//          character. The number of bytes is returned regardless of the
	//          |buffer| and |buflen| parameters.
	// Comments:
	//          Regardless of the platform, the |buffer| is always in UTF-16LE
	//          encoding. The string is terminated by a UTF16 NUL character. If
	//          |buflen| is less than the required length, or |buffer| is NULL,
	//          |buffer| will not be modified.
	@(link_name = "FPDF_StructElement_GetAltText")
	structelement_get_alt_text :: proc(struct_element: ^STRUCTELEMENT, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Function: FPDF_StructElement_GetActualText
	//          Get the actual text for a given element.
	// Parameters:
	//          struct_element -   Handle to the struct element.
	//          buffer         -   A buffer for output the actual text. May be NULL.
	//          buflen         -   The length of the buffer, in bytes. May be 0.
	// Return value:
	//          The number of bytes in the actual text, including the terminating
	//          NUL character. The number of bytes is returned regardless of the
	//          |buffer| and |buflen| parameters.
	// Comments:
	//          Regardless of the platform, the |buffer| is always in UTF-16LE
	//          encoding. The string is terminated by a UTF16 NUL character. If
	//          |buflen| is less than the required length, or |buffer| is NULL,
	//          |buffer| will not be modified.
	@(link_name = "FPDF_StructElement_GetActualText")
	structelement_get_actual_text :: proc(struct_element: ^STRUCTELEMENT, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Function: FPDF_StructElement_GetID
	//          Get the ID for a given element.
	// Parameters:
	//          struct_element -   Handle to the struct element.
	//          buffer         -   A buffer for output the ID string. May be NULL.
	//          buflen         -   The length of the buffer, in bytes. May be 0.
	// Return value:
	//          The number of bytes in the ID string, including the terminating NUL
	//          character. The number of bytes is returned regardless of the
	//          |buffer| and |buflen| parameters.
	// Comments:
	//          Regardless of the platform, the |buffer| is always in UTF-16LE
	//          encoding. The string is terminated by a UTF16 NUL character. If
	//          |buflen| is less than the required length, or |buffer| is NULL,
	//          |buffer| will not be modified.
	@(link_name = "FPDF_StructElement_GetID")
	structelement_get_id :: proc(struct_element: ^STRUCTELEMENT, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Function: FPDF_StructElement_GetLang
	//          Get the case-insensitive IETF BCP 47 language code for an element.
	// Parameters:
	//          struct_element -   Handle to the struct element.
	//          buffer         -   A buffer for output the lang string. May be NULL.
	//          buflen         -   The length of the buffer, in bytes. May be 0.
	// Return value:
	//          The number of bytes in the ID string, including the terminating NUL
	//          character. The number of bytes is returned regardless of the
	//          |buffer| and |buflen| parameters.
	// Comments:
	//          Regardless of the platform, the |buffer| is always in UTF-16LE
	//          encoding. The string is terminated by a UTF16 NUL character. If
	//          |buflen| is less than the required length, or |buffer| is NULL,
	//          |buffer| will not be modified.
	@(link_name = "FPDF_StructElement_GetLang")
	structelement_get_lang :: proc(struct_element: ^STRUCTELEMENT, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Function: FPDF_StructElement_GetStringAttribute
	//          Get a struct element attribute of type "name" or "string".
	// Parameters:
	//          struct_element -   Handle to the struct element.
	//          attr_name      -   The name of the attribute to retrieve.
	//          buffer         -   A buffer for output. May be NULL.
	//          buflen         -   The length of the buffer, in bytes. May be 0.
	// Return value:
	//          The number of bytes in the attribute value, including the
	//          terminating NUL character. The number of bytes is returned
	//          regardless of the |buffer| and |buflen| parameters.
	// Comments:
	//          Regardless of the platform, the |buffer| is always in UTF-16LE
	//          encoding. The string is terminated by a UTF16 NUL character. If
	//          |buflen| is less than the required length, or |buffer| is NULL,
	//          |buffer| will not be modified.
	@(link_name = "FPDF_StructElement_GetStringAttribute")
	structelement_get_string_attribute :: proc(struct_element: ^STRUCTELEMENT, attr_name: BYTESTRING, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Function: FPDF_StructElement_GetMarkedContentID
	//          Get the marked content ID for a given element.
	// Parameters:
	//          struct_element -   Handle to the struct element.
	// Return value:
	//          The marked content ID of the element. If no ID exists, returns
	//          -1.
	@(link_name = "FPDF_StructElement_GetMarkedContentID")
	structelement_get_marked_content_id :: proc(struct_element: ^STRUCTELEMENT) -> c.int ---

	// Function: FPDF_StructElement_GetType
	//           Get the type (/S) for a given element.
	// Parameters:
	//           struct_element - Handle to the struct element.
	//           buffer         - A buffer for output. May be NULL.
	//           buflen         - The length of the buffer, in bytes. May be 0.
	// Return value:
	//           The number of bytes in the type, including the terminating NUL
	//           character. The number of bytes is returned regardless of the
	//           |buffer| and |buflen| parameters.
	// Comments:
	//           Regardless of the platform, the |buffer| is always in UTF-16LE
	//           encoding. The string is terminated by a UTF16 NUL character. If
	//           |buflen| is less than the required length, or |buffer| is NULL,
	//           |buffer| will not be modified.
	@(link_name = "FPDF_StructElement_GetType")
	structelement_get_type :: proc(struct_element: ^STRUCTELEMENT, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Experimental API.
	// Function: FPDF_StructElement_GetObjType
	//           Get the object type (/Type) for a given element.
	// Parameters:
	//           struct_element - Handle to the struct element.
	//           buffer         - A buffer for output. May be NULL.
	//           buflen         - The length of the buffer, in bytes. May be 0.
	// Return value:
	//           The number of bytes in the object type, including the terminating
	//           NUL character. The number of bytes is returned regardless of the
	//           |buffer| and |buflen| parameters.
	// Comments:
	//           Regardless of the platform, the |buffer| is always in UTF-16LE
	//           encoding. The string is terminated by a UTF16 NUL character. If
	//           |buflen| is less than the required length, or |buffer| is NULL,
	//           |buffer| will not be modified.
	@(link_name = "FPDF_StructElement_GetObjType")
	structelement_get_obj_type :: proc(struct_element: ^STRUCTELEMENT, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Function: FPDF_StructElement_GetTitle
	//           Get the title (/T) for a given element.
	// Parameters:
	//           struct_element - Handle to the struct element.
	//           buffer         - A buffer for output. May be NULL.
	//           buflen         - The length of the buffer, in bytes. May be 0.
	// Return value:
	//           The number of bytes in the title, including the terminating NUL
	//           character. The number of bytes is returned regardless of the
	//           |buffer| and |buflen| parameters.
	// Comments:
	//           Regardless of the platform, the |buffer| is always in UTF-16LE
	//           encoding. The string is terminated by a UTF16 NUL character. If
	//           |buflen| is less than the required length, or |buffer| is NULL,
	//           |buffer| will not be modified.
	@(link_name = "FPDF_StructElement_GetTitle")
	structelement_get_title :: proc(struct_element: ^STRUCTELEMENT, buffer: rawptr, buflen: c.ulong) -> c.ulong ---

	// Function: FPDF_StructElement_CountChildren
	//          Count the number of children for the structure element.
	// Parameters:
	//          struct_element -   Handle to the struct element.
	// Return value:
	//          The number of children, or -1 on error.
	@(link_name = "FPDF_StructElement_CountChildren")
	structelement_count_children :: proc(struct_element: ^STRUCTELEMENT) -> c.int ---

	// Function: FPDF_StructElement_GetChildAtIndex
	//          Get a child in the structure element.
	// Parameters:
	//          struct_element -   Handle to the struct element.
	//          index          -   The index for the child, 0-based.
	// Return value:
	//          The child at the n-th index or NULL on error.
	// Comments:
	//          If the child exists but is not an element, then this function will
	//          return NULL. This will also return NULL for out of bounds indices.
	@(link_name = "FPDF_StructElement_GetChildAtIndex")
	structelement_get_child_at_index :: proc(struct_element: ^STRUCTELEMENT, index: c.int) -> ^STRUCTELEMENT ---

	// Experimental API.
	// Function: FPDF_StructElement_GetParent
	//          Get the parent of the structure element.
	// Parameters:
	//          struct_element -   Handle to the struct element.
	// Return value:
	//          The parent structure element or NULL on error.
	// Comments:
	//          If structure element is StructTreeRoot, then this function will
	//          return NULL.
	@(link_name = "FPDF_StructElement_GetParent")
	structelement_get_parent :: proc(struct_element: ^STRUCTELEMENT) -> ^STRUCTELEMENT ---

	// Function: FPDF_StructElement_GetAttributeCount
	//          Count the number of attributes for the structure element.
	// Parameters:
	//          struct_element -   Handle to the struct element.
	// Return value:
	//          The number of attributes, or -1 on error.
	@(link_name = "FPDF_StructElement_GetAttributeCount")
	structelement_get_attribute_count :: proc(struct_element: ^STRUCTELEMENT) -> c.int ---

	// Experimental API.
	// Function: FPDF_StructElement_GetAttributeAtIndex
	//          Get an attribute object in the structure element.
	// Parameters:
	//          struct_element -   Handle to the struct element.
	//          index          -   The index for the attribute object, 0-based.
	// Return value:
	//          The attribute object at the n-th index or NULL on error.
	// Comments:
	//          If the attribute object exists but is not a dict, then this
	//          function will return NULL. This will also return NULL for out of
	//          bounds indices.
	@(link_name = "FPDF_StructElement_GetAttributeAtIndex")
	structelement_get_attribute_at_index :: proc(struct_element: ^STRUCTELEMENT, index: c.int) -> ^STRUCTELEMENT_ATTR ---

	// Experimental API.
	// Function: FPDF_StructElement_Attr_GetCount
	//          Count the number of attributes in a structure element attribute map.
	// Parameters:
	//          struct_attribute - Handle to the struct element attribute.
	// Return value:
	//          The number of attributes, or -1 on error.
	@(link_name = "FPDF_StructElement_Attr_GetCount")
	structelement_attr_get_count :: proc(struct_attribute: ^STRUCTELEMENT_ATTR) -> c.int ---

	// Experimental API.
	// Function: FPDF_StructElement_Attr_GetName
	//          Get the name of an attribute in a structure element attribute map.
	// Parameters:
	//          struct_attribute   - Handle to the struct element attribute.
	//          index              - The index of attribute in the map.
	//          buffer             - A buffer for output. May be NULL. This is only
	//                               modified if |buflen| is longer than the length
	//                               of the key. Optional, pass null to just
	//                               retrieve the size of the buffer needed.
	//          buflen             - The length of the buffer.
	//          out_buflen         - A pointer to variable that will receive the
	//                               minimum buffer size to contain the key. Not
	//                               filled if FALSE is returned.
	// Return value:
	//          TRUE if the operation was successful, FALSE otherwise.
	@(link_name = "FPDF_StructElement_Attr_GetName")
	structelement_attr_get_name :: proc(struct_attribute: ^STRUCTELEMENT_ATTR, index: c.int, buffer: rawptr, buflen: c.ulong, out_buflen: ^c.ulong) -> BOOL ---

	// Experimental API.
	// Function: FPDF_StructElement_Attr_GetType
	//          Get the type of an attribute in a structure element attribute map.
	// Parameters:
	//          struct_attribute   - Handle to the struct element attribute.
	//          name               - The attribute name.
	// Return value:
	//          Returns the type of the value, or FPDF_OBJECT_UNKNOWN in case of
	//          failure.
	@(link_name = "FPDF_StructElement_Attr_GetType")
	structelement_attr_get_type :: proc(struct_attribute: ^STRUCTELEMENT_ATTR, name: BYTESTRING) -> OBJECT_TYPE ---

	// Experimental API.
	// Function: FPDF_StructElement_Attr_GetBooleanValue
	//          Get the value of a boolean attribute in an attribute map by name as
	//          FPDF_BOOL. FPDF_StructElement_Attr_GetType() should have returned
	//          FPDF_OBJECT_BOOLEAN for this property.
	// Parameters:
	//          struct_attribute   - Handle to the struct element attribute.
	//          name               - The attribute name.
	//          out_value          - A pointer to variable that will receive the
	//                               value. Not filled if false is returned.
	// Return value:
	//          Returns TRUE if the name maps to a boolean value, FALSE otherwise.
	@(link_name = "FPDF_StructElement_Attr_GetBooleanValue")
	structelement_attr_get_boolean_value :: proc(struct_attribute: ^STRUCTELEMENT_ATTR, name: BYTESTRING, out_value: ^BOOL) -> BOOL ---

	// Experimental API.
	// Function: FPDF_StructElement_Attr_GetNumberValue
	//          Get the value of a number attribute in an attribute map by name as
	//          float. FPDF_StructElement_Attr_GetType() should have returned
	//          FPDF_OBJECT_NUMBER for this property.
	// Parameters:
	//          struct_attribute   - Handle to the struct element attribute.
	//          name               - The attribute name.
	//          out_value          - A pointer to variable that will receive the
	//                               value. Not filled if false is returned.
	// Return value:
	//          Returns TRUE if the name maps to a number value, FALSE otherwise.
	@(link_name = "FPDF_StructElement_Attr_GetNumberValue")
	structelement_attr_get_number_value :: proc(struct_attribute: ^STRUCTELEMENT_ATTR, name: BYTESTRING, out_value: ^c.float) -> BOOL ---

	// Experimental API.
	// Function: FPDF_StructElement_Attr_GetStringValue
	//          Get the value of a string attribute in an attribute map by name as
	//          string. FPDF_StructElement_Attr_GetType() should have returned
	//          FPDF_OBJECT_STRING or FPDF_OBJECT_NAME for this property.
	// Parameters:
	//          struct_attribute   - Handle to the struct element attribute.
	//          name               - The attribute name.
	//          buffer             - A buffer for holding the returned key in
	//                               UTF-16LE. This is only modified if |buflen| is
	//                               longer than the length of the key. Optional,
	//                               pass null to just retrieve the size of the
	//                               buffer needed.
	//          buflen             - The length of the buffer.
	//          out_buflen         - A pointer to variable that will receive the
	//                               minimum buffer size to contain the key. Not
	//                               filled if FALSE is returned.
	// Return value:
	//          Returns TRUE if the name maps to a string value, FALSE otherwise.
	@(link_name = "FPDF_StructElement_Attr_GetStringValue")
	structelement_attr_get_string_value :: proc(struct_attribute: ^STRUCTELEMENT_ATTR, name: BYTESTRING, buffer: rawptr, buflen: c.ulong, out_buflen: ^c.ulong) -> BOOL ---

	// Experimental API.
	// Function: FPDF_StructElement_Attr_GetBlobValue
	//          Get the value of a blob attribute in an attribute map by name as
	//          string.
	// Parameters:
	//          struct_attribute   - Handle to the struct element attribute.
	//          name               - The attribute name.
	//          buffer             - A buffer for holding the returned value. This
	//                               is only modified if |buflen| is at least as
	//                               long as the length of the value. Optional, pass
	//                               null to just retrieve the size of the buffer
	//                               needed.
	//          buflen             - The length of the buffer.
	//          out_buflen         - A pointer to variable that will receive the
	//                               minimum buffer size to contain the key. Not
	//                               filled if FALSE is returned.
	// Return value:
	//          Returns TRUE if the name maps to a string value, FALSE otherwise.
	@(link_name = "FPDF_StructElement_Attr_GetBlobValue")
	structelement_attr_get_blob_value :: proc(struct_attribute: ^STRUCTELEMENT_ATTR, name: BYTESTRING, buffer: rawptr, buflen: c.ulong, out_buflen: ^c.ulong) -> BOOL ---

	// Experimental API.
	// Function: FPDF_StructElement_GetMarkedContentIdCount
	//          Get the count of marked content ids for a given element.
	// Parameters:
	//          struct_element -   Handle to the struct element.
	// Return value:
	//          The count of marked content ids or -1 if none exists.
	@(link_name = "FPDF_StructElement_GetMarkedContentIdCount")
	structelement_get_marked_content_id_count :: proc(struct_element: ^STRUCTELEMENT) -> c.int ---

	// Experimental API.
	// Function: FPDF_StructElement_GetMarkedContentIdAtIndex
	//          Get the marked content id at a given index for a given element.
	// Parameters:
	//          struct_element -   Handle to the struct element.
	//          index          -   The index of the marked content id, 0-based.
	// Return value:
	//          The marked content ID of the element. If no ID exists, returns
	//          -1.
	@(link_name = "FPDF_StructElement_GetMarkedContentIdAtIndex")
	structelement_get_marked_content_id_at_index :: proc(struct_element: ^STRUCTELEMENT, index: c.int) -> c.int ---
}
