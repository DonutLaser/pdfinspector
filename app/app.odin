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
	window:         ^gui.Window,
	pdf_doc:        pdf.Document,
	tabs:           Tabs,
	structure:      Structure,
	document_view:  Document_View,
	metadata_modal: Metadata_Modal,
	icons:          map[string]gui.Image,
	fonts:          map[i32]gui.Font,
}

create_app :: proc(window: ^gui.Window, pdf_file_path: string) -> (App, bool) {
	pdf.init()

	pdf_doc, pdf_ok := pdf.open_document(pdf_file_path)
	if !pdf_ok {
		return App{}, false
	}

	result := App {
		window         = window,
		pdf_doc        = pdf_doc,
		tabs           = create_tabs(),
		structure      = create_structure(),
		document_view  = create_document_view(pdf_doc.page_count),
		metadata_modal = create_metadata_modal(),
		icons          = make(map[string]gui.Image),
		fonts          = make(map[i32]gui.Font),
	}

	images_to_load := []Image_To_Load{
		Image_To_Load{"./assets/icons/text.png", "text.png"},
		Image_To_Load{"./assets/icons/metadata.png", "metadata.png"},
	}
	for image in images_to_load {
		icon, ok := gui.load_image(image.path, window)
		if !ok {return App{}, false}
		result.icons[image.name] = icon
	}

	fonts_to_load := []Font_To_Load{Font_To_Load{"./assets/fonts/consola.ttf", 14}}
	for f in fonts_to_load {
		font, ok := gui.load_font(f.path, f.size)
		if !ok {return App{}, false}
		result.fonts[f.size] = font
	}

	set_text_icon(&result.tabs, &result.icons["text.png"])
	set_metadata_icon(&result.tabs, &result.icons["metadata.png"])

	metadata := pdf.get_doc_metadata(result.pdf_doc)
	add_metadata_field(&result.metadata_modal, "Title", metadata.title)
	add_metadata_field(&result.metadata_modal, "Author", metadata.author)
	add_metadata_field(&result.metadata_modal, "Subject", metadata.subject)
	add_metadata_field(&result.metadata_modal, "Keywords", metadata.keywords)
	add_metadata_field(&result.metadata_modal, "Creator", metadata.creator)
	add_metadata_field(&result.metadata_modal, "Producer", metadata.producer)
	add_metadata_field(&result.metadata_modal, "CreationDate", metadata.creation_date)
	add_metadata_field(&result.metadata_modal, "ModDate", metadata.mod_date)

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

tick :: proc(app: ^App, input: ^gui.Input) {
	// TODO: figure out a better way for the modal to consume all input
	if !app.metadata_modal.is_visible {
		clicked_tab := tick_tabs(&app.tabs, app, input)
		#partial switch clicked_tab {
		case .METADATA:
			app.metadata_modal.is_visible = true
		}
	}

	tick_metadata_modal(&app.metadata_modal, input)
}

render :: proc(app: ^App) {
	render_tabs(&app.tabs, app)
	render_structure(&app.structure, app)
	render_document_view(&app.document_view, app)

	render_metadata_modal(&app.metadata_modal, app)
}
