package pdf

import "core:c"
import "core:mem"
import "core:unicode/utf16"
import "core:strings"
import "../libs/pdfium"

Object_Kind :: enum {
	TEXT,
	PATH,
	IMAGE,
	SHADING,
	FORM,
	UKNOWN,
}

Text_Render_Mode :: enum {
	UNKNOWN,
	FILL,
	STROKE,
	FILL_STROKE,
	INVISIBLE,
	FILL_CLIP,
	STROKE_CLIP,
	FILL_STROKE_CLIP,
	CLIP,
}

text_render_mode_to_string :: proc(mode: Text_Render_Mode) -> cstring {
	switch mode {
	case .UNKNOWN:
		return "uknown"
	case .FILL:
		return "fill"
	case .STROKE:
		return "stroke"
	case .FILL_STROKE:
		return "fill stroke"
	case .INVISIBLE:
		return "invisible"
	case .FILL_CLIP:
		return "fill clip"
	case .STROKE_CLIP:
		return "stroke clip"
	case .FILL_STROKE_CLIP:
		return "fill stroke clip"
	case .CLIP:
		return "clip"
	case:
		return ""
	}
}

Page :: struct {
	objects:     [dynamic]Object,
	annotations: [dynamic]Annotation,
}

Object :: struct {
	kind: Object_Kind,
	data: union {
		Text_Object,
		Path_Object,
		Image_Object,
	},
}

Text_Object :: struct {
	mode: Text_Render_Mode,
	text: cstring,
	size: f32,
	font: Font,
}

Path_Object :: struct {}

Image_Object :: struct {
	width:             u32,
	height:            u32,
	hdpi:              f32,
	vdpi:              f32,
	bpp:               u32,
	colorspace:        i32,
	marked_content_id: i32,
}

colorspace_to_string :: proc(colorspace: i32) -> cstring {
	switch colorspace {
	case pdfium.COLORSPACE_UNKNOWN:
		return "Unknown"
	case pdfium.COLORSPACE_DEVICEGRAY:
		return "Device Gray"
	case pdfium.COLORSPACE_DEVICERGB:
		return "Device RGB"
	case pdfium.COLORSPACE_DEVICECMYK:
		return "Device CMYK"
	case pdfium.COLORSPACE_CALGRAY:
		return "Device CalGray"
	case pdfium.COLORSPACE_CALRGB:
		return "Device CalRGB"
	case pdfium.COLORSPACE_LAB:
		return "Device LAB"
	case pdfium.COLORSPACE_ICCBASED:
		return "Device ICC based"
	case pdfium.COLORSPACE_SEPARATION:
		return "Device Separation"
	case pdfium.COLORSPACE_DEVICEN:
		return "Device En"
	case pdfium.COLORSPACE_INDEXED:
		return "Indexed"
	case pdfium.COLORSPACE_PATTERN:
		return "Pattern"
	case:
		return ""
	}
}

Annotation :: struct {}

Font :: struct {
	name:           cstring,
	is_fixed_pitch: bool,
	is_serif:       bool,
	is_symbolic:    bool,
	is_script:      bool,
	is_italic:      bool,
	is_all_caps:    bool,
	is_small_caps:  bool,
	is_forced_bold: bool,
	is_embedded:    bool,
	weight:         i32,
	ascent:         f32,
	descent:        f32,
}

get_document_structure :: proc(doc: Document) -> [dynamic]Page {
	result := make([dynamic]Page, doc.page_count)
	for i: i32 = 0; i < doc.page_count; i += 1 {
		page := pdfium.load_page(doc.data, i)
		defer pdfium.close_page(page)

		text_page := pdfium.text_load_page(page)
		defer pdfium.text_close_page(text_page)

		obj_count := pdfium.page_count_objects(page)

		result[i] = Page {
			objects = make([dynamic]Object, obj_count),
		}

		for j: i32 = 0; j < obj_count; j += 1 {
			obj := Object{}

			pdf_obj := pdfium.page_get_object(page, j)
			pdf_obj_type := pdfium.pageobj_get_type(pdf_obj)

			obj.kind = pageobj_type_to_object_kind(pdf_obj_type)

			#partial switch obj.kind {
			case .TEXT:
				obj.data = extract_text_object_data(text_page, pdf_obj)
			case .PATH:
			// TODO: extract path object data
			case .IMAGE:
				obj.data = extract_image_object_data(page, pdf_obj)
			}

			result[i].objects[j] = obj
		}
	}

	return result
}

free_document_structure :: proc(structure: [dynamic]Page) {
	for page in structure {
		for obj in page.objects {
			// TODO
			#partial switch obj.kind {
			case .TEXT:
				free_text_object_data(obj.data.(Text_Object))
			}
		}

		delete(page.objects)
	}

	delete(structure)
}


