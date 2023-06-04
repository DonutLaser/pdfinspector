package app

import "core:fmt"
import "../gui"
import "../pdf"

@(private = "file")
SCROLL_SPEED :: 20

@(private = "file")
instance := Structure{}
@(private = "file")
initialized := false

Tuple :: struct {
	key:   cstring,
	value: cstring,
}

@(private = "file")
Node :: struct {
	label:    cstring,
	rect:     gui.Rect,
	expanded: bool,
	hovered:  bool,
	active:   bool,
	children: [dynamic]^Node,
	metadata: [dynamic]Tuple,
}

Structure :: struct {
	rect:         gui.Rect,
	nodes:        [dynamic]Node,
	active_node:  ^Node,
	y_offset:     i32,
	total_height: i32,
	scrollbar:    Scrollbar,
}

structure_init :: proc(rect: gui.Rect) {
	if initialized {
		return
	}

	instance.rect = rect

	initialized = true
}

structure_deinit :: proc() {
	for node in instance.nodes {
		for child in node.children {
			free(child)
		}

		delete(node.children)
	}

	delete(instance.nodes)
}

structure_resize :: proc(rect: gui.Rect) {
	instance.rect = rect
	scrollbar_setup(&instance.scrollbar, instance.rect, instance.rect, instance.total_height)
}

structure_setup :: proc(pdf_structure: [dynamic]pdf.Page) {
	instance.nodes = make([dynamic]Node, len(pdf_structure))

	for i := 0; i < len(pdf_structure); i += 1 {
		page := pdf_structure[i]

		instance.nodes[i] = Node {
			label = fmt.caprintf("Page %d", i),
			rect = gui.Rect{
				instance.rect.x,
				instance.rect.y + i32(i) * STRUCTURE_NODE_HEIGHT,
				instance.rect.w,
				STRUCTURE_NODE_HEIGHT,
			},
			expanded = false,
			hovered = false,
			active = false,
			children = make([dynamic]^Node, len(page.objects)),
			metadata = nil,
		}

		for j := 0; j < len(page.objects); j += 1 {
			obj := page.objects[j]

			n := new(Node)
			n.rect = gui.Rect{instance.rect.x, -1, instance.rect.w, STRUCTURE_NODE_HEIGHT}
			n.expanded = false
			n.hovered = false
			n.active = false
			n.children = nil
			n.metadata = nil

			switch obj.kind {
			case .TEXT:
				n.label = "Text"
				n.metadata = make([dynamic]Tuple)

				data := obj.data.(pdf.Text_Object)
				append(&n.metadata, Tuple{"Mode", pdf.text_render_mode_to_string(data.mode)})
				append(&n.metadata, Tuple{"Value", data.text})
				// append(&n.metadata, Tuple{"Size", data.size}) // TODO
				append(&n.metadata, Tuple{"Font name", data.font.name})
				// append(&n.metadata, Tuple{"Font weight", data.font.weight}) // TODO
				// append(&n.metadata, Tuple{"Font ascent", data.font.ascent}) // TODO
				// append(&n.metadata, Tuple{"Font descent", data.font.descent}) // TODO
				append(
					&n.metadata,
					Tuple{"Font is fixed pitch", bool_to_string(data.font.is_fixed_pitch)},
				)
				append(&n.metadata, Tuple{"Font is serif", bool_to_string(data.font.is_serif)})
				append(
					&n.metadata,
					Tuple{"Font is symbolic", bool_to_string(data.font.is_symbolic)},
				)
				append(&n.metadata, Tuple{"Font is script", bool_to_string(data.font.is_script)})
				append(&n.metadata, Tuple{"Font is italic", bool_to_string(data.font.is_italic)})
				append(
					&n.metadata,
					Tuple{"Font is all caps", bool_to_string(data.font.is_all_caps)},
				)
				append(
					&n.metadata,
					Tuple{"Font is small caps", bool_to_string(data.font.is_small_caps)},
				)
				append(
					&n.metadata,
					Tuple{"Font is forced bold", bool_to_string(data.font.is_forced_bold)},
				)
				append(
					&n.metadata,
					Tuple{"Font is embedded", bool_to_string(data.font.is_embedded)},
				)
			case .IMAGE:
				n.label = "Image"
			case .PATH:
				n.label = "Path"
			case .FORM:
				n.label = "Form"
			case .SHADING:
				n.label = "Shading"
			case .UKNOWN:
				n.label = "Unknown"
			}

			instance.nodes[i].children[j] = n
		}
	}

	instance.total_height = i32(len(instance.nodes)) * STRUCTURE_NODE_HEIGHT
	scrollbar_setup(&instance.scrollbar, instance.rect, instance.rect, instance.total_height)
}

