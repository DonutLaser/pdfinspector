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
	rect:         gui.Rect,
	pages:        [dynamic]Document_Page,
	y_offset:     i32,
	total_height: i32,
	scrollbar:    Scrollbar,
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

	instance.total_height = (i32(len(instance.pages)) - 1) * DOCUMENT_VIEW_PAGE_SPACING
	for page in instance.pages {
		instance.total_height += page.image.height
	}

	scrollbar_setup(&instance.scrollbar, instance.rect, instance.rect, instance.total_height)
}

document_view_resize :: proc(rect: gui.Rect) {
	instance.rect = rect
	scrollbar_setup(&instance.scrollbar, instance.rect, instance.rect, instance.total_height)
}

document_view_tick :: proc(input: ^gui.Input) {
	if gui.is_point_in_rect(input.mouse_x, input.mouse_y, instance.rect) {
		instance.y_offset = calculate_scroll_offset(
			instance.y_offset,
			input.scroll_y,
			instance.rect.h,
			instance.total_height,
		)
		scrollbar_update_offset(&instance.scrollbar, instance.y_offset)
	}
}

document_view_render :: proc(app: ^App) {
	gui.draw_rect(app.window, instance.rect, DOCUMENT_VIEW_BG_COLOR)

	layout := gui.layout_new(instance.rect)

	for page in instance.pages {
		image := &instance.pages[0].image
		rect := gui.layout_get_rect(&layout, image.width, image.height)

		offset_rect := gui.Rect{rect.x, rect.y + instance.y_offset, rect.w, rect.h}

		if gui.do_rects_overlaps(instance.rect, offset_rect) {
			gui.draw_image(
				app.window,
				&instance.pages[0].image,
				rect.x + (rect.w - image.width) / 2,
				offset_rect.y,
				gui.Color{255, 255, 255, 255},
			)
		}

		_ = gui.layout_get_rect(&layout, -1, DOCUMENT_VIEW_PAGE_SPACING)
	}

	scrollbar_render(&instance.scrollbar, app)
}
