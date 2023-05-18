package pdf

import "core:strings"
import "core:mem"
import "core:fmt"
import "core:unicode/utf16"
import "../libs/pdfium"

Metadata :: struct {
	title:         string,
	author:        string,
	subject:       string,
	keywords:      string,
	creator:       string,
	producer:      string,
	creation_date: string,
	mod_date:      string,
}

get_doc_metadata :: proc(doc: Document) -> (result: Metadata) {
	result.title = get_metadata_tag_value(doc.data, "Title")
	result.author = get_metadata_tag_value(doc.data, "Author")
	result.subject = get_metadata_tag_value(doc.data, "Subject")
	result.keywords = get_metadata_tag_value(doc.data, "Keywords")
	result.creator = get_metadata_tag_value(doc.data, "Creator")
	result.producer = get_metadata_tag_value(doc.data, "Producer")

	creation_date := get_metadata_tag_value(doc.data, "CreationDate")
	if len(creation_date) != 2 {
		result.creation_date = parse_date(creation_date)
		delete(creation_date)
	} else {
		result.creation_date = creation_date
	}

	mod_date := get_metadata_tag_value(doc.data, "ModDate")
	if len(mod_date) != 2 {
		result.mod_date = parse_date(mod_date)
		delete(mod_date)
	} else {
		result.mod_date = mod_date
	}

	return
}

free_doc_metadata :: proc(metadata: ^Metadata) {
	delete(metadata.title)
	delete(metadata.author)
	delete(metadata.subject)
	delete(metadata.keywords)
	delete(metadata.creator)
	delete(metadata.producer)
	delete(metadata.creation_date)
	delete(metadata.mod_date)
}

@(private)
get_metadata_tag_value :: proc(doc: ^pdfium.DOCUMENT, tag: cstring) -> string {
	len := pdfium.get_meta_text(doc, tag, nil, 0)

	src := make([^]u16, len)
	defer mem.free(src)
	_ = pdfium.get_meta_text(doc, tag, cast(rawptr)src, len)

	dest := make([^]u8, len)
	defer mem.free(dest)
	utf16.decode_to_utf8(dest[:len], src[:len])

	return strings.clone_from_ptr(cast(^byte)dest, int(len))
}

@(private = "file")
parse_date :: proc(str: string) -> string {
	return fmt.aprintf(
		"%s-%s-%s %s:%s:%s",
		str[2:6],
		str[6:8],
		str[8:10],
		str[10:12],
		str[12:14],
		str[14:16],
	)
}
