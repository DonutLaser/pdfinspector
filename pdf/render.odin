package pdf

import "core:fmt"
import "../libs/pdfium"

Bitmap :: struct {
	data:   rawptr,
	width:  i32,
	height: i32,
	stride: i32,
}

get_page_bitmap :: proc(doc: Document, index: i32) -> (Bitmap, bool) {
	if index >= doc.page_count {
		fmt.eprintf("Error: Cannot get page %d bitmap, there are only %d pages in the document", index, doc.page_count)
		return Bitmap{}, false
	}

	page := pdfium.load_page(doc.data, index)
	width_px, height_px := get_page_size(page)

	// Setup pdf
	bitmap := pdfium.bitmap_create(width_px, height_px, 0)
	if bitmap == nil {
		fmt.eprintln("Error: cannot create a bitmap")
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
