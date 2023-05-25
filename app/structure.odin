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
	rect:        gui.Rect,
	nodes:       [dynamic]Node,
	active_node: ^Node,
	y_offset:    i32,
}

create_structure :: proc(rect: gui.Rect) -> Structure {
	return Structure{rect = rect, active_node = nil, y_offset = 0}
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
}

tick_structure :: proc(s: ^Structure, app: ^App, input: ^gui.Input) {
	for i := 0; i < len(s.nodes); i += 1 {
		n := s.nodes[i]

		node_rect := gui.Rect{n.rect.x, n.rect.y + s.y_offset, n.rect.w, n.rect.h}
		if gui.is_point_in_rect(input.mouse_x, input.mouse_y, node_rect) {
			s.nodes[i].hovered = true

			if input.lmb == .JUST_PRESSED || input.lmb == .PRESSED {
				s.nodes[i].active = true
			} else if input.lmb == .JUST_RELEASED {
				s.nodes[i].expanded = !s.nodes[i].expanded
				s.nodes[i].active = false

				recalculate_nodes(s)

				s.active_node = &s.nodes[i]
			}
		} else {
			s.nodes[i].hovered = false
			s.nodes[i].active = false
		}

		for j := 0; j < len(n.children); j += 1 {
			child_rect := gui.Rect{
				n.children[j].rect.x,
				n.children[j].rect.y + s.y_offset,
				n.children[j].rect.w,
				n.children[j].rect.h,
			}
			if gui.is_point_in_rect(input.mouse_x, input.mouse_y, child_rect) {
				n.children[j].hovered = true

				if input.lmb == .JUST_PRESSED || input.lmb == .PRESSED {
					n.children[j].active = true
				} else if input.lmb == .JUST_RELEASED {
					n.children[j].expanded = !n.children[j].expanded
					n.children[j].active = false

					s.active_node = n.children[j]
				}
			} else {
				n.children[j].hovered = false
				n.children[j].active = false
			}
		}
	}

	if gui.is_point_in_rect(input.mouse_x, input.mouse_y, s.rect) {
		s.y_offset += input.scroll_y * SCROLL_SPEED
		if s.y_offset > 0 {
			s.y_offset = 0
		}
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
}
