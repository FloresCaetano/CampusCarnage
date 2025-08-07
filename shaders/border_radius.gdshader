shader_type canvas_item;

uniform float radius = 20.0;
uniform float feather = 1.0;
uniform vec4 color : source_color = vec4(1.0);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 size = vec2(textureSize(SCREEN_TEXTURE, 0));
    vec2 uv = FRAGCOORD.xy / size;

    vec2 pixel_size = vec2(SCREEN_PIXEL_SIZE.x * size.x, SCREEN_PIXEL_SIZE.y * size.y);
    vec2 pos = UV * pixel_size;

    vec2 dist = min(pos, pixel_size - pos);
    float d = min(dist.x, dist.y);

    float corner_dist = length(dist - vec2(radius));
    float alpha = smoothstep(radius, radius - feather, corner_dist);

    COLOR = color;
    COLOR.a *= alpha;
}
