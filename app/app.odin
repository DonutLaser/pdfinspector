package app

import "core:fmt"
import "../gui"
import "../pdf"

@(private = "file")
Image_To_Load :: struct {
	path: cstring,
	name: string,
}

@(private = "file")
Font_To_Load :: struct {
	path: cstring,
	size: i32,
}

App :: struct {
	window:        ^gui.Window,
	pdf_doc:       pdf.Document,
	tabs:          Tabs,
	structure:     Structure,
	document_view: Document_View,
	modal_manager: Modal_Manager,
	icons:         map[string]gui.Image,
	fonts:         map[i32]gui.Font,
}

create_app :: proc(window: ^gui.Window, pdf_file_path: string) -> (App, bool) {
	pdf.init()

	pdf_doc, pdf_ok := pdf.open_document(pdf_file_path)
	if !pdf_ok {
		return App{}, false
	}

	result := App {
		window        = window,
		pdf_doc       = pdf_doc,
		tabs          = create_tabs(gui.Rect{0, 0, TABS_WIDTH, window.height}),
		structure     = create_structure(gui.Rect{TABS_WIDTH, 0, STRUCTURE_WIDTH, window.height}),
		document_view = create_document_view(
			gui.Rect{
				TABS_WIDTH + STRUCTURE_WIDTH,
				0,
				window.width - TABS_WIDTH - STRUCTURE_WIDTH,
				window.height,
			},
			pdf_doc.page_count,
		),
		modal_manager = create_modal_manager(gui.Rect{0, 0, window.width, window.height}),
		icons         = make(map[string]gui.Image),
		fonts         = make(map[i32]gui.Font),
	}

	// Load icons
	images_to_load := []Image_To_Load{
		Image_To_Load{"./assets/icons/text.png", "text.png"},
		Image_To_Load{"./assets/icons/metadata.png", "metadata.png"},
	}
	for image in images_to_load {
		icon, ok := gui.load_image(image.path, window)
		if !ok {return App{}, false}
		result.icons[image.name] = icon
	}

	// Load fonts
	fonts_to_load := []Font_To_Load{Font_To_Load{"./assets/fonts/consola.ttf", 14}}
	for f in fonts_to_load {
		font, ok := gui.load_font(f.path, f.size)
		if !ok {return App{}, false}
		result.fonts[f.size] = font
	}

	set_text_icon(&result.tabs, &result.icons["text.png"])
	set_metadata_icon(&result.tabs, &result.icons["metadata.png"])

	// Load pdf metadata
	metadata_modal := &result.modal_manager.metadata_modal
	metadata := pdf.get_doc_metadata(result.pdf_doc)
	defer pdf.free_doc_metadata(&metadata)
	add_metadata_field(metadata_modal, "Title", metadata.title, &result)
	add_metadata_field(metadata_modal, "Author", metadata.author, &result)
	add_metadata_field(metadata_modal, "Subject", metadata.subject, &result)
	add_metadata_field(metadata_modal, "Keywords", metadata.keywords, &result)
	add_metadata_field(metadata_modal, "Creator", metadata.creator, &result)
	add_metadata_field(metadata_modal, "Producer", metadata.producer, &result)
	add_metadata_field(metadata_modal, "CreationDate", metadata.creation_date, &result)
	add_metadata_field(metadata_modal, "ModDate", metadata.mod_date, &result)

	// Load pdf text
	text_modal := &result.modal_manager.text_modal
	pdf_text := pdf.get_all_text_in_doc(result.pdf_doc)
	defer pdf.free_text(&pdf_text)
	img, img_ok := gui.image_from_pdf_text(pdf_text, &result.fonts[14], TEXT_MODAL_WIDTH, window)
	if !img_ok {
		return App{}, false
	}
	text_modal.text = img

	// Load pdf page bitmaps
	for i: i32 = 0; i < result.pdf_doc.page_count; i += 1 {
		bitmap, bitmap_ok := pdf.get_page_bitmap(result.pdf_doc, i)
		if !bitmap_ok {return App{}, false}

		image, image_ok := gui.image_from_pdf_bitmap(bitmap, window)
		if !image_ok {return App{}, false}

		setup_document_view_page(&result.document_view, i, image)
	}

	return result, true
}

destroy_app :: proc(app: ^App) {
	pdf.close_document(app.pdf_doc)
	pdf.deinit()
}

resize_app :: proc(app: ^App) {
	// At this point, the window that we have a reference to should have the new sizes already set
	resize_tabs(&app.tabs, app.window.height)
	resize_structure(&app.structure, app.window.height)
	resize_document_view(
		&app.document_view,
		gui.Rect{
			TABS_WIDTH + STRUCTURE_WIDTH,
			0,
			app.window.width - TABS_WIDTH - STRUCTURE_WIDTH,
			app.window.height,
		},
	)
	resize_modals(&app.modal_manager, app.window.width / 2, app.window.height / 2)
}

tick :: proc(app: ^App, input: ^gui.Input) {
	if app.modal_manager.open_modal == .NONE {
		clicked_tab := tick_tabs(&app.tabs, app, input)
		#partial switch clicked_tab {
		case .METADATA:
			open_modal(&app.modal_manager, .METADATA)
		case .TEXT:
			open_modal(&app.modal_manager, .TEXT)
		}
	}

	tick_modal_manager(&app.modal_manager, input)
}

render :: proc(app: ^App) {
	render_tabs(&app.tabs, app)
	render_structure(&app.structure, app)
	render_document_view(&app.document_view, app)

	render_modal_manager(&app.modal_manager, app)
}
