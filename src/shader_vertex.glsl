#version 330 core

layout (location = 0) in vec4 model_coefficients;
layout (location = 1) in vec4 normal_coefficients;
layout (location = 2) in vec2 texture_coefficients;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

uniform int object_id;

out vec4 position_world;
out vec4 position_model;
out vec4 normal;
out vec2 texcoords;

out vec3 gouraud_color;

void main()
{
    gl_Position = projection * view * model * model_coefficients;

    // Posição do vértice atual no sistema de coordenadas global (World).
    position_world = model * model_coefficients;

    // Posição do vértice atual no sistema de coordenadas do modelo
    position_model = model_coefficients;

    // Normal deste vértice
    normal = inverse(transpose(model)) * normal_coefficients;
    normal.w = 0.0;

    // Utilizamos Gouraud Shading para o X nas portas (Equação computada apenas uma vez por vértice)
    #define CROSS_BAR 13
    if (object_id == CROSS_BAR)
    {
        vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
        vec4 camera_position = inverse(view) * origin;

        vec4 light_pos = vec4(0.0f,10.0f,0.0f,1.0f);
        vec4 l = normalize(light_pos - position_world);
        vec4 v = normalize(camera_position - position_world);
        vec4 n = normalize(normal);

        vec3 I = vec3(1.0,1.0,1.0);
        vec3 Ia = vec3(0.1,0.1,0.1);

        vec3 Kd = vec3(1.0,0.0,0.0);

        // Termo difuso utilizando a lei dos cossenos de Lambert
        vec3 lambert_diffuse_term = Kd*I*max(0,dot(n,l));

        // Termo ambiente
        vec3 Ka = vec3(0.1,0.1,0.1);
        vec3 Ks = vec3(0.5,0.2,0.2);
        float q = 1.0;

        vec3 ambient_term = Ka*Ia;

        // Termo especular utilizando o modelo de iluminação de Blinn-Phong
        vec4 h = l + v;
        h = h/length(h);

        vec3 blinn_phong_specular_term = Ks*I*pow(max(0,dot(n,h)),q);

        // Cor final do fragmento
        gouraud_color = lambert_diffuse_term + ambient_term + blinn_phong_specular_term;

    }
    else
    {
        gouraud_color = vec3(0.0,0.0,0.0);
    }

    texcoords = texture_coefficients;
}

