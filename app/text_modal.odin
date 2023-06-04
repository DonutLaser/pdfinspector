package app

import "core:fmt"
import "../gui"
import "../pdf"

@(private = "file")
instance := Text_Modal{}

Text_Modal :: struct {
	rect:          gui.Rect,
	viewport_rect: gui.Rect,
	y_offset:      i32,
	// No reason to render utf16 text when you can render an image of that text. It's easier and the result is the same
	// in this case
	text:          gui.Image,
	scrollbar:     Scrollbar,
}

text_modal_show :: proc(parent_rect: gui.Rect) {
	instance.rect = gui.place_rect_in_center(parent_rect, TEXT_MODAL_SIZE, TEXT_MODAL_SIZE)
	instance.viewport_rect = gui.contract_rect(instance.rect, TEXT_MODAL_PADDING)
	scrollbar_setup(&instance.scrollbar, instance.rect, instance.viewport_rect, instance.text.height)
}

// TODO: resize this

text_modal_set_text :: proc(img: gui.Image) {
	instance.text = img
}

text_modal_tick :: proc(input: ^gui.Input) {
	if gui.is_point_in_rect(input.mouse_x, input.mouse_y, instance.rect) {
		instance.y_offset = calculate_scroll_offset(
			instance.y_offset,
			input.scroll_y,
			TEXT_MODAL_SIZE - TEXT_MODAL_PADDING * 2,
			instance.text.height,
		)

		scrollbar_update_offset(&instance.scrollbar, instance.y_offset)
	}
}

text_modal_render :: proc(app: ^App) {
	gui.draw_rect(app.window, instance.rect, MODAL_BG_COLOR)

	gui.clip_rect(app.window, instance.viewport_rect)
	gui.draw_image(
		app.window,
		&instance.text,
		instance.viewport_rect.x,
		instance.viewport_rect.y + instance.y_offset,
		TEXT_MODAL_TEXT_COLOR,
	)
	gui.unclip_rect(app.window)

	scrollbar_render(&instance.scrollbar, app)

	gui.draw_rect(app.window, instance.rect, MODAL_BORDER_COLOR, 1)
}
