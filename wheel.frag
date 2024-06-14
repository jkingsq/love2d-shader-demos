#define M_PI 3.1415926535897932384626433832795

uniform float time;
uniform vec2 mouse;
uniform mat2 window_scale;

mat4 xyz_to_rgb = mat4(
    3.2404542, -1.5371385, -0.4985314, 0.0,
    -0.9692660, 1.8760108, 0.0415560, 0.0,
    0.0556434, -0.2040259, 1.0572252, 0.0,
    0.0, 0.0, 0.0, 1.0
);

float pos_sine(float theta)
{
    return (sin(theta) + 1) / 2;
}

vec4 color_cycle(float theta)
{
    vec4 color_xyz = vec4(
        pos_sine(theta),
        pos_sine(theta + 2 * M_PI / 3),
        pos_sine(theta - 2 * M_PI / 3),
        1.0
    );

    return color_xyz;

    /*

    float theta_norm = theta / (2 * M_PI);

    float luminance = pow(theta_norm - floor(theta_norm), 2.0);

    return vec4(luminance, luminance, luminance, 1.0);
    */
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);

    float wheel_phase = 2 * M_PI * time / 1;

    vec2 position = window_scale * vec2(
        texture_coords.x - mouse.x,
        texture_coords.y - mouse.y
    );

    float position_theta = atan(position.y, position.x);

    float max_wave_offset = 4 * M_PI;

    float wave_phase = 2 * M_PI * time / 30;

    float wave_theta = length(position) * 45;

    float wave_offset = sin(wave_phase) * sin(wave_theta) * max_wave_offset;

    return color_cycle(5 * position_theta + wheel_phase + wave_offset);
}
