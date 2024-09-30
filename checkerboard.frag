#define M_PI 3.1415926535897932384626433832795

uniform float time;
uniform vec2 mouse;
uniform mat2 window_scale;

// Higher exponents give sharper edges
float smoothing_exponent = 2.0;

// FIXME this behaves differently on different GPUs I guess?
// There's probably a built-in glsl function that just does this consistently
float floor_rounded(float x)
{
   return
    floor(x) + (pow(2 * (x - floor(x)) - 1, smoothing_exponent) + 1) / 2;
}

float pos_sine(float theta)
{
    return (sin(theta) + 1) / 2;
}

vec4 color_cycle(float theta)
{
    return vec4(
        pos_sine(theta),
        pos_sine(theta + 2 * M_PI / 3),
        pos_sine(theta - 2 * M_PI / 3),
        1.0
    );
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screencoords)
{
    vec4 texturecolor = Texel(tex, texture_coords);

    vec2 position = window_scale * vec2(
        texture_coords.x - mouse.x,
        texture_coords.y - mouse.y
    );

    float tile_scale = 0.2;
    float wave_amplitude_scale = 2 * tile_scale;

    float wave_amplitude_period = 6.0;
    float wave_amplitude =
        wave_amplitude_scale * sin(2 * M_PI * time / wave_amplitude_period);
    float wave_rotation_period = wave_amplitude_period * 8.0;
    float wave_rotation_theta = 2 * M_PI * time / wave_rotation_period;
    mat2 wave_rotation = mat2(
        cos(wave_rotation_theta), sin(wave_rotation_period),
        sin(wave_rotation_period), -1 * cos(wave_amplitude_period)
    );
    float position_offset_scale =
        wave_amplitude *
        sin(2 * M_PI * dot(wave_rotation[0], position) / tile_scale);

    vec2 position_offset =
        tile_scale *
        position_offset_scale *
        wave_rotation[1];

    position += position_offset;
    position *= 1/tile_scale;

    float checkerboard_luminance =
        mod(floor_rounded(position.x) + floor_rounded(position.y), 2);

    float color_period = 16;
    float color_steps = 16;
    float color_theta =
        2 * M_PI * time / color_period;
        // alternate config where tiles step through the color cycle.
        // the steps looked too abrupt
        // 2 * M_PI * time
        // floor_rounded(time / color_period * color_steps)
        // / color_steps;

    vec4 checkerboard_color =
        checkerboard_luminance *
        color_cycle(
            2 * M_PI / color_steps *
            (floor_rounded(position.x) + floor_rounded(position.y))
            + color_theta
        );

    float luminance = checkerboard_luminance;

    vec4 checkerboard = vec4(
        luminance,
        luminance,
        luminance,
        1.0
    );

    return checkerboard_color;
}
