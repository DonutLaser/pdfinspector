package pdf

import "core:strings"
import "core:fmt"
import "core:mem"
import "core:unicode/utf16"
import "../libs/pdfium"

get_all_text_in_doc :: proc(doc: Document) -> string {
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
	result_pages := make([dynamic]string, doc.page_count)
	for text_page, index in text_pages {
		len := text_lengths[index]

		// TODO: figure out how to get utf-8 text and print it in utf-8
		buffer := make([^]u16, len)
		defer mem.free(bytes)
		pdfium.text_get_text(text_page, 0, len, buffer)

		// TODO: there has to be a better way to do this
		bytes := make([^]u8, len)
		defer mem.free(buffer)
		utf16.decode_to_utf8(bytes[:len], buffer[:len])
		result_pages[index] = strings.clone_from_bytes(bytes[:len])
	}

	result := strings.join(result_pages[:], "\n")

	for text_page in text_pages {
		pdfium.text_close_page(text_page)
	}

	return result
}

free_text :: proc(text: string) {
	delete(text)
}
