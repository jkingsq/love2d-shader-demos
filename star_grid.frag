#define M_PI 3.1415926535897932384626433832795

uniform float time;
uniform vec2 mouse;
uniform mat2 window_scale;

float pos_sine(float theta)
{
    return (sin(theta) + 1) / 2;
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);
    vec2 center = vec2(0.5, 0.5);
    vec2 position = window_scale * vec2(
        texture_coords.x - mouse.x,
        texture_coords.y - mouse.y
    );

    float grid_scale = 40;

    vec2 scaled_pos = grid_scale * position;

    float grid_luminance = pow(max(
        pos_sine(3 * M_PI / 2 + 2 * M_PI * (scaled_pos.x - floor(scaled_pos.x))),
        pos_sine(3 * M_PI / 2 + 2 * M_PI * (scaled_pos.y - floor(scaled_pos.y)))
    ), 2.0f);

    float pos_theta = atan(position.y, position.x);
    float spokes = 128.0;

    float wheel_luminance = pow(sin(pos_theta * spokes + time * 4 * M_PI), 100.0f);

    float pattern_luminance =
        wheel_luminance * grid_luminance + wheel_luminance / 10.0 + grid_luminance / 10.0;

    return vec4(pattern_luminance, pattern_luminance, pattern_luminance, 1.0f);
}
