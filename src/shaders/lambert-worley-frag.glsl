#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform int u_Time;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

float length2(vec2 p)
{
    //producto punto entre los 2 vectore vx*vx + vY*vY
    return dot(p,p);
}

float noise(vec2 p)
{
    //funcion de ruido pseudo-aleatoria basada en la funcio seno 
    return fract(cos(fract(sin(p.x)*(41.13311))+ p.y)*31.0011);
}

float worley(vec2 p) 
{
    //ponemos un numero grandote 
 float d = 1e30;
    //checamos todos los puntos vecinos en 9 direcciones 
 for (int xo = -1; xo <= 1; ++xo) {
  for (int yo = -1; yo <= 1; ++yo) {
   vec2 tp = floor(p) + vec2(xo, yo);
   d = min(d, length2(p - tp - noise(tp)));
  }
 }
    //funcion exponencial mamona 3.0*exp(-4.0*abs(2.0*d - 1.0)).
  return 3.0*exp(-4.0*abs((2.5*d)-1.0));
}

float fworley(vec2 p)
{
    return sqrt(sqrt(sqrt(worley(p * 5.0 + 0.05 * float(u_Time) * 0.05) * 
                          sqrt(worley(p*50.0+ 0.12+ -0.1*float(u_Time) * 0.05)) *
                         sqrt(sqrt(worley(p*-10.0+00.03*float(u_Time)* 0.05))))));
}

void main()
{
    vec2 resolution = vec2(1080, 1080);
    vec2 uv = gl_FragCoord.xy / resolution;
    float wolo = fworley(uv*resolution.xy / 1500.0);
    wolo *= exp(-length2(abs(0.5*uv-1.0)));
    vec4 fragColor = vec4(wolo * vec3(.1, 0.2*wolo, pow(wolo, 0.50-wolo)), 1.0);

    out_Col = fragColor;
}
