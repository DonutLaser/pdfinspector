package app

import "../gui"

Button :: struct {
	rect:       gui.Rect,
	is_hovered: bool,
	is_pressed: bool,
	text:       cstring,
}

create_button :: proc(rect: gui.Rect, text: cstring) -> Button {
	return Button{rect = rect, is_hovered = false, is_pressed = false, text = text}
}

tick_button :: proc(btn: ^Button, input: ^gui.Input) -> bool {
	result := false

	if gui.is_point_in_rect(input.mouse_x, input.mouse_y, btn.rect) {
		btn.is_hovered = true

		if input.lmb == .JUST_PRESSED || input.lmb == .PRESSED {
			btn.is_pressed = true
		} else if input.lmb == .JUST_RELEASED {
			btn.is_pressed = false
			result = true
		}
	} else {
		btn.is_hovered = false
		btn.is_pressed = false
	}

	return result
}

render_button :: proc(btn: ^Button, app: ^App) {
	color := BUTTON_COLOR_NORMAL
	if btn.is_pressed {
		color = BUTTON_COLOR_PRESSED
	} else if btn.is_hovered {
		color = BUTTON_COLOR_HOVER
	}

	gui.draw_rect(app.window, btn.rect, color)

	if btn.text != "" {
		font := &app.fonts[14]

		center_x, center_y := gui.get_rect_center(btn.rect)
		width, height := gui.measure_text(font, btn.text)
		x, y := center_x - width / 2, center_y - height / 2

		gui.draw_text(app.window, font, gui.Text{btn.text, false}, gui.Rect{x, y, -1, -1}, BUTTON_TEXT_COLOR)
	}
}
