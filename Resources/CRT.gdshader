shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Lower = lighter lines. Try 0.05 for subtle, 0.15 for stronger.
uniform float scanline_opacity : hint_range(0.0, 1.0) = 0.08;

// Number of horizontal scanlines across the height of the screen
uniform float scanline_count : hint_range(100.0, 1080.0) = 360.0;

void fragment() {
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    // Simple sine wave to darken alternating pixel rows
    float scanline = sin(SCREEN_UV.y * scanline_count * 3.14159 * 2.0);
    scanline = (scanline + 1.0) * 0.5;
    
    color.rgb = mix(color.rgb, color.rgb * scanline, scanline_opacity);
    COLOR = color;
}