structure_tick :: proc(input: ^gui.Input) {
	// TODO: prevent clicks on invisible items
	for i := 0; i < len(instance.nodes); i += 1 {
		n := instance.nodes[i]
		check_mouse_on_node(&instance.nodes[i], input)

		if (instance.nodes[i].expanded) {
			for j := 0; j < len(n.children); j += 1 {
				check_mouse_on_node(n.children[j], input)
			}
		}
	}

	if gui.is_point_in_rect(input.mouse_x, input.mouse_y, instance.rect) {
		instance.y_offset = calculate_scroll_offset(
			instance.y_offset,
			input.scroll_y,
			instance.rect.h,
			instance.total_height,
		)
		scrollbar_update_offset(&instance.scrollbar, instance.y_offset)
	}
}

@(private = "file")
check_mouse_on_node :: proc(node: ^Node, input: ^gui.Input) {
	rect := gui.Rect{node.rect.x, node.rect.y + instance.y_offset, node.rect.w, node.rect.h}
	if gui.is_point_in_rect(input.mouse_x, input.mouse_y, rect) {
		node.hovered = true

		if input.lmb == .JUST_PRESSED || input.lmb == .PRESSED {
			node.active = true
		} else if input.lmb == .JUST_RELEASED {
			node.expanded = !node.expanded
			node.active = false

			if node.metadata == nil {
				object_info_hide()
			} else {
				object_info_show(&node.metadata)
			}

			recalculate_nodes()

			instance.active_node = node
		}
	} else {
		node.hovered = false
		node.active = false
	}
}

structure_render :: proc(app: ^App) {
	gui.draw_rect(app.window, instance.rect, STRUCTURE_BG_COLOR)

	main_font := assets_get_font_at_size(14)

	gui.clip_rect(app.window, instance.rect)
	for i := 0; i < len(instance.nodes); i += 1 {
		render_node(&instance.nodes[i], app, instance.y_offset)

		if instance.nodes[i].expanded {
			for child in instance.nodes[i].children {
				render_node(child, app, instance.y_offset, 2)
			}
		}
	}
	gui.unclip_rect(app.window)
}

@(private = "file")
render_node :: proc(node: ^Node, app: ^App, y_offset: i32, depth: i32 = 1) {
	color := STRUCTURE_NODE_BG_COLOR
	if node.active {
		color = STRUCTURE_NODE_ACTIVE_BG_COLOR
	} else if node.hovered {
		color = STRUCTURE_NODE_HOVERED_BG_COLOR
	}

	offset_rect := gui.Rect{node.rect.x, node.rect.y + y_offset, node.rect.w, node.rect.h}

	gui.draw_rect(app.window, offset_rect, color)
	gui.draw_rect(
		app.window,
		gui.Rect{offset_rect.x, offset_rect.y + STRUCTURE_NODE_HEIGHT - 1, offset_rect.w, 1},
		STRUCTURE_NODE_BORDER_COLOR,
	)

	main_font := assets_get_font_at_size(14)
	gui.draw_text(
		app.window,
		main_font,
		gui.Text{data = node.label, allocated = false},
		gui.Rect{
			offset_rect.x + STRUCTURE_NODE_PADDING * depth,
			offset_rect.y + STRUCTURE_NODE_HEIGHT / 2 - main_font.size / 2,
			-1,
			-1,
		},
		STRUCTURE_NODE_TITLE_COLOR,
	)

	scrollbar_render(&instance.scrollbar, app)
}

@(private = "file")
recalculate_nodes :: proc() {
	layout := gui.layout_new(instance.rect)
	for i := 0; i < len(instance.nodes); i += 1 {
		instance.nodes[i].rect = gui.layout_get_rect(&layout, -1, STRUCTURE_NODE_HEIGHT)
		if instance.nodes[i].expanded {
			for j := 0; j < len(instance.nodes[i].children); j += 1 {
				instance.nodes[i].children[j].rect = gui.layout_get_rect(
					&layout,
					-1,
					STRUCTURE_NODE_HEIGHT,
				)
			}
		}
	}

	instance.total_height = layout.rect.y
	scrollbar_setup(&instance.scrollbar, instance.rect, instance.rect, instance.total_height)
}

@(private = "file")
bool_to_string :: proc(value: bool) -> cstring {
	return value ? "Yes" : "No"
}
