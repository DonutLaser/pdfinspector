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
	// Function: FPDFSignatureObj_GetContents
	//          Get the contents of a signature object.
	// Parameters:
	//          signature   -   Handle to the signature object. Returned by
	//                          FPDF_GetSignatureObject().
	//          buffer      -   The address of a buffer that receives the contents.
	//          length      -   The size, in bytes, of |buffer|.
	// Return value:
	//          Returns the number of bytes in the contents on success, 0 on error.
	//
	// For public-key signatures, |buffer| is either a DER-encoded PKCS#1 binary or
	// a DER-encoded PKCS#7 binary. If |length| is less than the returned length, or
	// |buffer| is NULL, |buffer| will not be modified.
	@(link_name = "FPDFSignatureObj_GetContents")
	signatureobj_get_contents :: proc(signature: ^SIGNATURE, buffer: rawptr, length: c.ulong) -> c.ulong ---

	// Experimental API.
	// Function: FPDFSignatureObj_GetByteRange
	//          Get the byte range of a signature object.
	// Parameters:
	//          signature   -   Handle to the signature object. Returned by
	//                          FPDF_GetSignatureObject().
	//          buffer      -   The address of a buffer that receives the
	//                          byte range.
	//          length      -   The size, in ints, of |buffer|.
	// Return value:
	//          Returns the number of ints in the byte range on
	//          success, 0 on error.
	//
	// |buffer| is an array of pairs of integers (starting byte offset,
	// length in bytes) that describes the exact byte range for the digest
	// calculation. If |length| is less than the returned length, or
	// |buffer| is NULL, |buffer| will not be modified.
	@(link_name = "FPDFSignatureObj_GetByteRange")
	signatureobj_get_byte_range :: proc(signature: ^SIGNATURE, buffer: ^c.int, length: c.ulong) -> c.ulong ---

	// Experimental API.
	// Function: FPDFSignatureObj_GetSubFilter
	//          Get the encoding of the value of a signature object.
	// Parameters:
	//          signature   -   Handle to the signature object. Returned by
	//                          FPDF_GetSignatureObject().
	//          buffer      -   The address of a buffer that receives the encoding.
	//          length      -   The size, in bytes, of |buffer|.
	// Return value:
	//          Returns the number of bytes in the encoding name (including the
	//          trailing NUL character) on success, 0 on error.
	//
	// The |buffer| is always encoded in 7-bit ASCII. If |length| is less than the
	// returned length, or |buffer| is NULL, |buffer| will not be modified.
	@(link_name = "FPDFSignatureObj_GetSubFilter")
	signatureobj_get_sub_filter :: proc(signature: ^SIGNATURE, buffer: cstring, length: c.ulong) -> c.ulong ---

	// Experimental API.
	// Function: FPDFSignatureObj_GetReason
	//          Get the reason (comment) of the signature object.
	// Parameters:
	//          signature   -   Handle to the signature object. Returned by
	//                          FPDF_GetSignatureObject().
	//          buffer      -   The address of a buffer that receives the reason.
	//          length      -   The size, in bytes, of |buffer|.
	// Return value:
	//          Returns the number of bytes in the reason on success, 0 on error.
	//
	// Regardless of the platform, the |buffer| is always in UTF-16LE encoding. The
	// string is terminated by a UTF16 NUL character. If |length| is less than the
	// returned length, or |buffer| is NULL, |buffer| will not be modified.
	@(link_name = "FPDFSignatureObj_GetReason")
	signatureobj_get_reason :: proc(signature: ^SIGNATURE, buffer: rawptr, length: c.ulong) -> c.ulong ---

	// Experimental API.
	// Function: FPDFSignatureObj_GetTime
	//          Get the time of signing of a signature object.
	// Parameters:
	//          signature   -   Handle to the signature object. Returned by
	//                          FPDF_GetSignatureObject().
	//          buffer      -   The address of a buffer that receives the time.
	//          length      -   The size, in bytes, of |buffer|.
	// Return value:
	//          Returns the number of bytes in the encoding name (including the
	//          trailing NUL character) on success, 0 on error.
	//
	// The |buffer| is always encoded in 7-bit ASCII. If |length| is less than the
	// returned length, or |buffer| is NULL, |buffer| will not be modified.
	//
	// The format of time is expected to be D:YYYYMMDDHHMMSS+XX'YY', i.e. it's
	// percision is seconds, with timezone information. This value should be used
	// only when the time of signing is not available in the (PKCS#7 binary)
	// signature.
	@(link_name = "FPDFSignatureObj_GetTime")
	signtureobj_get_time :: proc(signature: ^SIGNATURE, buffer: cstring, length: c.ulong) -> c.ulong ---

	// Experimental API.
	// Function: FPDFSignatureObj_GetDocMDPPermission
	//          Get the DocMDP permission of a signature object.
	// Parameters:
	//          signature   -   Handle to the signature object. Returned by
	//                          FPDF_GetSignatureObject().
	// Return value:
	//          Returns the permission (1, 2 or 3) on success, 0 on error.
	@(link_name = "FPDFSignatureObj_GetDocMDPPermission")
	signatureobj_get_doc_md_permission :: proc(signature: ^SIGNATURE) -> c.uint ---
}
