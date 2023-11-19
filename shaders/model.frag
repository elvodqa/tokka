#version 330 core

in vec3 fNormal;
in vec3 fPos;
in vec2 fTexCoords;

struct Material {
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float shininess;
};

struct Light {
    vec3 position;
    vec3 diffuse;
    vec3 specular;
};

uniform Material material;

uniform Light light1;
uniform Light light2;
uniform Light light3;
uniform Light light4;

uniform vec3 viewPos;

uniform sampler2D modelTexture;

uniform vec3 world_color;

struct DirectionalLight{
    vec3 direction;
    vec3 color;
};
uniform DirectionalLight directionalLight;

out vec4 FragColor;

vec3 calculateLight(Light light, Material material, vec3 viewPos, vec3 fPos, vec3 fNormal) {
    //diffuse
    vec3 norm = normalize(fNormal);
    vec3 lightDirection = normalize(light.position - fPos);
    float diff = max(dot(norm, lightDirection), 0.0);
    float distance = length(light.position - fPos);

    float falloff = 1.0f/(distance*distance);
    vec3 diffuse = light.diffuse * (diff * material.diffuse)* (falloff);
    return diffuse;
}

vec3 calculateDirectionalLight(DirectionalLight light, Material material, vec3 viewPos, vec3 fPos, vec3 fNormal) {
    //diffuse
    vec3 norm = normalize(fNormal);
    vec3 lightDirection = normalize(-light.direction);
    float diff = max(dot(norm, lightDirection), 0.0);

    vec3 diffuse = light.color * (diff * material.diffuse);

    return diffuse;
}

void main()
{
    vec3 result = vec3(0.0);
    
    result+=calculateLight(light1, material, viewPos, fPos, fNormal);
    result+=calculateLight(light2, material, viewPos, fPos, fNormal);
    result+=calculateLight(light3, material, viewPos, fPos, fNormal);
    result+=calculateLight(light4, material, viewPos, fPos, fNormal);

    result+=calculateDirectionalLight(directionalLight, material, viewPos, fPos, fNormal);
    result+=world_color*material.diffuse;

    //FragColor = vec4(result, 1.0);
    FragColor = texture(modelTexture, fTexCoords) * vec4(result, 1.0);
}