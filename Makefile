./bin/Linux/main: src/main.cpp src/glad.c src/textrendering.cpp include/matrices.h include/utils.h include/dejavufont.h src/shader_vertex.glsl src/shader_fragment.glsl src/tiny_obj_loader.cpp
	mkdir -p bin/Linux
	g++ -std=c++11 -Wall -Wno-unused-function -g -I ./include/ -o ./bin/Linux/main src/main.cpp src/glad.c src/textrendering.cpp src/tiny_obj_loader.cpp -L./lib-linux/ ./lib-linux/libglfw3.a ./lib-linux/libIrrKlang.so -lrt -lm -ldl -lX11 -lpthread -lXrandr -lXinerama -lXxf86vm -lXcursor

.PHONY: clean run
clean:
	rm -f bin/Linux/main

run: ./bin/Linux/main
	cd bin/Linux && ./main
