package app

import "../gui"

Modal_Kind :: enum {
	NONE,
	METADATA,
	TEXT,
}

Modal_Manager :: struct {
	metadata_modal: Metadata_Modal,
	text_modal:     Text_Modal,
	open_modal:     Modal_Kind,
}

create_modal_manager :: proc() -> Modal_Manager {
	result := Modal_Manager {
		metadata_modal = create_metadata_modal(),
	}

	return result
}

open_modal :: proc(mm: ^Modal_Manager, kind: Modal_Kind) {
	switch kind {
	case .NONE:
		panic("Unreachable")
	case .METADATA:
		mm.metadata_modal.is_visible = true
		mm.open_modal = .METADATA
	case .TEXT:
		mm.text_modal.is_visible = true
		mm.open_modal = .TEXT
	}
}

tick_modal_manager :: proc(mm: ^Modal_Manager, input: ^gui.Input) {
	if mm.open_modal == .NONE {
		return
	}

	should_close := input.escape == .JUST_PRESSED || input.rmb == .JUST_PRESSED

	#partial switch mm.open_modal {
	case .METADATA:
		if should_close {
			mm.metadata_modal.is_visible = false
			mm.open_modal = .NONE
		} else {
			tick_metadata_modal(&mm.metadata_modal, input)
		}
	case .TEXT:
		if should_close {
			mm.text_modal.is_visible = false
			mm.open_modal = .NONE
		} else {
			tick_text_modal(&mm.text_modal, input)
		}
	}
}

render_modal_manager :: proc(mm: ^Modal_Manager, app: ^App) {
	if mm.open_modal == .NONE {
		return
	}

	#partial switch mm.open_modal {
	case .METADATA:
		render_metadata_modal(&mm.metadata_modal, app)
	case .TEXT:
		render_text_modal(&mm.text_modal, app)
	}
}
