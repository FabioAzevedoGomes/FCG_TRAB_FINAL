#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpolação da posição global e a normal de cada vértice, definidas em
// "shader_vertex.glsl" e "main.cpp".
in vec4 position_world;
in vec4 normal;

in vec4 position_model;

in vec2 texcoords;
// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto está sendo desenhado no momento
#define MENU_BACKGROUND  0
#define BUNNY            1
#define GRASS_FLOOR      2
#define MIKU             3
#define BULLET           4
#define WALL             5
#define ENEMY_COW        6
#define PROJECTILE       7
#define MEDAL            8
#define DOOR             9
#define SHOW_BACKGROUND 10
#define SHOW_FLOOR      11
#define ENEMY_SHINOBU   12
#define CROSS_BAR       13
#define CHECK_PIECE     14


uniform int object_id;

// Parâmetros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

//Textures
uniform sampler2D TextureImage0;
uniform sampler2D TextureImage1; // Fundo menu
uniform sampler2D TextureImage2;
uniform sampler2D TextureImage3;
uniform sampler2D TextureImage4;
uniform sampler2D TextureImage5; // Fundo show
uniform sampler2D TextureImage6; // Chão do show
uniform sampler2D TextureImage7; // shinobu

// O valor de saída ("out") de um Fragment Shader é a cor final do fragmento.
out vec3 color;

// Constantes
#define M_PI   3.14159265358979323846
#define M_PI_2 1.57079632679489661923

