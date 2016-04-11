#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
#include <hl.h>

extern "C" vbyte *hl_kore_create_vertexshader(vbyte *data, int length) {
	return (vbyte*)new Kore::Shader(data, length, Kore::VertexShader);
}

extern "C" vbyte *hl_kore_create_fragmentshader(vbyte *data, int length) {
	return (vbyte*)new Kore::Shader(data, length, Kore::FragmentShader);
}

extern "C" vbyte *hl_kore_create_program() {
	return (vbyte*)new Kore::Program();
}

extern "C" void hl_kore_program_set_vertex_shader(vbyte *program, vbyte *shader) {
	Kore::Program* prog = (Kore::Program*)program;
	Kore::Shader* sh = (Kore::Shader*)shader;
	prog->setVertexShader(sh);
}

extern "C" void hl_kore_program_set_fragment_shader(vbyte *program, vbyte *shader) {
	Kore::Program* prog = (Kore::Program*)program;
	Kore::Shader* sh = (Kore::Shader*)shader;
	prog->setFragmentShader(sh);
}

extern "C" void hl_kore_program_link(vbyte *program, vbyte *structure) {
	Kore::Program* prog = (Kore::Program*)program;
	Kore::VertexStructure* struc = (Kore::VertexStructure*)structure;
	prog->link(*struc);
}

extern "C" void hl_kore_program_set(vbyte *program) {
	Kore::Program* prog = (Kore::Program*)program;
	prog->set();
}

extern "C" vbyte *hl_kore_program_get_constantlocation(vbyte *program, vbyte *name) {
	Kore::Program* prog = (Kore::Program*)program;
	return (vbyte*)new Kore::ConstantLocation(prog->getConstantLocation((char*)name));
}

extern "C" vbyte *hl_kore_program_get_textureunit(vbyte *program, vbyte *name) {
	Kore::Program* prog = (Kore::Program*)program;
	return (vbyte*)new Kore::TextureUnit(prog->getTextureUnit((char*)name));
}
