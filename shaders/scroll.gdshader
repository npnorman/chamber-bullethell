shader_type canvas_item;

uniform float speed_x = 1.0;
uniform float speed_y = 1.0;
uniform float amplitude = 0.2;

void vertex() {
	UV.x += TIME * speed_x;
	UV.y += sin(TIME * speed_y) * amplitude;
}
