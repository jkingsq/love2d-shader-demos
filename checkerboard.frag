#define M_PI 3.1415926535897932384626433832795

uniform float time;
uniform vec2 mouse;
uniform mat2 window_scale;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screencoords)
{
    vec4 texturecolor = Texel(tex, texture_coords);

    vec2 position = window_scale * vec2(
        texture_coords.x - mouse.x,
        texture_coords.y - mouse.y
    );

    float wave_amplitude_period = 6.0;
    float wave_amplitude = sin(2 * M_PI * time / wave_amplitude_period);
    float wave_rotation_period = wave_amplitude_period * 6.0;
    float wave_rotation_theta = 2 * M_PI * time / wave_rotation_period;
    mat2 wave_rotation = mat2(
        cos(wave_rotation_theta), -1 * sin(wave_rotation_period),
        sin(wave_rotation_period), cos(wave_amplitude_period)
    );

    vec2 position_offset =
        dot(wave_rotation[0], normalize(position)) * wave_rotation[1];
    float tile_scale = 0.2;

    position += position_offset;
    position *= 1/tile_scale;

    float checkerboard_luminance =
        mod(floor(position.x) + floor(position.y), 2);

    vec4 checkerboard = vec4(
        checkerboard_luminance,
        checkerboard_luminance,
        checkerboard_luminance,
        1.0
    );

    return checkerboard;
}
