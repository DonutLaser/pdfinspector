package pdf

import "core:strings"
import "core:mem"
import "../libs/pdfium"

Metadata :: struct {
	page_count:    u16,
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
	result.page_count = cast(u16)doc.page_count
	result.title = get_metadata_tag_value(doc.data, "Title")
	result.author = get_metadata_tag_value(doc.data, "Author")
	result.subject = get_metadata_tag_value(doc.data, "Subject")
	result.keywords = get_metadata_tag_value(doc.data, "Keywords")
	result.creator = get_metadata_tag_value(doc.data, "Creator")
	result.producer = get_metadata_tag_value(doc.data, "Producer")
	result.creation_date = get_metadata_tag_value(doc.data, "CreationDate") // TODO: Parse into an ISO string for better readability
	result.mod_date = get_metadata_tag_value(doc.data, "ModDate") // TODO: Parse into an ISO string for better readability

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

	buffer := mem.alloc(cast(int)len)
	_ = pdfium.get_meta_text(doc, tag, cast(rawptr)buffer, len)

	return strings.clone_from_ptr(cast(^byte)buffer, cast(int)len)
}
