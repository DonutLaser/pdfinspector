package app

import "../gui"

@(private = "file")
instance := Modal_Manager{}
@(private = "file")
initialized := false

Modal_Kind :: enum {
	NONE,
	METADATA,
	TEXT,
}

Modal_Manager :: struct {
	open_modal: Modal_Kind,
}

modal_manager_init :: proc() {
	if initialized {
		return
	}

	initialized = true
}

modal_manager_open_modal :: proc(kind: Modal_Kind, parent_rect: gui.Rect) {
	switch kind {
	case .NONE:
		panic("Unreachable")
	case .METADATA:
		instance.open_modal = .METADATA
		metadata_modal_show(parent_rect)
	case .TEXT:
		instance.open_modal = .TEXT
		text_modal_show(parent_rect)
	}
}

modal_manager_get_open_modal :: proc() -> Modal_Kind {
	return instance.open_modal
}

modal_manager_tick :: proc(input: ^gui.Input) {
	if instance.open_modal == .NONE {
		return
	}

	should_close := input.escape == .JUST_PRESSED || input.rmb == .JUST_PRESSED

	#partial switch instance.open_modal {
	case .METADATA:
		if should_close {
			instance.open_modal = .NONE
		} else {
			metadata_modal_tick(input)
		}
	case .TEXT:
		if should_close {
			instance.open_modal = .NONE
		} else {
			text_modal_tick(input)
		}
	}
}

modal_manager_render :: proc(app: ^App) {
	if instance.open_modal == .NONE {
		return
	}

	gui.draw_rect(app.window, gui.Rect{0, 0, app.window.width, app.window.height}, MODAL_OVERLAY_COLOR)

	#partial switch instance.open_modal {
	case .METADATA:
		metadata_modal_render(app)
	case .TEXT:
		text_modal_render(app)
	}
}
