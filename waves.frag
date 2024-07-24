#define M_PI 3.1415926535897932384626433832795

uniform float time;
uniform vec2 mouse;
uniform mat2 window_scale;

float pos_sine(float theta)
{
    return (sin(theta) + 1) / 2;
}

float pos_cos(float theta)
{
    return (cos(theta) + 1) / 2;
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);

    vec2 position = window_scale * vec2(
        texture_coords.x - mouse.x,
        texture_coords.y - mouse.y
    );

    float base_luminance = pow(pos_sine(
        length(position) * 100 * M_PI // + 2 * M_PI * time
    ), 20);
    float luminance_exp = pow(pos_cos(
        (position.x * position.y) * 100 * M_PI + 2 * M_PI * time
    ) / length(position), 2);

    float luminance = pow(base_luminance, luminance_exp);

    return vec4(luminance, luminance, luminance, 1.0);
}
