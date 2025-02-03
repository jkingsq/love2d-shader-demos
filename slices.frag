#define M_PI 3.1415926535897932384626433832795

uniform float time;
uniform vec2 mouse;
uniform mat2 window_scale;

int slices = 8;
int iterations = slices;

float pattern_scale = 0.5;
float band_r = 0.7 * pattern_scale;
float arc_center_r = 0.6 * pattern_scale;
float rotation_period = 36.0;
float sharpening_coeff = 1.5;

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

    for(int i = 0; i < iterations; i++)
    {
        int i_index = int(i - iterations/2);
        float i_nearness = 1.0 - 2.0 * i_index / slices;

        float i_theta = slice_theta + i_index * slice_angle;
        vec2 i_normal = vec2(cos(i_theta), sin(i_theta));

        float arc_center_theta = i_theta - 2 * rotation_theta;
        vec2 arc_center_normal = vec2(cos(arc_center_theta), sin(arc_center_theta));

        // length of position projected onto slice_normal
        float distance_along_slice = abs(dot(position, slice_normal)) / pattern_scale;

        vec2 band_fixed_point = band_r * i_normal;
        vec2 arc_center = i_nearness * arc_center_r * arc_center_normal;

        result_color += color_cycle(i_theta) * i_nearness * pow(pos_sine(
            distance(position, arc_center) * (2 * M_PI) / distance(band_fixed_point, arc_center)
        ), 1.0 + pow(distance_along_slice * 100, 2.0 / i_nearness));
        //), 10.0 / (distance_along_slice * i_nearness));
    }

    return vec4(
        pow(result_color.x, sharpening_coeff),
        pow(result_color.y, sharpening_coeff),
        pow(result_color.z, sharpening_coeff),
        1.0
    );
}
