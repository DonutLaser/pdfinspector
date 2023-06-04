package app

import "core:fmt"
import "../gui"
import "../pdf"

@(private = "file")
instance := Document_View{}
@(private = "file")
initialized := false

Document_Object_Highlight :: struct {
	page: i32,
	rect: gui.Rect,
}

Document_Page :: struct {
	image: gui.Image,
}

Document_View :: struct {
	rect:         gui.Rect,
	highlight:    Document_Object_Highlight,
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

document_view_highlight_object :: proc(page: i32, rect: gui.Rect) {
	instance.highlight = Document_Object_Highlight{page, rect}
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

	for page, index in instance.pages {
		rect := gui.layout_get_rect(&layout, page.image.width, page.image.height)
		rect.y += instance.y_offset

		if gui.do_rects_overlaps(instance.rect, rect) {
			x, y := rect.x + (rect.w - page.image.width) / 2, rect.y
			gui.draw_image(app.window, &instance.pages[index].image, x, y, gui.Color{255, 255, 255, 255})

			if instance.highlight.page == i32(index) {
				highlight_rect := gui.Rect{
					x + instance.highlight.rect.x,
					y + instance.highlight.rect.y,
					instance.highlight.rect.w,
					instance.highlight.rect.h,
				}
				gui.draw_rect(app.window, highlight_rect, DOCUMENT_VIEW_HIGHLIGHT_COLOR, 2)
			}
		}

		_ = gui.layout_get_rect(&layout, -1, DOCUMENT_VIEW_PAGE_SPACING)
	}

	scrollbar_render(&instance.scrollbar, app)
}
