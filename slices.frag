#define M_PI 3.1415926535897932384626433832795

uniform float time;
uniform vec2 mouse;
uniform mat2 window_scale;

int slices = 16;

float band_r = 0.7;
float arc_center_r = 0.6;
float rotation_period = 36.0;

float pos_sine(float theta)
{
    return (sin(theta) + 1) / 2;
}

float pos_cos(float theta)
{
    return (cos(theta) + 1) / 2;
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
    vec2 position = window_scale * vec2(
        texture_coords.x - mouse.x,
        texture_coords.y - mouse.y
    );

    float rotation_theta = time * (2 * M_PI) / rotation_period;

    float slice_angle = (2 * M_PI) / slices;
    float slice = floor((atan(position.y, position.x) - rotation_theta) / slice_angle);
    float slice_theta = (slice + 0.5) * slice_angle;
    float arc_center_theta = slice_theta - 2 * rotation_theta;
    vec2 slice_normal = vec2(cos(slice_theta), sin(slice_theta));
    vec2 arc_center_normal = vec2(cos(arc_center_theta), sin(arc_center_theta));

    // length of position projected onto slice_normal
    float distance_along_slice = abs(dot(position, slice_normal));

    vec2 band_fixed_point = band_r * slice_normal;
    vec2 arc_center = arc_center_r * arc_center_normal;

    return color_cycle(slice_theta) * 2 * pow(pos_sine(
        distance(position, arc_center) * (2 * M_PI) / distance(band_fixed_point, arc_center)
    ), 1.0 + pow(distance_along_slice * 100, 2.0));
}
