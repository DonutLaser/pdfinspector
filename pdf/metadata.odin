package pdf

import "core:strings"
import "core:mem"
import "core:fmt"
import "core:unicode/utf16"
import "../libs/pdfium"

Metadata :: struct {
	title:         cstring,
	author:        cstring,
	subject:       cstring,
	keywords:      cstring,
	creator:       cstring,
	producer:      cstring,
	creation_date: cstring,
	mod_date:      cstring,
}

get_doc_metadata :: proc(doc: Document) -> (result: Metadata) {
	result.title = get_metadata_tag_value(doc.data, "Title")
	result.author = get_metadata_tag_value(doc.data, "Author")
	result.subject = get_metadata_tag_value(doc.data, "Subject")
	result.keywords = get_metadata_tag_value(doc.data, "Keywords")
	result.creator = get_metadata_tag_value(doc.data, "Creator")
	result.producer = get_metadata_tag_value(doc.data, "Producer")

	creation_date := get_metadata_tag_value(doc.data, "CreationDate")
	if len(creation_date) != 0 {
		result.creation_date = parse_date(creation_date)
		delete(creation_date)
	} else {
		result.creation_date = creation_date
	}

	mod_date := get_metadata_tag_value(doc.data, "ModDate")
	if len(mod_date) != 0 {
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
get_metadata_tag_value :: proc(doc: ^pdfium.DOCUMENT, tag: cstring) -> cstring {
	len := pdfium.get_meta_text(doc, tag, nil, 0)

	src := make([^]u16, len)
	defer mem.free(src)
	_ = pdfium.get_meta_text(doc, tag, cast(rawptr)src, len)

	dest := make([^]u8, len)
	defer mem.free(dest)
	utf16.decode_to_utf8(dest[:len], src[:len])

	str := strings.clone_from_ptr(cast(^byte)dest, int(len))
	defer delete(str)

	return strings.clone_to_cstring(str)
}

@(private = "file")
parse_date :: proc(str: cstring) -> cstring {
	value := strings.clone_from_cstring(str)
	defer delete(value)

	return fmt.caprintf(
		"%s-%s-%s %s:%s:%s",
		value[2:6],
		value[6:8],
		value[8:10],
		value[10:12],
		value[12:14],
		value[14:16],
	)
}
