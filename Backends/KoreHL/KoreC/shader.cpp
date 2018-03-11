#include <Kore/pch.h>
#include <Kore/Graphics4/Graphics.h>
#include <Kore/Graphics4/PipelineState.h>
#include <hl.h>

extern "C" vbyte *hl_kore_create_vertexshader(vbyte *data, int length) {
	return (vbyte*)new Kore::Graphics4::Shader(data, length, Kore::Graphics4::VertexShader);
}

extern "C" vbyte *hl_kore_create_fragmentshader(vbyte *data, int length) {
	return (vbyte*)new Kore::Graphics4::Shader(data, length, Kore::Graphics4::FragmentShader);
}

extern "C" vbyte *hl_kore_create_pipeline() {
	return (vbyte*)new Kore::Graphics4::PipelineState();
}

extern "C" void hl_kore_pipeline_set_vertex_shader(vbyte *pipeline, vbyte *shader) {
	Kore::Graphics4::PipelineState* pipe = (Kore::Graphics4::PipelineState*)pipeline;
	Kore::Graphics4::Shader* sh = (Kore::Graphics4::Shader*)shader;
	pipe->vertexShader = sh;
}

extern "C" void hl_kore_pipeline_set_fragment_shader(vbyte *pipeline, vbyte *shader) {
	Kore::Graphics4::PipelineState* pipe = (Kore::Graphics4::PipelineState*)pipeline;
	Kore::Graphics4::Shader* sh = (Kore::Graphics4::Shader*)shader;
	pipe->fragmentShader = sh;
}

extern "C" void hl_kore_pipeline_compile(vbyte *pipeline, vbyte *structure) {
	Kore::Graphics4::PipelineState* pipe = (Kore::Graphics4::PipelineState*)pipeline;
	Kore::Graphics4::VertexStructure* struc = (Kore::Graphics4::VertexStructure*)structure;
	//pipe->inputLayout = struc; // TODO
	pipe->compile();
}

extern "C" void hl_kore_pipeline_set(vbyte *pipeline) {
	Kore::Graphics4::PipelineState* pipe = (Kore::Graphics4::PipelineState*)pipeline;
	Kore::Graphics4::setPipeline(pipe);
}

extern "C" vbyte *hl_kore_pipeline_get_constantlocation(vbyte *pipeline, vbyte *name) {
	Kore::Graphics4::PipelineState* pipe = (Kore::Graphics4::PipelineState*)pipeline;
	return (vbyte*)new Kore::Graphics4::ConstantLocation(pipe->getConstantLocation((char*)name));
}

extern "C" vbyte *hl_kore_pipeline_get_textureunit(vbyte *pipeline, vbyte *name) {
	Kore::Graphics4::PipelineState* pipe = (Kore::Graphics4::PipelineState*)pipeline;
	return (vbyte*)new Kore::Graphics4::TextureUnit(pipe->getTextureUnit((char*)name));
}
