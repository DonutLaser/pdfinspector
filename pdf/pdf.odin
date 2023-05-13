package pdf

import "core:strings"
import "core:mem"
import "core:fmt"
import "../libs/pdfium"

Document :: struct {
	data:       ^pdfium.DOCUMENT,
	page_count: i32,
}

init :: proc() {
	config := pdfium.LIBRARY_CONFIG {
		version          = 2,
		m_pUserFontPaths = nil,
		m_pIsolate       = nil,
		m_v8EmbedderSlot = 0,
	}

	pdfium.init_library_with_config(&config)
}

deinit :: proc() {
	pdfium.destroy_library()
}

open_document :: proc(file_path: string) -> (Document, bool) {
	path := strings.clone_to_cstring(file_path)
	defer delete_cstring(path)

	data := pdfium.load_document(path, "")
	if data == nil {
		err := pdfium.get_last_error()
		err_str := ""

		switch err {
		case pdfium.ERR_UNKNOWN:
			fmt.eprintln("Error: uknown error.")
		case pdfium.ERR_FILE:
			fmt.eprintln("Error: file cannot be opened.")
		case pdfium.ERR_FORMAT:
			fmt.eprintln("Error: file is not a PDF")
		case pdfium.ERR_PASSWORD:
			fmt.eprintln("Error: incorrect password")
		case pdfium.ERR_SECURITY:
			fmt.eprintln("Error: unsupported security scheme")
		case:
			fmt.eprintln("Error: unknown error")
		}

		return Document{}, false
	}

	result := Document {
		data       = data,
		page_count = pdfium.get_page_count(data),
	}

	return result, true
}

close_document :: proc(doc: Document) {
	pdfium.close_document(doc.data)
}
