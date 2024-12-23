#define M_PI 3.1415926535897932384626433832795

uniform float time;
uniform vec2 mouse;
uniform mat2 window_scale;

int slices = 5;

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
    int slice = int(floor((atan(position.y, position.x) - rotation_theta) / slice_angle));
    float slice_theta = (slice + 0.5) * slice_angle;
    vec2 slice_normal = vec2(cos(slice_theta), sin(slice_theta));

    vec4 result_color = vec4(0.0, 0.0, 0.0, 1.0);

    for(int i = 0; i < slices; i++)
    {
        float i_nearness = 1.0 - slices / abs(slice - i);

        // want this to count from (-slices/2, slices/2) with 0 being the i that
        // matches the slice.  Losing my mind.
        int i_index = i - slice;
        float i_theta = slice_theta + i_index * slice_angle;
        vec2 i_normal = vec2(cos(i_theta), sin(i_theta));

        float arc_center_theta = i_theta - 2 * rotation_theta;
        vec2 arc_center_normal = vec2(cos(arc_center_theta), sin(arc_center_theta));

        // length of position projected onto slice_normal
        float distance_along_slice = abs(dot(position, slice_normal));

        vec2 band_fixed_point = band_r * i_normal;
        vec2 arc_center = arc_center_r * arc_center_normal;

        result_color += color_cycle(slice_theta) * 2 * pow(pos_sine(
            distance(position, arc_center) * (2 * M_PI) / distance(band_fixed_point, arc_center)
        ), 1.0 + pow(distance_along_slice * 100, 50.0));
    }

    result_color.w = 1.0;

    return result_color;
}
