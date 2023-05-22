package app

import "core:time"
import "core:fmt"
import "core:strings"
import "../gui"

Tab_Button :: struct {
	rect:               gui.Rect,
	is_hovered:         bool,
	is_pressed:         bool,
	icon:               ^gui.Image,
	tooltip:            cstring,
	is_tooltip_visible: bool,
	tooltip_stopwatch:  time.Stopwatch,
}

create_tab_button :: proc(rect: gui.Rect) -> Tab_Button {
	return(
		Tab_Button{
			rect = rect,
			is_hovered = false,
			is_pressed = false,
			is_tooltip_visible = false,
		} \
	)
}

tick_tab_button :: proc(btn: ^Tab_Button, input: ^gui.Input) -> bool {
	result := false

	time.read_cycle_counter()

	if gui.is_point_in_rect(input.mouse_x, input.mouse_y, btn.rect) {
		// It's fine to call this each time as it will not do anything if stopwatch is already running
		time.stopwatch_start(&btn.tooltip_stopwatch)

		btn.is_hovered = true

		if input.lmb == .JUST_PRESSED || input.lmb == .PRESSED {
			btn.is_pressed = true
		} else if input.lmb == .JUST_RELEASED {
			btn.is_pressed = false
			result = true

			hide_tooltip(btn)
		}

		elapsed := time.duration_milliseconds(time.stopwatch_duration(btn.tooltip_stopwatch))
		if elapsed > 500 {
			btn.is_tooltip_visible = true
		}
	} else {
		hide_tooltip(btn)
		btn.is_hovered = false
		btn.is_pressed = false
	}

	return result
}

render_tab_button :: proc(btn: ^Tab_Button, app: ^App) {
	color := BUTTON_COLOR_NORMAL
	if btn.is_pressed {
		color = BUTTON_COLOR_PRESSED
	} else if btn.is_hovered {
		color = BUTTON_COLOR_HOVER
	}

	gui.draw_rect(app.window, btn.rect, color)

	if btn.icon != nil {
		x, y := gui.get_rect_center(btn.rect)
		gui.draw_image(
			app.window,
			btn.icon,
			x - btn.icon.width / 2,
			y - btn.icon.height / 2,
			BUTTON_ICON_COLOR,
		)
	}

	if btn.is_tooltip_visible {
		font := &app.fonts[14]
		tooltip_width, tooltip_height := gui.measure_text(font, btn.tooltip)
		tooltip_x, _ := gui.get_rect_end(btn.rect)
		_, tooltip_y := gui.get_rect_center(btn.rect)
		gui.draw_rect(
			app.window,
			gui.Rect{
				tooltip_x,
				tooltip_y,
				tooltip_width + TOOLTIP_PADDING * 2,
				tooltip_height + TOOLTIP_PADDING * 2,
			},
			TOOLTIP_BG_COLOR,
			0,
			777,
		)
		gui.draw_text(
			app.window,
			font,
			gui.Text{btn.tooltip, false},
			gui.Rect{tooltip_x + TOOLTIP_PADDING, tooltip_y + TOOLTIP_PADDING, -1, -1},
			TOOLTIP_TEXT_COLOR,
			777,
		)
	}
}

@(private = "file")
hide_tooltip :: proc(btn: ^Tab_Button) {
	time.stopwatch_reset(&btn.tooltip_stopwatch)
	btn.is_tooltip_visible = false
}
