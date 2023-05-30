package app

import "core:fmt"
import "../gui"

@(private = "file")
instance := Tabs{}
@(private = "file")
initialized := false

Tab_Kind :: enum {
	TEXT,
	METADATA,
	_COUNT,
	NONE,
}

Tabs :: struct {
	rect:    gui.Rect,
	buttons: [int(Tab_Kind._COUNT)]Tab_Button,
}

tabs_init :: proc(rect: gui.Rect) {
	if initialized {
		return
	}

	instance.rect = rect

	layout := gui.layout_new(instance.rect)

	for i := 0; i < int(Tab_Kind._COUNT); i += 1 {
		btn_rect := gui.layout_get_rect(&layout, TAB_SIZE, TAB_SIZE)
		instance.buttons[i] = tab_button_new(btn_rect)
	}

	instance.buttons[int(Tab_Kind.TEXT)].tooltip = "Text"
	instance.buttons[int(Tab_Kind.METADATA)].tooltip = "Metadata"

	initialized = true
}

tabs_set_icon :: proc(kind: Tab_Kind, icon: ^gui.Image) {
	instance.buttons[int(kind)].icon = icon
}

tabs_resize :: proc(rect: gui.Rect) {
	instance.rect = rect
	layout := gui.layout_new(rect)

	for i := 0; i < int(Tab_Kind._COUNT); i += 1 {
		instance.buttons[i].rect = gui.layout_get_rect(&layout, TAB_SIZE, TAB_SIZE)
	}
}

tabs_tick :: proc(input: ^gui.Input) -> Tab_Kind {
	for i := 0; i < int(Tab_Kind._COUNT); i += 1 {
		if tab_button_tick(&instance.buttons[i], input) {
			return Tab_Kind(i)
		}
	}

	return .NONE
}

tabs_render :: proc(app: ^App) {
	gui.draw_rect(app.window, instance.rect, TABS_BG_COLOR)

	for i := 0; i < int(Tab_Kind._COUNT); i += 1 {
		tab_button_render(&instance.buttons[i], app)
	}
}
