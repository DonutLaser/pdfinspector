package app

import "core:fmt"
import "../gui"

Clicked_Tab :: enum {
	STRUCTURE,
	TEXT,
	METADATA,
	NONE,
}

Tabs :: struct {
	text_button:     Tab_Button,
	metadata_button: Tab_Button,
}

create_tabs :: proc() -> Tabs {
	result := Tabs {
		text_button     = create_tab_button(
			0,
			TAB_BUTTON_HEIGHT * 0,
			TABS_WIDTH,
			TAB_BUTTON_HEIGHT,
		),
		metadata_button = create_tab_button(
			0,
			TAB_BUTTON_HEIGHT * 1,
			TABS_WIDTH,
			TAB_BUTTON_HEIGHT,
		),
	}

	result.text_button.tooltip = "Text"
	result.metadata_button.tooltip = "Metadata"

	return result
}

set_text_icon :: proc(tabs: ^Tabs, icon: ^gui.Image) {
	tabs.text_button.icon = icon
}

set_metadata_icon :: proc(tabs: ^Tabs, icon: ^gui.Image) {
	tabs.metadata_button.icon = icon
}

tick_tabs :: proc(tabs: ^Tabs, app: ^App, input: ^gui.Input) -> Clicked_Tab {
	if tick_tab_button(&tabs.text_button, input) {
		return .TEXT
	}

	if tick_tab_button(&tabs.metadata_button, input) {
		return .METADATA
	}

	return .NONE
}

render_tabs :: proc(tabs: ^Tabs, app: ^App) {
	gui.draw_rect(app.window, 0, 0, TABS_WIDTH, app.window.height, TABS_BG_COLOR)

	render_tab_button(&tabs.text_button, app)
	render_tab_button(&tabs.metadata_button, app)
}