@(private = "file")
extract_text_object_data :: proc(
	text_page: ^pdfium.TEXTPAGE,
	text_obj: ^pdfium.PAGEOBJECT,
) -> Text_Object {
	result := Text_Object{}

	mode := pdfium.textobj_get_text_render_mode(text_obj)
	result.mode = pdfium_text_render_mode_to_text_render_mode(mode)

	len := pdfium.text_count_chars(text_page)

	// TODO: figure out how to get utf-8 text and print it in utf-8
	buffer := make([^]u16, len)
	pdfium.textobj_get_text(text_obj, text_page, buffer, cast(u32)len)

	bytes := make([^]u8, len)
	utf16.decode_to_utf8(bytes[:len], buffer[:len])
	str := strings.clone_from_bytes(bytes[:len])
	defer delete(str)
	result.text = strings.clone_to_cstring(str)

	pdfium.textobj_get_font_size(text_obj, &result.size)

	result.font = extract_font_data(text_obj, result.size)

	mem.free(bytes)
	mem.free(buffer)

	return result
}

@(private = "file")
extract_image_object_data :: proc(
	page: ^pdfium.PAGE,
	image_obj: ^pdfium.PAGEOBJECT,
) -> Image_Object {
	result := Image_Object{}

	data: pdfium.IMAGEOBJ_METADATA = pdfium.IMAGEOBJ_METADATA{}
	pdfium.imageobj_get_image_metadata(image_obj, page, &data)

	result.width = data.width
	result.height = data.height
	result.hdpi = data.horizontal_dpi
	result.vdpi = data.vertical_dpi
	result.bpp = data.bits_per_pixel
	result.colorspace = data.colorspace
	result.marked_content_id = data.marked_content_id

	return result
}

@(private = "file")
extract_font_data :: proc(text_obj: ^pdfium.PAGEOBJECT, size: f32) -> Font {
	result := Font{}

	font_data := pdfium.textobj_get_font(text_obj)

	flags := pdfium.font_get_flags(font_data)
	result.is_fixed_pitch = flags & (1 << 0) == 1
	result.is_serif = flags & (1 << 1) == 1
	result.is_symbolic = flags & (1 << 2) == 1
	result.is_script = flags & (1 << 3) == 1
	result.is_symbolic = flags & (1 << 5) != 1
	result.is_italic = flags & (1 << 6) == 1
	result.is_all_caps = flags & (1 << 16) == 1
	result.is_small_caps = flags & (1 << 17) == 1
	result.is_forced_bold = flags & (1 << 18) == 1
	result.is_embedded = pdfium.font_get_is_embedded(font_data) == 1
	result.weight = pdfium.font_get_weight(font_data)
	pdfium.font_get_ascent(font_data, size, &result.ascent)
	pdfium.font_get_descent(font_data, size, &result.descent)

	len := pdfium.font_get_font_name(font_data, nil, 0)
	buffer := make([^]byte, len)
	pdfium.font_get_font_name(font_data, buffer, len)
	str := strings.clone_from_bytes(buffer[:len])
	defer delete(str)
	result.name = strings.clone_to_cstring(str)

	return result
}

@(private = "file")
free_text_object_data :: proc(text_obj: Text_Object) {
	delete(text_obj.text)
}

@(private = "file")
free_font_data :: proc(font: Font) {
	delete(font.name)
}

@(private = "file")
pageobj_type_to_object_kind :: proc(t: c.int) -> Object_Kind {
	switch t {
	case pdfium.PAGEOBJ_UNKNOWN:
		return .UKNOWN
	case pdfium.PAGEOBJ_TEXT:
		return .TEXT
	case pdfium.PAGEOBJ_PATH:
		return .PATH
	case pdfium.PAGEOBJ_IMAGE:
		return .IMAGE
	case pdfium.PAGEOBJ_SHADING:
		return .SHADING
	case pdfium.PAGEOBJ_FORM:
		return .FORM
	case:
		panic("Unreachable")
	}
}

@(private = "file")
pdfium_text_render_mode_to_text_render_mode :: proc(
	mode: pdfium.TEXT_RENDERMODE,
) -> Text_Render_Mode {
	#partial switch mode {
	case pdfium.TEXT_RENDERMODE.UNKNOWN:
		return .UNKNOWN
	case pdfium.TEXT_RENDERMODE.FILL:
		return .FILL
	case pdfium.TEXT_RENDERMODE.STROKE:
		return .STROKE
	case pdfium.TEXT_RENDERMODE.FILL_STROKE:
		return .FILL_STROKE
	case pdfium.TEXT_RENDERMODE.INVISIBLE:
		return .INVISIBLE
	case pdfium.TEXT_RENDERMODE.FILL_CLIP:
		return .FILL_CLIP
	case pdfium.TEXT_RENDERMODE.STROKE_CLIP:
		return .STROKE_CLIP
	case pdfium.TEXT_RENDERMODE.FILL_STROKE_CLIP:
		return .FILL_STROKE_CLIP
	case pdfium.TEXT_RENDERMODE.CLIP:
		return .CLIP
	case:
		panic("Unreachable")
	}
}
