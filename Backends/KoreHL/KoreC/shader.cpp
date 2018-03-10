#include <Kore/pch.h>
#include <Kore/Graphics4/Graphics.h>
#include <hl.h>

extern "C" vbyte *hl_kore_create_vertexshader(vbyte *data, int length) {
	return (vbyte*)new Kore::Graphics4::Shader(data, length, Kore::Graphics4::VertexShader);
}

extern "C" vbyte *hl_kore_create_fragmentshader(vbyte *data, int length) {
	return (vbyte*)new Kore::Graphics4::Shader(data, length, Kore::Graphics4::FragmentShader);
}

extern "C" vbyte *hl_kore_create_program() {
	return (vbyte*)new Kore::Graphics4::Program();
}

extern "C" void hl_kore_program_set_vertex_shader(vbyte *program, vbyte *shader) {
	Kore::Graphics4::Program* prog = (Kore::Graphics4::Program*)program;
	Kore::Graphics4::Shader* sh = (Kore::Graphics4::Shader*)shader;
	prog->setVertexShader(sh);
}

extern "C" void hl_kore_program_set_fragment_shader(vbyte *program, vbyte *shader) {
	Kore::Graphics4::Program* prog = (Kore::Graphics4::Program*)program;
	Kore::Graphics4::Shader* sh = (Kore::Graphics4::Shader*)shader;
	prog->setFragmentShader(sh);
}

extern "C" void hl_kore_program_link(vbyte *program, vbyte *structure) {
	Kore::Graphics4::Program* prog = (Kore::Graphics4::Program*)program;
	Kore::Graphics4::VertexStructure* struc = (Kore::Graphics4::VertexStructure*)structure;
	prog->link(*struc);
}

extern "C" void hl_kore_program_set(vbyte *program) {
	Kore::Graphics4::Program* prog = (Kore::Graphics4::Program*)program;
	prog->set();
}

extern "C" vbyte *hl_kore_program_get_constantlocation(vbyte *program, vbyte *name) {
	Kore::Graphics4::Program* prog = (Kore::Graphics4::Program*)program;
	return (vbyte*)new Kore::Graphics4::ConstantLocation(prog->getConstantLocation((char*)name));
}

extern "C" vbyte *hl_kore_program_get_textureunit(vbyte *program, vbyte *name) {
	Kore::Graphics4::Program* prog = (Kore::Graphics4::Program*)program;
	return (vbyte*)new Kore::Graphics4::TextureUnit(prog->getTextureUnit((char*)name));
}
