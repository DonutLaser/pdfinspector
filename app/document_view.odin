package app

import "core:fmt"
import "../gui"
import "../pdf"

Document_Page :: struct {
	image: gui.Image,
}

Document_View :: struct {
	pages: []Document_Page,
}

create_document_view :: proc(page_count: i32) -> Document_View {
	return Document_View{pages = make([]Document_Page, page_count)}
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

tick_document_view :: proc(dv: ^Document_View, app: ^App, input: ^gui.Input) {

}

render_document_view :: proc(dv: ^Document_View, app: ^App) {
	x: i32 = TABS_WIDTH + STRUCTURE_WIDTH
	gui.draw_rect(
		app.window,
		x,
		0,
		app.window.width - x,
		app.window.height,
		DOCUMENT_VIEW_BG_COLOR,
	)

	gui.draw_image(app.window, &dv.pages[0].image, x, 0, gui.Color{255, 255, 255, 255})
}
