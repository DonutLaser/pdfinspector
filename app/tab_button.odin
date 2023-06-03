package app

import "core:time"
import "core:fmt"
import "core:strings"
import "../gui"

Tab_Button :: struct {
	rect:              gui.Rect,
	is_hovered:        bool,
	is_pressed:        bool,
	icon:              ^gui.Image,
	tooltip:           Tooltip,
	tooltip_stopwatch: time.Stopwatch,
}

tab_button_new :: proc(rect: gui.Rect) -> Tab_Button {
	return(
		{
			rect = rect,
			is_hovered = false,
			is_pressed = false,
			icon = nil,
			tooltip = tooltip_new(),
		} \
	)
}

tab_button_tick :: proc(btn: ^Tab_Button, input: ^gui.Input) -> bool {
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
			tooltip_x, _ := gui.get_rect_end(btn.rect)
			_, tooltip_y := gui.get_rect_center(btn.rect)

			tooltip_show_at(&btn.tooltip, tooltip_x, tooltip_y)
		}
	} else {
		hide_tooltip(btn)
		btn.is_hovered = false
		btn.is_pressed = false
	}

	return result
}

tab_button_render :: proc(btn: ^Tab_Button, app: ^App) {
	color := TAB_COLOR_NORMAL
	if btn.is_pressed {
		color = TAB_COLOR_PRESSED
	} else if btn.is_hovered {
		color = TAB_COLOR_HOVER
	}

	gui.draw_rect(app.window, btn.rect, color)

	if btn.icon != nil {
		x, y := gui.get_rect_center(btn.rect)
		gui.draw_image(
			app.window,
			btn.icon,
			x - btn.icon.width / 2,
			y - btn.icon.height / 2,
			TAB_ICON_COLOR,
		)
	}

	tooltip_render(&btn.tooltip, app)
}

@(private = "file")
hide_tooltip :: proc(btn: ^Tab_Button) {
	time.stopwatch_reset(&btn.tooltip_stopwatch)
	tooltip_hide(&btn.tooltip)
}
