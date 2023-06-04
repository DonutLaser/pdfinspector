package app

import "core:fmt"
import "../gui"
import "../pdf"

App :: struct {
	window:       ^gui.Window,
	pdf_doc:      pdf.Document,
	pdf_metadata: pdf.Metadata,
}

app_new :: proc(window: ^gui.Window, pdf_file_path: string) -> (App, bool) {
	pdf.init()

	pdf_doc, pdf_ok := pdf.open_document(pdf_file_path)
	if !pdf_ok {
		return App{}, false
	}

	result := App {
		window  = window,
		pdf_doc = pdf_doc,
	}

	assets_init(result.window)

	layout := gui.layout_new(gui.Rect{0, 0, result.window.width, result.window.height})
	layout.state = .HORIZONTAL

	// Init tabs
	tabs_init(gui.layout_get_rect(&layout, TAB_SIZE, -1))
	tabs_set_icon(.TEXT, assets_get_image("text.png"))
	tabs_set_icon(.METADATA, assets_get_image("metadata.png"))

	structure_layout := gui.layout_new(
		gui.layout_get_rect(&layout, STRUCTURE_WIDTH, result.window.height),
	)

	// Init structure
	structure_init(
		gui.layout_get_rect(
			&structure_layout,
			-1,
			i32(f32(result.window.height) * STRUCTURE_HEIGHT),
		),
	)
	pdf_structure := pdf.get_document_structure(result.pdf_doc)
	defer pdf.free_document_structure(pdf_structure)
	structure_setup(pdf_structure)

	object_info_init(
		gui.layout_get_rect(
			&structure_layout,
			-1,
			i32(f32(result.window.height) * OBJECT_INFO_HEIGHT),
		),
	)

	// Init document view
	document_view_init(gui.layout_get_rect(&layout, -1, -1))
	for i: i32 = 0; i < result.pdf_doc.page_count; i += 1 {
		bitmap, bitmap_ok := pdf.get_page_bitmap(result.pdf_doc, i)
		if !bitmap_ok {return App{}, false}

		image, image_ok := gui.image_from_pdf_bitmap(bitmap, result.window)
		if !image_ok {return App{}, false}

		document_view_add_page(image)
	}

	// Init metadata modal
	result.pdf_metadata = pdf.get_doc_metadata(result.pdf_doc)
	metadata_modal_add_field("Title", result.pdf_metadata.title)
	metadata_modal_add_field("Author", result.pdf_metadata.author)
	metadata_modal_add_field("Subject", result.pdf_metadata.subject)
	metadata_modal_add_field("Keywords", result.pdf_metadata.keywords)
	metadata_modal_add_field("Creator", result.pdf_metadata.creator)
	metadata_modal_add_field("Producer", result.pdf_metadata.producer)
	metadata_modal_add_field("Creation date", result.pdf_metadata.creation_date)
	metadata_modal_add_field("Modification date", result.pdf_metadata.mod_date)

	// Init text modal
	pdf_text := pdf.get_all_text_in_doc(result.pdf_doc)
	defer pdf.free_text(&pdf_text)
	if pdf_text.size > 0 {
		img, img_ok := gui.image_from_pdf_text(
			pdf_text,
			assets_get_font_at_size(14),
			TEXT_MODAL_SIZE - TEXT_MODAL_PADDING * 2 - SCROLLBAR_SIZE,
			window,
		)
		if !img_ok {
			return App{}, false
		}

		text_modal_set_text(img)
	}

	return result, true
}

app_destroy :: proc(app: ^App) {
	structure_deinit()
	document_view_deinit()

	pdf.free_doc_metadata(&app.pdf_metadata)
	pdf.close_document(app.pdf_doc)
	pdf.deinit()
}

app_resize :: proc(app: ^App) {
	// At this point, the window that we have a reference to should have the new sizes already set
	layout := gui.layout_new(gui.Rect{0, 0, app.window.width, app.window.height})
	layout.state = .HORIZONTAL

	tabs_resize(gui.layout_get_rect(&layout, TAB_SIZE, -1))

	structure_layout := gui.layout_new(
		gui.layout_get_rect(&layout, STRUCTURE_WIDTH, app.window.height),
	)
	structure_resize(
		gui.layout_get_rect(&structure_layout, -1, i32(f32(app.window.height) * STRUCTURE_HEIGHT)),
	)
	object_info_resize(
		gui.layout_get_rect(
			&structure_layout,
			-1,
			i32(f32(app.window.height) * OBJECT_INFO_HEIGHT),
		),
	)
	document_view_resize(gui.layout_get_rect(&layout, -1, -1))
}

app_tick :: proc(app: ^App, input: ^gui.Input) {
	if modal_manager_get_open_modal() != .NONE {
		modal_manager_tick(input)
		return
	}

	clicked_tab := tabs_tick(input)
	#partial switch clicked_tab {
	case .METADATA:
		modal_manager_open_modal(.METADATA, gui.Rect{0, 0, app.window.width, app.window.height})
	case .TEXT:
		modal_manager_open_modal(.TEXT, gui.Rect{0, 0, app.window.width, app.window.height})
	}

	structure_tick(input)
	object_info_tick(input)
}

app_render :: proc(app: ^App) {
	tabs_render(app)
	structure_render(app)
	object_info_render(app)
	document_view_render(app)

	modal_manager_render(app)
}
