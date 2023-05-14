package pdf

import "../libs/pdfium"

Bitmap :: struct {
	data:   rawptr,
	width:  i32,
	height: i32,
	stride: i32,
}

get_page_bitmap :: proc(doc: Document, index: i32) -> (Bitmap, bool) {
	if index >= doc.page_count {
		// TODO: print error
		return Bitmap{}, false
	}

	// Get page size
	page := pdfium.load_page(doc.data, index)
	width_pts := pdfium.get_page_widthf(page)
	width_px := i32(width_pts / 72 * 96) // TODO: unhardcode these and explain
	height_pts := pdfium.get_page_heightf(page)
	height_px := i32(height_pts / 72 * 96) // TODO: unhardcode these and explain

	// Setup pdf
	bitmap := pdfium.bitmap_create(width_px, height_px, 0)
	if bitmap == nil {
		// TODO: print error
		return Bitmap{}, false
	}
	pdfium.bitmap_fill_rect(bitmap, 0, 0, width_px, height_px, 0xFFFFFFFF)

	// Render to bitmap
	pdfium.render_page_bitmap(bitmap, page, 0, 0, width_px, height_px, 0, 0)

	result := Bitmap {
		data   = pdfium.bitmap_get_buffer(bitmap),
		width  = width_px,
		height = height_px,
		stride = pdfium.bitmap_get_stride(bitmap),
	}

	return result, true
}
