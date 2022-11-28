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

flat out int cdUntil;
flat out int cdr;

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

    bool isHotbar = -0.2 < gl_Position.z && gl_Position.z < -0.1;

    if (isHotbar) {
        if (Color.r < 0.999 && Color.g < 0.999 && Color.b < 0.999) {
            int tint = int(Color.r*255 * 65536 + Color.g*255 * 256 + Color.b*255 + 0.5);
            cdUntil = tint % 4096;
            cdr = tint >> 12;
        }
    }
}
