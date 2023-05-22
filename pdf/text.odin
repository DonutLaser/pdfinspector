package pdf

import "core:strings"
import "core:mem"
import "core:unicode/utf16"
import "../libs/pdfium"

Pdf_Text :: struct {
	data: [^]u16,
	size: i32,
}

get_all_text_in_doc :: proc(doc: Document) -> Pdf_Text {
	// We first figure out the total length of text in the document...
	text_pages := make([dynamic]^pdfium.TEXTPAGE, doc.page_count)
	defer delete(text_pages)
	text_lengths := make([dynamic]i32, doc.page_count)
	defer delete(text_lengths)

	total_len: i32 = 0
	for i: i32 = 0; i < doc.page_count; i += 1 {
		page := pdfium.load_page(doc.data, i)
		defer pdfium.close_page(page)

		text_pages[i] = pdfium.text_load_page(page)
		text_lengths[i] = pdfium.text_count_chars(text_pages[i])

		total_len += text_lengths[i]
	}

	// ... and then we actually load the text for each page. That's why we collected the text pages...
	result := make([^]u16, total_len)
	start: i32 = 0
	for text_page, index in text_pages {
		len := text_lengths[index]

		buffer := make([^]u16, len)
		defer mem.free(buffer)
		pdfium.text_get_text(text_page, 0, len, buffer)

		for i: i32 = start; i < len; i += 1 {
			result[i] = buffer[i]
		}

		start += len
	}

	return Pdf_Text{data = result, size = total_len}
}

free_text :: proc(text: ^Pdf_Text) {
	mem.free(text.data)
}
