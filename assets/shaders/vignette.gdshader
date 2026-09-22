shader_type canvas_item;

// A full-screen darkening overlay: a uniform base dim plus a radial
// vignette that gets darker toward the edges/corners. Applied to a
// full-rect ColorRect placed as the first child of UI (so it sits under
// every HUD board, dimming the game world without dimming the HUD text
// itself). All values tunable live in the Inspector.

uniform float base_darken : hint_range(0.0, 1.0) = 0.12;
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.75;
uniform float vignette_radius : hint_range(0.0, 1.5) = 0.55;
uniform float vignette_softness : hint_range(0.01, 1.5) = 0.6;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec2 centered_uv = (UV - vec2(0.5)) * 2.0;
	float dist = length(centered_uv);
	float vignette = smoothstep(vignette_radius, vignette_radius + vignette_softness, dist);
	float alpha = clamp(base_darken + vignette * vignette_intensity, 0.0, 1.0);
	COLOR = vec4(vignette_color.rgb, alpha);
}
