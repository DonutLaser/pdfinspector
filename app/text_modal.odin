package app

import "../gui"

COPY_BTN_WIDTH :: 60

Text_Modal :: struct {
	rect:        gui.Rect,
	copy_button: Button,
	is_visible:  bool,
}

create_text_modal :: proc(center_x, center_y: i32) -> Text_Modal {
	rect := gui.Rect{
		center_x - TEXT_MODAL_WIDTH / 2,
		center_y - TEXT_MODAL_HEIGHT / 2,
		TEXT_MODAL_WIDTH,
		TEXT_MODAL_HEIGHT,
	}

	r, b := gui.get_rect_end(rect)

	result := Text_Modal {
		rect        = rect,
		copy_button = create_button(
			gui.Rect{
				r - TEXT_PADDING - COPY_BTN_WIDTH,
				b - TEXT_PADDING - BUTTON_HEIGHT,
				COPY_BTN_WIDTH,
				BUTTON_HEIGHT,
			},
			"Copy",
		),
	}

	return result
}

resize_text_modal :: proc(tm: ^Text_Modal, center_x, center_y: i32) {
	tm.rect.x = center_x - TEXT_MODAL_WIDTH / 2
	tm.rect.y = center_y - TEXT_MODAL_HEIGHT / 2

	r, b := gui.get_rect_end(tm.rect)
	tm.copy_button.rect = gui.Rect{
		r - TEXT_PADDING - COPY_BTN_WIDTH,
		b - TEXT_PADDING - BUTTON_HEIGHT,
		COPY_BTN_WIDTH,
		BUTTON_HEIGHT,
	}
}

tick_text_modal :: proc(tm: ^Text_Modal, input: ^gui.Input) {
	if !tm.is_visible {
		return
	}

	if input.escape == .JUST_PRESSED || input.rmb == .JUST_PRESSED {
		tm.is_visible = false
	} else {
		clicked := tick_button(&tm.copy_button, input)
		if clicked {

		}
	}
}

render_text_modal :: proc(tm: ^Text_Modal, app: ^App) {
	if !tm.is_visible {
		return
	}

	gui.draw_rect(app.window, tm.rect, MODAL_BG_COLOR)
	gui.draw_rect(app.window, tm.rect, MODAL_BORDER_COLOR, 1)

	render_button(&tm.copy_button, app)
}
