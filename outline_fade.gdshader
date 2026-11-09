shader_type canvas_item;

// Smooth fading outline for pixel art (Godot 4).
// Usage: assign as a ShaderMaterial on a Sprite2D / AnimatedSprite2D / TextureRect.
// Set the node's Texture > Filter to "Nearest" to keep the sprite crisp.
// The texture needs transparent padding >= outline_width + 1, or the fade is clipped.
// Respects the node's (and its parents') modulate, so fading via modulate.a works.

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 16.0, 0.1) = 4.0; // in texels
uniform float falloff : hint_range(0.25, 4.0, 0.05) = 1.0;      // 1 = linear, >1 = tighter glow

const int MAX_RADIUS = 17; // must be >= ceil(max outline_width) + 1

// In vertex(), COLOR holds the node's modulate. Pass it on to fragment().
varying vec4 tint;

void vertex() {
	tint = COLOR;
}

// Alpha of the texture at uv, treating anything outside the texture as transparent.
float sample_alpha(sampler2D tex, vec2 uv) {
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		return 0.0;
	}
	return texture(tex, uv).a;
}

void fragment() {
	// Sprite pixel with modulate applied.
	vec4 base = texture(TEXTURE, UV) * tint;
	float best = 0.0;

	if (base.a < 1.0 && outline_width > 0.0) {
		// Outline reaches 1 texel past the sprite edge plus outline_width.
		float max_dist = outline_width + 1.0;
		int radius = int(ceil(max_dist));
		float nearest = max_dist; // distance (in texels) to the closest opaque texel

		for (int y = -MAX_RADIUS; y <= MAX_RADIUS; y++) {
			if (abs(y) > radius) {
				continue;
			}
			for (int x = -MAX_RADIUS; x <= MAX_RADIUS; x++) {
				if (abs(x) > radius) {
					continue;
				}
				// Exact Euclidean distance in texels. Skip samples that can't win.
				float d = length(vec2(float(x), float(y)));
				if (d >= nearest) {
					continue;
				}
				vec2 offset = vec2(float(x), float(y)) * TEXTURE_PIXEL_SIZE;
				if (sample_alpha(TEXTURE, UV + offset) > 0.0) {
					nearest = d;
				}
			}
		}

		if (nearest < max_dist) {
			// 1.0 right next to the sprite, smoothly fading to 0 at the outer edge.
			float t = 1.0 - (nearest - 1.0) / outline_width;
			best = pow(clamp(t, 0.0, 1.0), falloff);
		}
	}

	// Outline fades together with the sprite's modulate alpha.
	float outline_a = best * outline_color.a * tint.a;

	// Composite sprite over outline.
	float out_a = base.a + outline_a * (1.0 - base.a);
	vec3 out_rgb = base.rgb;
	if (out_a > 0.0) {
		out_rgb = (base.rgb * base.a + outline_color.rgb * outline_a * (1.0 - base.a)) / out_a;
	}
	COLOR = vec4(out_rgb, out_a);
}
