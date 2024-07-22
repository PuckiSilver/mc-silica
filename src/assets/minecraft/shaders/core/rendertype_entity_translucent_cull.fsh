#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in float cooldown; //// mc-silica ////

out vec4 fragColor;

void main() {
    vec4 pixel = texture(Sampler0, texCoord0); // pulled texture reading infront of mc-silica, no need to load the texture twice
    //// mc-silica ////
    if (cooldown >= 0) { // check if cooldown is set
        if (1 - cooldown <= pixel.b) { // if this pixel should show
            fragColor = vec4(1, 1, 1, 0.5); // color of the cooldown
            return;
        }
    }

    //// vanilla ////
    vec4 color = pixel * vertexColor * ColorModulator; // replaced texture getting with pixel variable
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
