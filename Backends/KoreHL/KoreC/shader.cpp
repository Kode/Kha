#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
#include <hl.h>

extern "C" int hl_kore_create_vertexshader(vbyte *data, int length) {
	return (int)new Kore::Shader(data, length, Kore::VertexShader);
}

extern "C" int hl_kore_create_fragmentshader(vbyte *data, int length) {
	return (int)new Kore::Shader(data, length, Kore::FragmentShader);
}

extern "C" int hl_kore_create_program() {
	return (int)new Kore::Program();
}

extern "C" void hl_kore_program_set_vertex_shader(int program, int shader) {
	Kore::Program* prog = (Kore::Program*)program;
	Kore::Shader* sh = (Kore::Shader*)shader;
	prog->setVertexShader(sh);
}

extern "C" void hl_kore_program_set_fragment_shader(int program, int shader) {
	Kore::Program* prog = (Kore::Program*)program;
	Kore::Shader* sh = (Kore::Shader*)shader;
	prog->setFragmentShader(sh);
}

extern "C" void hl_kore_program_link(int program, int structure) {
	Kore::Program* prog = (Kore::Program*)program;
	Kore::VertexStructure* struc = (Kore::VertexStructure*)structure;
	prog->link(*struc);
}

extern "C" void hl_kore_program_set(int program) {
	Kore::Program* prog = (Kore::Program*)program;
	prog->set();
}

extern "C" int hl_kore_program_get_constantlocation(int program, vbyte *name) {
	Kore::Program* prog = (Kore::Program*)program;
	return (int)new Kore::ConstantLocation(prog->getConstantLocation((char*)name));
}

extern "C" int hl_kore_program_get_textureunit(int program, vbyte *name) {
	Kore::Program* prog = (Kore::Program*)program;
	return (int)new Kore::TextureUnit(prog->getTextureUnit((char*)name));
}
