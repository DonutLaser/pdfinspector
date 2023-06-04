package app

import "core:fmt"
import "../gui"
import "../pdf"

@(private = "file")
instance := Document_View{}
@(private = "file")
initialized := false

Document_Page :: struct {
	image: gui.Image,
}

Document_View :: struct {
	rect:  gui.Rect,
	pages: [dynamic]Document_Page,
}

document_view_init :: proc(rect: gui.Rect) {
	if initialized {
		return
	}

	instance.rect = rect

	initialized = true
}

document_view_deinit :: proc() {
	delete(instance.pages)
}

document_view_add_page :: proc(image: gui.Image) {
	append(&instance.pages, Document_Page{image = image})
}

document_view_resize :: proc(rect: gui.Rect) {
	instance.rect = rect
}

document_view_tick :: proc(app: ^App, input: ^gui.Input) {
	// TODO: implement scrolling
}

document_view_render :: proc(app: ^App) {
	gui.draw_rect(app.window, instance.rect, DOCUMENT_VIEW_BG_COLOR)

	layout := gui.layout_new(instance.rect)

	for page in instance.pages {
		image := &instance.pages[0].image
		rect := gui.layout_get_rect(&layout, image.width, image.height)

		if gui.do_rects_overlaps(instance.rect, rect) {
			gui.draw_image(
				app.window,
				&instance.pages[0].image,
				rect.x + (rect.w - image.width) / 2,
				rect.y,
				gui.Color{255, 255, 255, 255},
			)
		}
	}
}
