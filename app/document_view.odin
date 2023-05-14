package app

import "core:fmt"
import "../gui"
import "../pdf"

Document_Page :: struct {
	image: gui.Image,
}

Document_View :: struct {
	rect:  gui.Rect,
	pages: []Document_Page,
}

create_document_view :: proc(rect: gui.Rect, page_count: i32) -> Document_View {
	return Document_View{rect = rect, pages = make([]Document_Page, page_count)}
}

destroy_document_view :: proc(dv: ^Document_View) {
	delete(dv.pages)
}

setup_document_view_page :: proc(dv: ^Document_View, page_index: i32, image: gui.Image) {
	assert(page_index < i32(len(dv.pages)))

	dv.pages[page_index] = Document_Page {
		image = image,
	}
}

resize_document_view :: proc(dv: ^Document_View, rect: gui.Rect) {
	dv.rect = rect
}

tick_document_view :: proc(dv: ^Document_View, app: ^App, input: ^gui.Input) {

}

render_document_view :: proc(dv: ^Document_View, app: ^App) {
	// x: i32 = TABS_WIDTH + STRUCTURE_WIDTH
	// width := app.window.width - x
	gui.draw_rect(app.window, dv.rect, DOCUMENT_VIEW_BG_COLOR)

	// TODO: do not draw image if no pixels of it are visible
	start_y: i32 = dv.rect.y
	for page in dv.pages {
		image := &dv.pages[0].image
		image_x, image_y: i32 = dv.rect.x + dv.rect.w / 2 - image.width / 2, dv.rect.y
		gui.draw_image(
			app.window,
			&dv.pages[0].image,
			image_x,
			image_y,
			gui.Color{255, 255, 255, 255},
		)

		start_y += image.height
	}
}
