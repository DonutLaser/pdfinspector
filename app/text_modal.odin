package app

import "core:fmt"
import "../gui"
import "../pdf"

Text_Modal :: struct {
	rect:       gui.Rect,
	is_visible: bool,
	text:       pdf.Pdf_Text,
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
		rect = rect,
	}

	return result
}

resize_text_modal :: proc(tm: ^Text_Modal, center_x, center_y: i32) {
	tm.rect.x = center_x - TEXT_MODAL_WIDTH / 2
	tm.rect.y = center_y - TEXT_MODAL_HEIGHT / 2

	r, b := gui.get_rect_end(tm.rect)
}

tick_text_modal :: proc(tm: ^Text_Modal, input: ^gui.Input) {
	if !tm.is_visible {
		return
	}

	if input.escape == .JUST_PRESSED || input.rmb == .JUST_PRESSED {
		tm.is_visible = false
	} else {
	}
}

render_text_modal :: proc(tm: ^Text_Modal, app: ^App) {
	if !tm.is_visible {
		return
	}

	gui.draw_rect(app.window, tm.rect, MODAL_BG_COLOR)
	gui.draw_rect(app.window, tm.rect, MODAL_BORDER_COLOR, 1)

	if tm.text.size != 0 {
		font := &app.fonts[14]
		gui.draw_text_u16(
			app.window,
			font,
			gui.Text_u16{data = tm.text.data, size = tm.text.size},
			tm.rect,
			TEXT_MODAL_TEXT_COLOR,
		)
	}
}
