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
//// mc-silica ////
uniform sampler2D Sampler0;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
out vec4 normal;

//// mc-silica ////
flat out int cdUntil;
flat out int cdr;
flat out int cdMax;

//// mc-silica ////
int getMaxCd(int green) {                 // retrieve max cooldown information from green channel of texture corners
    int scaled = green* 10;
    int value;
    if (scaled < 1000) {
        value = scaled;                     // g of 1 - 99 => 0.1 - 9.9
    } else if (scaled > 1500) {
        value = (scaled - 1500) * 5 + 600;  // g of 151 - 255 => 65.0 - 625.0 (10 min 25sec)
    } else {
        value = scaled - 900;               // g of 100 - 150 => 10.0 - 60.0
    }
    return value;
}

void main() {
    //// vanilla ////
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);

    //// mc-silica ////
    cdUntil = -1;
    cdr = -1;
    cdMax = -1;

    bool isHotbar = -0.2 < gl_Position.z && gl_Position.z < -0.1;

    if (isHotbar) {
        if (Color.r < 0.999 && Color.g < 0.999 && Color.b < 0.999) {
            // grab info from tint
            int tint = int(Color.r*255 * 65536 + Color.g*255 * 256 + Color.b*255 + 0.5);
            cdUntil = tint % 4096;
            cdr = tint >> 12;

            // grab info from texture
            ivec2 texSize = textureSize(Sampler0, 0);
            vec4 pixel = texelFetch(Sampler0, ivec2(texCoord0 * texSize + vec2(0.5)), 0);
            ivec4 pixelScaled = ivec4(pixel * 255 + vec4(0.5));
            if (pixelScaled.r == 15 && pixelScaled.a == 19) {   // check for correct texture
                cdMax = getMaxCd(pixelScaled.g);
            }
        }
    }
}
