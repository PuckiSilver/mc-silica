#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;
uniform sampler2D Sampler0; //// mc-silica ////

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;
uniform float GameTime; //// mc-silica ////

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
out vec4 normal;
out float cooldown; //// mc-silica ////

//// mc-silica ////
int getMaxCd(int green) {                   // retrieve max cooldown information from texture
    int scaled = green* 10;
    int value;
    if (scaled < 1000) {
        value = scaled / 10;                // green of 1 - 99 => 0.1 - 9.9
    } else if (scaled > 1500) {
        value = (scaled - 1500) * 5 + 600;  // green of 151 - 255 => 65.0 - 585.0 (9,75min)
    } else {
        value = scaled - 900;               // green of 100 - 150 => 10.0 - 60.0
    }
    return value;
}

void main() {
    //// vanilla ////
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(Position, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);

    //// mc-silica ////
    cooldown = -1; // set cooldown to -1 to avoid unvorseen behavior
    if (-0.02 < gl_Position.z && gl_Position.z < -0.01) {                 // check if item is in hotbar
        if (Color.r < 0.999 && Color.g < 0.999 && Color.b < 0.999) {    // check if item is colored
            // grab info from tint
            int tint = int(Color.r*255 * 65536 + Color.g*255 * 256 + Color.b*255 + 0.5);
            float cdUntil = (tint % 16384) / 12000.;    // lower 14 bits
            float cdr = (tint >> 14) / 1000.;           // upper 10 bits

            // grab info from texture
            vec4 pixel = texelFetch(Sampler0, ivec2(texCoord0 * textureSize(Sampler0, 0)), 0);  // get corner pixel
            ivec4 pixelScaled = ivec4(pixel * 255 + vec4(0.5));
            if (pixelScaled.r == 15 && pixelScaled.a == 19) {           // check for correct texture
                float cdMax = getMaxCd(pixelScaled.g) / 12000. * cdr;
                float time = GameTime;
                if (cdUntil - cdMax < 0 && time > 0.5) time += cdMax - cdUntil - 1;     // handle wrapping
                cooldown = (cdUntil - time) / cdMax;
                if (cooldown < 0 || cooldown > 1) {
                    gl_Position = vec4(2.0, 2.0, 2.0, 1.0); // discard vertex if unused
                    cooldown = -1;
                }
            }
        }
    }
}
