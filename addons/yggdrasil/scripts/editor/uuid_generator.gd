static func v4() -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var bytes := PackedByteArray()
	bytes.resize(16)

	for i in range(16):
		bytes[i] = rng.randi_range(0, 255)

	bytes[6] = (bytes[6] & 0x0F) | 0x40
	bytes[8] = (bytes[8] & 0x3F) | 0x80

	return _bytes_to_uuid(bytes)

static func _bytes_to_uuid(bytes: PackedByteArray) -> String:
	return "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x" % [
		bytes[0], bytes[1], bytes[2], bytes[3],
		bytes[4], bytes[5],
		bytes[6], bytes[7],
		bytes[8], bytes[9],
		bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]
	]
