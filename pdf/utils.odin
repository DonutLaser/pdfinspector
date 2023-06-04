package pdf

import "../libs/pdfium"

DPI :: 96 // Usually, screen DPI and we do want to render on a screen, so...

@(private)
pts_to_px :: proc(value: f32) -> f32 {
	return value / 72 * DPI
}

@(private)
get_page_size :: proc(page: ^pdfium.PAGE) -> (i32, i32) {
	width_pts := pdfium.get_page_widthf(page)
	height_pts := pdfium.get_page_heightf(page)

	return i32(pts_to_px(width_pts)), i32(pts_to_px(height_pts))
}
