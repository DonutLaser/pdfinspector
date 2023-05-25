package app

import "core:fmt"
import "../gui"
import "../pdf"

Text_Modal :: struct {
	rect:          gui.Rect,
	viewport_rect: gui.Rect,
	y_offset:      i32,
	is_visible:    bool,
	// No reason to render utf16 text when you can render an image of that text. It's easier and the result is the same
	// in this case
	text:          gui.Image,
	scrollbar:     Scrollbar,
}

create_text_modal :: proc(center_x, center_y: i32) -> Text_Modal {
	rect := gui.Rect{
		center_x - TEXT_MODAL_WIDTH / 2,
		center_y - TEXT_MODAL_HEIGHT / 2,
		TEXT_MODAL_WIDTH,
		TEXT_MODAL_HEIGHT,
	}

	result := Text_Modal {
		rect = rect,
		viewport_rect = gui.Rect{
			rect.x + TEXT_PADDING,
			rect.y + TEXT_PADDING,
			rect.w - TEXT_PADDING + 2,
			rect.h - TEXT_PADDING * 2,
		},
		scrollbar = create_scrollbar(rect),
	}

	return result
}

resize_text_modal :: proc(tm: ^Text_Modal, center_x, center_y: i32) {
	tm.rect.x = center_x - TEXT_MODAL_WIDTH / 2
	tm.rect.y = center_y - TEXT_MODAL_HEIGHT / 2

	tm.viewport_rect.x = tm.rect.x + TEXT_PADDING
	tm.viewport_rect.y = tm.rect.y + TEXT_PADDING

	resize_scrollbar(&tm.scrollbar, tm.rect)
}

set_text_image :: proc(tm: ^Text_Modal, img: gui.Image) {
	tm.text = img

	if tm.text.height > tm.rect.h {
		show_scrollbar(&tm.scrollbar, tm.viewport_rect.h, tm.text.height)
	}
}

tick_text_modal :: proc(tm: ^Text_Modal, input: ^gui.Input) {
	if !tm.is_visible {
		return
	}

	if input.escape == .JUST_PRESSED || input.rmb == .JUST_PRESSED {
		tm.is_visible = false
	} else {
		if gui.is_point_in_rect(input.mouse_x, input.mouse_y, tm.rect) {
			tm.y_offset = calculate_scroll_offset(
				tm.y_offset,
				input.scroll_y,
				TEXT_MODAL_HEIGHT - TEXT_PADDING * 2,
				tm.text.height,
			)

			update_scrollbar_offset(&tm.scrollbar, tm.y_offset)
		}
	}
}

render_text_modal :: proc(tm: ^Text_Modal, app: ^App) {
	if !tm.is_visible {
		return
	}

	gui.draw_rect(app.window, tm.rect, MODAL_BG_COLOR)

	gui.clip_rect(app.window, tm.viewport_rect)
	gui.draw_image(
		app.window,
		&tm.text,
		tm.viewport_rect.x,
		tm.viewport_rect.y + tm.y_offset,
		TEXT_MODAL_TEXT_COLOR,
	)
	gui.unclip_rect(app.window)

	render_scrollbar(&tm.scrollbar, app)

	gui.draw_rect(app.window, tm.rect, MODAL_BORDER_COLOR, 1)
}
