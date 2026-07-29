#version 330

uniform sampler2D tex;
uniform vec2 texsize;
uniform float timer;

// Custom uniform, picom sets this to a random value per frame
uniform float picom_rand;

// The main shader function
out vec4 FragColor; // Declare output variable for fragment color

void main() {
    vec2 uv = gl_FragCoord.xy / texsize.xy;

    // Simulate scanlines
    uv.y += sin(uv.y * 300.0) * 0.005 * sin(timer * 2.0 + picom_rand * 10.0);

    // Create a horizontal chromatic aberration/shift
    vec4 color = texture(tex, uv);
    vec4 colorR = texture(tex, uv + vec2(0.005, 0.0) * sin(timer));
    vec4 colorG = texture(tex, uv + vec2(0.0, 0.002));
    vec4 colorB = texture(tex, uv + vec2(-0.005, 0.0) * cos(timer * 1.2));

    // Combine the shifted colors with some random noise
    color.r = colorR.r + (picom_rand - 0.5) * 0.1;
    color.g = colorG.g + (picom_rand - 0.5) * 0.1;
    color.b = colorB.b + (picom_rand - 0.5) * 0.1;
    color.a = color.a; // Maintain original opacity

    // A subtle wave distortion effect
    uv.x += sin(uv.y * 10.0 + timer) * 0.002 * cos(timer * 0.5);

    // Final color output
    FragColor = texture(tex, uv);
    FragColor += color * 0.2; // Blend with our shifted colors

    // Add a subtle flicker effect
    FragColor.rgb *= (0.95 + picom_rand * 0.1);

    // Add a final CRT-like vignette
    float vignette = length(uv - 0.5) * 1.5;
    FragColor.rgb *= (1.0 - vignette);
}


// Error:
// [ 08/09/2025 20:57:15.285 c2_parse_target WARN ] Type specifier is deprecated. Type "c" specified on target "_GTK_FRAME_EXTENTS" will be ignored, you can remove it.
// [ 08/09/2025 20:57:15.286 session_init ERROR ] Failed to load shader source file for some of the window shader rules
// [ 08/09/2025 20:57:15.384 gl_create_shader ERROR ] Failed to compile shader with type 35632: 0(33) : error C1503: undefined variable "FragColor"
// 0(34) : error C1503: undefined variable "FragColor"
// 0(37) : error C1503: undefined variable "FragColor"
// 0(41) : error C1503: undefined variable "FragColor"
// 0(11) : error C1110: function "window_shader" has no return statement

// [ 08/09/2025 20:57:15.384 gl_shader_from_stringv ERROR ] Failed to create GLSL program.
// [ 08/09/2025 20:57:15.384 initialize_backend WARN ] Failed to create shader for shader file /home/tetra/.config/picom/shaders/glitch.glsl, this shader will not be used
