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
	// Get number of paths inside |clip_path|.
	//
	//   clip_path - handle to a clip_path.
	//
	// Returns the number of objects in |clip_path| or -1 on failure.
	@(link_name = "FPDFClipPath_CountPaths")
	clippath_count_paths :: proc(clip_path: ^CLIPPATH) -> c.int ---

	// Experimental API.
	// Get number of segments inside one path of |clip_path|.
	//
	//   clip_path  - handle to a clip_path.
	//   path_index - index into the array of paths of the clip path.
	//
	// Returns the number of segments or -1 on failure.
	@(link_name = "FPDFClipPath_CountPathSegments")
	clippath_count_path_segments :: proc(clip_path: ^CLIPPATH, path_index: c.int) -> c.int ---

	// Experimental API.
	// Get segment in one specific path of |clip_path| at index.
	//
	//   clip_path     - handle to a clip_path.
	//   path_index    - the index of a path.
	//   segment_index - the index of a segment.
	//
	// Returns the handle to the segment, or NULL on failure. The caller does not
	// take ownership of the returned FPDF_PATHSEGMENT. Instead, it remains valid
	// until FPDF_ClosePage() is called for the page containing |clip_path|.
	@(link_name = "FPDFClipPath_GetPathSegment")
	clippath_get_path_segment :: proc(clip_path: ^CLIPPATH, path_index: c.int, segment_index: c.int) -> ^PATHSEGMENT ---
}
