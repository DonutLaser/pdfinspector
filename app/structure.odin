package app

import "core:fmt"
import "../gui"
import "../pdf"

@(private = "file")
SCROLL_SPEED :: 20

@(private = "file")
Node_Metadata_Key_Value_Pair :: struct {
	key:   string,
	value: string,
}

@(private = "file")
Node :: struct {
	label:    cstring,
	rect:     gui.Rect,
	expanded: bool,
	hovered:  bool,
	active:   bool,
	children: [dynamic]^Node,
	metadata: [dynamic]Node_Metadata_Key_Value_Pair,
}

Structure :: struct {
	rect:         gui.Rect,
	nodes:        [dynamic]Node,
	active_node:  ^Node,
	y_offset:     i32,
	total_height: i32,
	scrollbar:    Scrollbar,
}

create_structure :: proc(rect: gui.Rect) -> Structure {
	return(
		Structure{
			rect = rect,
			active_node = nil,
			y_offset = 0,
			total_height = 0,
			scrollbar = create_scrollbar(rect),
		} \
	)
}

destroy_structure :: proc(s: ^Structure) {
	for node in s.nodes {
		for child in node.children {
			free(child)
		}

		delete(node.children)
	}

	delete(s.nodes)
}

resize_structure :: proc(s: ^Structure, h: i32) {
	s.rect.h = h

	resize_scrollbar(&s.scrollbar, s.rect)
}

setup_structure :: proc(s: ^Structure, pdf_structure: [dynamic]pdf.Page) {
	s.nodes = make([dynamic]Node, len(pdf_structure))

	for i := 0; i < len(pdf_structure); i += 1 {
		page := pdf_structure[i]

		s.nodes[i] = Node {
			label = fmt.caprintf("Page %d", i),
			rect = gui.Rect{s.rect.x, s.rect.y + i32(i) * NODE_HEIGHT, s.rect.w, NODE_HEIGHT},
			expanded = false,
			hovered = false,
			active = false,
			children = make([dynamic]^Node, len(page.objects)),
			metadata = nil, // TODO
		}

		for j := 0; j < len(page.objects); j += 1 {
			obj := page.objects[j]

			n := new(Node)
			n.rect = gui.Rect{s.rect.x, -1, s.rect.w, NODE_HEIGHT}
			n.expanded = false
			n.hovered = false
			n.active = false
			n.children = nil
			n.metadata = nil // TODO

			switch obj.kind {
			case .TEXT:
				n.label = "Text"
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

			s.nodes[i].children[j] = n
		}
	}

	s.total_height = i32(len(s.nodes)) * NODE_HEIGHT

	if s.total_height > s.rect.h {
		show_scrollbar(&s.scrollbar, s.rect.h, s.total_height)
	} else {
		hide_scrollbar(&s.scrollbar)
	}
}

tick_structure :: proc(s: ^Structure, app: ^App, input: ^gui.Input) {
	for i := 0; i < len(s.nodes); i += 1 {
		n := s.nodes[i]
		check_mouse_on_node(s, &s.nodes[i], input)

		for j := 0; j < len(n.children); j += 1 {
			check_mouse_on_node(s, n.children[j], input)
		}
	}

	if gui.is_point_in_rect(input.mouse_x, input.mouse_y, s.rect) {
		s.y_offset = calculate_scroll_offset(s.y_offset, input.scroll_y, s.rect.h, s.total_height)
		update_scrollbar_offset(&s.scrollbar, s.y_offset)
	}
}

@(private = "file")
check_mouse_on_node :: proc(s: ^Structure, node: ^Node, input: ^gui.Input) {
	rect := gui.Rect{node.rect.x, node.rect.y + s.y_offset, node.rect.w, node.rect.h}
	if gui.is_point_in_rect(input.mouse_x, input.mouse_y, rect) {
		node.hovered = true

		if input.lmb == .JUST_PRESSED || input.lmb == .PRESSED {
			node.active = true
		} else if input.lmb == .JUST_RELEASED {
			node.expanded = !node.expanded
			node.active = false

			recalculate_nodes(s)

			s.active_node = node
		}
	} else {
		node.hovered = false
		node.active = false
	}
}

render_structure :: proc(s: ^Structure, app: ^App) {
	gui.draw_rect(app.window, s.rect, STRUCTURE_BG_COLOR)

	main_font := &app.fonts[14]

	for node, index in s.nodes {
		n := node
		render_node(&n, app, s.y_offset)

		if node.expanded {
			for child in node.children {
				render_node(child, app, s.y_offset, 2)
			}
		}
	}

	render_scrollbar(&s.scrollbar, app)
}

@(private = "file")
render_node :: proc(node: ^Node, app: ^App, y_offset: i32, depth: i32 = 1) {
	color := NODE_BG_COLOR
	if node.active {
		color = NODE_ACTIVE_BG_COLOR
	} else if node.hovered {
		color = NODE_HOVERED_BG_COLOR
	}

	r := gui.Rect{node.rect.x, node.rect.y + y_offset, node.rect.w, node.rect.h}

	gui.draw_rect(app.window, r, color)
	gui.draw_rect(app.window, gui.Rect{r.x, r.y + NODE_HEIGHT - 1, r.w, 1}, NODE_BORDER_COLOR)

	main_font := &app.fonts[14]
	gui.draw_text(
		app.window,
		main_font,
		gui.Text{data = node.label, allocated = false},
		gui.Rect{r.x + NODE_PADDING * depth, r.y + NODE_HEIGHT / 2 - main_font.size / 2, -1, -1},
		NODE_TITLE_COLOR,
	)
}

@(private = "file")
recalculate_nodes :: proc(s: ^Structure) {
	start_y: i32 = s.rect.y
	for i := 0; i < len(s.nodes); i += 1 {
		s.nodes[i].rect.y = start_y

		start_y += NODE_HEIGHT

		if s.nodes[i].expanded {
			for j := 0; j < len(s.nodes[i].children); j += 1 {
				s.nodes[i].children[j].rect.y = start_y
				start_y += NODE_HEIGHT
			}
		}
	}

	s.total_height = start_y
	if s.total_height > s.rect.h {
		show_scrollbar(&s.scrollbar, s.rect.h, s.total_height)
	} else {
		hide_scrollbar(&s.scrollbar)
	}
}
