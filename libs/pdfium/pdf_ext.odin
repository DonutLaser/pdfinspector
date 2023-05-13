package pdfium

import "core:c"
import "core:time"

when ODIN_OS == .Windows {
	foreign import lib "lib/pdfium.dll.lib"
} else {
	foreign import lib "system:pdfium"
}

// Unsupported XFA form.
UNSP_DOC_XFAFORM :: 1
// Unsupported portable collection.
UNSP_DOC_PORTABLECOLLECTION :: 2
// Unsupported attachment.
UNSP_DOC_ATTACHMENT :: 3
// Unsupported security.
UNSP_DOC_SECURITY :: 4
// Unsupported shared review.
UNSP_DOC_SHAREDREVIEW :: 5
// Unsupported shared form, acrobat.
UNSP_DOC_SHAREDFORM_ACROBAT :: 6
// Unsupported shared form, filesystem.
UNSP_DOC_SHAREDFORM_FILESYSTEM :: 7
// Unsupported shared form, email.
UNSP_DOC_SHAREDFORM_EMAIL :: 8
// Unsupported 3D annotation.
UNSP_ANNOT_3DANNOT :: 11
// Unsupported movie annotation.
UNSP_ANNOT_MOVIE :: 12
// Unsupported sound annotation.
UNSP_ANNOT_SOUND :: 13
// Unsupported screen media annotation.
UNSP_ANNOT_SCREEN_MEDIA :: 14
// Unsupported screen rich media annotation.
UNSP_ANNOT_SCREEN_RICHMEDIA :: 15
// Unsupported attachment annotation.
UNSP_ANNOT_ATTACHMENT :: 16
// Unsupported signature annotation.
UNSP_ANNOT_SIG :: 17

// Interface for unsupported feature notifications.
UNSUPPORT_INFO :: struct {
	// Version number of the interface. Must be 1.
	version:           c.int,

	// Unsupported object notification function.
	// Interface Version: 1
	// Implementation Required: Yes
	//
	//   pThis - pointer to the interface structure.
	//   nType - the type of unsupported object. One of the |FPDF_UNSP_*| entries.
	UnSupport_Handler: proc(pThis: ^UNSUPPORT_INFO, nType: c.int),
}

@(default_calling_convention = "c")
foreign lib {
	// Setup an unsupported object handler.
	//
	//   unsp_info - Pointer to an UNSUPPORT_INFO structure.
	//
	// Returns TRUE on success.
	@(link_name = "FSDK_SetUnSpObjProcessHandler")
	fsdk_set_un_sp_obj_process_handler :: proc(unsp_info: ^UNSUPPORT_INFO) -> BOOL ---
	// TODO
	// Set replacement function for calls to time().
	//
	// This API is intended to be used only for testing, thus may cause PDFium to
	// behave poorly in production environments.
	//
	//   func - Function pointer to alternate implementation of time(), or
	//          NULL to restore to actual time() call itself.
	// FSDK_SetTimeFunction :: proc(fn: proc() -> time.time) ---
	// Set replacement function for calls to localtime().
	//
	// This API is intended to be used only for testing, thus may cause PDFium to
	// behave poorly in production environments.
	//
	//   func - Function pointer to alternate implementation of localtime(), or
	//          NULL to restore to actual localtime() call itself.
	// FSDK_SetLocaltimeFunction :: proc(struct tm* (*func)(const time_t*)) ---
}

// Unknown page mode.
PAGEMODE_UNKNOWN :: -1
// Document outline, and thumbnails hidden.
PAGEMODE_USENONE :: 0
// Document outline visible.
PAGEMODE_USEOUTLINES :: 1
// Thumbnail images visible.
PAGEMODE_USETHUMBS :: 2
// Full-screen mode, no menu bar, window controls, or other decorations visible.
PAGEMODE_FULLSCREEN :: 3
// Optional content group panel visible.
PAGEMODE_USEOC :: 4
// Attachments panel visible.
PAGEMODE_USEATTACHMENTS :: 5
