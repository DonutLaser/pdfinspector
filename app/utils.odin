package app

@(private = "file")
SCROLL_SPEED :: 20

calculate_scroll_offset :: proc(old_offset, scroll, container_height, content_height: i32) -> i32 {
	if content_height <= container_height {
		return old_offset
	}

	new_offset := old_offset + (scroll * SCROLL_SPEED)
	if new_offset > 0 {
		new_offset = 0
	} else if -new_offset + container_height > content_height {
		new_offset = container_height - content_height
	}

	return new_offset
}