void main()
{
    // Obtemos a posição da câmera utilizando a inversa da matriz que define o
    // sistema de coordenadas da câmera.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;

    // O fragmento atual é coberto por um ponto que percente à superfície de um
    // dos objetos virtuais da cena. Este ponto, p, possui uma posição no
    // sistema de coordenadas global (World coordinates). Esta posição é obtida
    // através da interpolação, feita pelo rasterizador, da posição de cada
    // vértice.
    vec4 p = position_world;

    // Normal do fragmento atual, interpolada pelo rasterizador a partir das
    // normais de cada vértice.
    vec4 n = normalize(normal);

    vec4 light_pos = vec4(0.0f,10.0f,0.0f,1.0f);

    // Vetor que define o sentido da fonte de luz em relação ao ponto atual.
    vec4 l = normalize(light_pos - p);//normalize(vec4(0.5,1.0,0.5,0.0));

    // Vetor que define o sentido da câmera em relação ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // Vetor que define o sentido da reflexão especular ideal.
    vec4 r = -l + 2*n*dot(n,l);//vec4(0.0,0.0,0.0,0.0); // PREENCHA AQUI o vetor de reflexão especular ideal

    // Parâmetros que definem as propriedades espectrais da superfície
    vec3 Kd; // Refletância difusa que será obtida da imagem de textura
    vec3 Ks; // Refletância especular
    vec3 Ka; // Refletância ambiente
    float q; // Expoente especular para o modelo de iluminação de Phong

    float U;    //Coordenadas de textura u e v
    float V;

    if ( object_id == MENU_BACKGROUND )
    {

        vec4 p_lin = camera_position + ((position_world - camera_position)/length(position_world - camera_position));
        vec4 coord_vector = (p_lin - camera_position);
        float theta = atan(coord_vector.x,coord_vector.z);
        float phi = asin(coord_vector.y);

        U = (theta + M_PI)/(2*M_PI);
        V = (phi + M_PI_2)/M_PI;

        Kd = texture(TextureImage1, vec2(U,V)).rgb;

        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 1.0;

        //nvertemos a normal da esfera, para que ela esteja "virada para dentro"
        n = -n;
    }
    else if ( object_id == BUNNY )
    {
        // PREENCHA AQUI
        // Propriedades espectrais do coelho
        Kd = vec3(0.08,0.4,0.8);
        Ks = vec3(0.8,0.8,0.8);
        Ka = vec3(0.04,0.2,0.4);
        q = 32.0;
    }
    else if ( object_id == GRASS_FLOOR )
    {

        U = position_model.x;// - minx)/(maxx - minx);
        V = position_model.z;// - minz)/(maxz - minz);

        //Computa a cor da textura neste ponto
        Kd = texture(TextureImage0, vec2(U,V)).rgb;

        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 20.0;
    }
    else if ( object_id == MIKU)
    {
        Kd = vec3(0.1,0.4,0.6);
        Ks = vec3(0.8,0.8,0.8);
        Ka = vec3(0.05,0.2,0.3);
        q = 30.0;
    }
    else if ( object_id == WALL)
    {

        U = position_model.x;// - minx)/(maxx - minx);
        V = position_model.y;// - minz)/(maxz - minz);

        //Computa a cor da textura neste ponto
        Kd = texture(TextureImage2, vec2(U,V)).rgb;

        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.05,0.2,0.3);
        q = 30.0;
    }
    else if ( object_id == ENEMY_COW)
    {

        vec4 bbox_mid = (bbox_max + bbox_min) / 2;

        vec4 p_lin = bbox_mid + ((position_model - bbox_mid)/length(position_model - bbox_mid));
        vec4 coord_vector = (p_lin - bbox_mid);
        float theta = atan(coord_vector.x,coord_vector.z);
        float phi = asin(coord_vector.y);

        U = (theta + M_PI)/(2*M_PI);
        V = (phi + M_PI_2)/M_PI;

        Kd = texture(TextureImage3, vec2(U,V)).rgb;

        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 20.0;


    }
    else if ( object_id == BULLET)
    {

        Kd = vec3(1.0f,0.0f,0.0f);
        Ks = vec3(0.0f,0.0f,0.0f);
        Ka = vec3(0.0f,0.0f,0.0f);
        q = 1.0;

    }
    else if ( object_id == PROJECTILE)
    {
        /*TODO*/
        Kd = vec3(0.0,0.0,0.0);
        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 1.0;
    }
    else if ( object_id == MEDAL)
    {
        Kd = vec3(0.8431f,0.7176f,0.25f);
        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 10.0;
    }
    else if ( object_id == DOOR)
    {
        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        /*TODO Arrumar textura da porta*/
        U = (position_model.x - minx)/(maxx - minx);
        V = (position_model.z - minz)/(maxz - minz);

        //Computa a cor da textura neste ponto
        Kd = texture(TextureImage4, vec2(U,V)).rgb;
        Ka = vec3(1.0,1.0,1.0);
        Ks = vec3(1.0,1.0,1.0);
        q = 20.0;

    }
    else if ( object_id == SHOW_BACKGROUND)
    {
        vec4 p_lin = camera_position + ((position_world - camera_position)/length(position_world - camera_position));
        vec4 coord_vector = (p_lin - camera_position);
        float theta = atan(coord_vector.x,coord_vector.z);
        float phi = asin(coord_vector.y);

        U = (theta + M_PI)/(2*M_PI);
        V = (phi + M_PI_2)/M_PI;

        Kd = texture(TextureImage5, vec2(U,V)).rgb;

        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 1.0;

        //nvertemos a normal da esfera, para que ela esteja "virada para dentro"
        n = -n;
    }
    else if ( object_id == SHOW_FLOOR)
    {
        U = position_model.x;// - minx)/(maxx - minx);
        V = position_model.z;// - minz)/(maxz - minz);

        //Computa a cor da textura neste ponto
        Kd = texture(TextureImage6, vec2(U,V)).rgb;

        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 1.0;
    }
    else if ( object_id == ENEMY_SHINOBU)
    {

        Kd = texture(TextureImage7, texcoords).rgb;

        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 20.0;
    }
    else if ( object_id == CROSS_BAR)
    {
        Kd = vec3(1.0,0.0,0.0);
        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 1.0;
    }
    else if ( object_id == CHECK_PIECE)
    {
        Kd = vec3(0.0,1.0,0.0);
        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 1.0;
    }
    else // Objeto desconhecido = preto
    {
        Kd = vec3(0.0,0.0,0.0);
        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 1.0;
    }

    // Espectro da fonte de iluminação
    vec3 I = vec3(1.0,1.0,1.0); // PREENCH AQUI o espectro da fonte de luz

    // Espectro da luz ambiente
    vec3 Ia = vec3(0.5,0.5,0.5); // PREENCHA AQUI o espectro da luz ambiente

    // Termo difuso utilizando a lei dos cossenos de Lambert
    vec3 lambert_diffuse_term = Kd*I*max(0,dot(n,l));//vec3(0.0,0.0,0.0); // PREENCHA AQUI o termo difuso de Lambert

    // Termo ambiente
    vec3 ambient_term = Ka*Ia;

    // Termo especular utilizando o modelo de iluminação de Phong
    vec3 phong_specular_term  = Ks*I*pow(max(0,dot(r,v)),q);

    // Cor final do fragmento calculada com uma combinação dos termos difuso,
    // especular, e ambiente. Veja slide 133 do documento "Aula_17_e_18_Modelos_de_Iluminacao.pdf".
    color = lambert_diffuse_term + phong_specular_term;

    // Cor final com correção gamma, considerando monitor sRGB.
    // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
    color = pow(color, vec3(1.0,1.0,1.0)/2.2);

}

