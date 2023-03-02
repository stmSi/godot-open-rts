static func find_valid_position_radially(starting_position: Vector3, radius: float, scene_tree):
	return find_valid_position_radially_yet_skip_starting_radius(
		starting_position, 0.0, radius, 0.0, Vector3(0, 0, 1), true, scene_tree
	)


static func find_valid_position_radially_yet_skip_starting_radius(
	starting_position: Vector3,
	starting_radius: float,
	radius: float,
	spacing: float,
	starting_direction: Vector3,
	shuffle: bool,
	scene_tree
):
	var starting_position_yless = starting_position * Vector3(1, 0, 1)
	var units = scene_tree.get_nodes_in_group("units")
	var starting_distance = (
		0 if is_zero_approx(starting_radius) else starting_radius + radius + spacing
	)
	var starting_offset = 1 if is_zero_approx(starting_radius) else 0
	if (
		is_zero_approx(starting_radius)
		and _is_agent_placement_position_valid(starting_position_yless, radius, units)
	):
		return starting_position_yless
	for ring_number in range(starting_offset, 999999):
		var ring_distance_from_starting_position: float = (
			starting_distance + radius * 0.5 * ring_number
		)
		var rotation_angle_rad = asin((radius + spacing) / ring_distance_from_starting_position)
		var radial_positions = []
		var next_rotation_angle_rad = 0.0
		while next_rotation_angle_rad <= PI * 2.0 - rotation_angle_rad:
			radial_positions.append(
				(
					starting_position_yless
					+ (
						starting_direction.normalized().rotated(Vector3.UP, next_rotation_angle_rad)
						* ring_distance_from_starting_position
					)
				)
			)
			next_rotation_angle_rad += rotation_angle_rad
		if shuffle:
			radial_positions.shuffle()
		for radial_position in radial_positions:
			if _is_agent_placement_position_valid(radial_position, radius, units):
				return radial_position
	assert(false)  # unexpected flow
	return Vector3.INF


static func _is_agent_placement_position_valid(position, radius, existing_units):
	for existing_unit in existing_units:
		if (
			(existing_unit.global_position * Vector3(1, 0, 1)).distance_to(
				position * Vector3(1, 0, 1)
			)
			<= existing_unit.radius + radius
		):
			return false  # TODO: take navigation into account
	return true
