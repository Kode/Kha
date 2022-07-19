#include <kinc/graphics4/graphics.h>
#include <kinc/graphics4/pipeline.h>
#include <kinc/graphics4/shader.h>
#include <kinc/graphics4/vertexstructure.h>

#include <hl.h>

static kinc_g4_compare_mode_t convertCompareMode(int mode) {
	switch (mode) {
	case 0:
		return KINC_G4_COMPARE_ALWAYS;
	case 1:
		return KINC_G4_COMPARE_NEVER;
	case 2:
		return KINC_G4_COMPARE_EQUAL;
	case 3:
		return KINC_G4_COMPARE_NOT_EQUAL;
	case 4:
		return KINC_G4_COMPARE_LESS;
	case 5:
		return KINC_G4_COMPARE_LESS_EQUAL;
	case 6:
		return KINC_G4_COMPARE_GREATER;
	case 7:
	default:
		return KINC_G4_COMPARE_GREATER_EQUAL;
	}
}

static kinc_g4_stencil_action_t convertStencilAction(int action) {
	switch (action) {
	case 0:
		return KINC_G4_STENCIL_KEEP;
	case 1:
		return KINC_G4_STENCIL_ZERO;
	case 2:
		return KINC_G4_STENCIL_REPLACE;
	case 3:
		return KINC_G4_STENCIL_INCREMENT;
	case 4:
		return KINC_G4_STENCIL_INCREMENT_WRAP;
	case 5:
		return KINC_G4_STENCIL_DECREMENT;
	case 6:
		return KINC_G4_STENCIL_DECREMENT_WRAP;
	case 7:
	default:
		return KINC_G4_STENCIL_INVERT;
	}
}

static kinc_g4_render_target_format_t convertColorAttachment(int format) {
	switch (format) {
	case 0:
		return KINC_G4_RENDER_TARGET_FORMAT_32BIT;
	case 1:
		return KINC_G4_RENDER_TARGET_FORMAT_8BIT_RED;
	case 2:
		return KINC_G4_RENDER_TARGET_FORMAT_128BIT_FLOAT;
	case 3:
		return KINC_G4_RENDER_TARGET_FORMAT_16BIT_DEPTH;
	case 4:
		return KINC_G4_RENDER_TARGET_FORMAT_64BIT_FLOAT;
	case 5:
		return KINC_G4_RENDER_TARGET_FORMAT_32BIT_RED_FLOAT;
	case 6:
	default:
		return KINC_G4_RENDER_TARGET_FORMAT_16BIT_RED_FLOAT;
	}
}

vbyte *hl_kore_create_vertexshader(vbyte *data, int length) {
	kinc_g4_shader_t *shader = (kinc_g4_shader_t *)malloc(sizeof(kinc_g4_shader_t));
	kinc_g4_shader_init(shader, data, length, KINC_G4_SHADER_TYPE_VERTEX);
	return (vbyte *)shader;
}

vbyte *hl_kore_create_fragmentshader(vbyte *data, int length) {
	kinc_g4_shader_t *shader = (kinc_g4_shader_t *)malloc(sizeof(kinc_g4_shader_t));
	kinc_g4_shader_init(shader, data, length, KINC_G4_SHADER_TYPE_FRAGMENT);
	return (vbyte *)shader;
}

vbyte *hl_kore_create_geometryshader(vbyte *data, int length) {
	kinc_g4_shader_t *shader = (kinc_g4_shader_t *)malloc(sizeof(kinc_g4_shader_t));
	kinc_g4_shader_init(shader, data, length, KINC_G4_SHADER_TYPE_GEOMETRY);
	return (vbyte *)shader;
}

vbyte *hl_kore_create_tesscontrolshader(vbyte *data, int length) {
	kinc_g4_shader_t *shader = (kinc_g4_shader_t *)malloc(sizeof(kinc_g4_shader_t));
	kinc_g4_shader_init(shader, data, length, KINC_G4_SHADER_TYPE_TESSELLATION_CONTROL);
	return (vbyte *)shader;
}

vbyte *hl_kore_create_tessevalshader(vbyte *data, int length) {
	kinc_g4_shader_t *shader = (kinc_g4_shader_t *)malloc(sizeof(kinc_g4_shader_t));
	kinc_g4_shader_init(shader, data, length, KINC_G4_SHADER_TYPE_TESSELLATION_EVALUATION);
	return (vbyte *)shader;
}

vbyte *hl_kore_vertexshader_from_source(vbyte *source) {
	kinc_g4_shader_t *shader = (kinc_g4_shader_t *)malloc(sizeof(kinc_g4_shader_t));
	kinc_g4_shader_init_from_source(shader, (char *)source, KINC_G4_SHADER_TYPE_VERTEX);
	return (vbyte *)shader;
}

vbyte *hl_kore_fragmentshader_from_source(vbyte *source) {
	kinc_g4_shader_t *shader = (kinc_g4_shader_t *)malloc(sizeof(kinc_g4_shader_t));
	kinc_g4_shader_init_from_source(shader, (char *)source, KINC_G4_SHADER_TYPE_FRAGMENT);
	return (vbyte *)shader;
}

vbyte *hl_kore_geometryshader_from_source(vbyte *source) {
	kinc_g4_shader_t *shader = (kinc_g4_shader_t *)malloc(sizeof(kinc_g4_shader_t));
	kinc_g4_shader_init_from_source(shader, (char *)source, KINC_G4_SHADER_TYPE_GEOMETRY);
	return (vbyte *)shader;
}

vbyte *hl_kore_tesscontrolshader_from_source(vbyte *source) {
	kinc_g4_shader_t *shader = (kinc_g4_shader_t *)malloc(sizeof(kinc_g4_shader_t));
	kinc_g4_shader_init_from_source(shader, (char *)source, KINC_G4_SHADER_TYPE_TESSELLATION_CONTROL);
	return (vbyte *)shader;
}

vbyte *hl_kore_tessevalshader_from_source(vbyte *source) {
	kinc_g4_shader_t *shader = (kinc_g4_shader_t *)malloc(sizeof(kinc_g4_shader_t));
	kinc_g4_shader_init_from_source(shader, (char *)source, KINC_G4_SHADER_TYPE_TESSELLATION_EVALUATION);
	return (vbyte *)shader;
}

vbyte *hl_kore_create_pipeline() {
	kinc_g4_pipeline_t *pipeline = (kinc_g4_pipeline_t *)malloc(sizeof(kinc_g4_pipeline_t));
	kinc_g4_pipeline_init(pipeline);
	return (vbyte *)pipeline;
}

void hl_kore_delete_pipeline(vbyte *pipeline) {
	kinc_g4_pipeline_t *pipe = (kinc_g4_pipeline_t *)pipeline;
	kinc_g4_pipeline_destroy(pipe);
	free(pipe);
}

void hl_kore_pipeline_set_vertex_shader(vbyte *pipeline, vbyte *shader) {
	kinc_g4_pipeline_t *pipe = (kinc_g4_pipeline_t *)pipeline;
	kinc_g4_shader_t *sh = (kinc_g4_shader_t *)shader;
	pipe->vertex_shader = sh;
}

void hl_kore_pipeline_set_fragment_shader(vbyte *pipeline, vbyte *shader) {
	kinc_g4_pipeline_t *pipe = (kinc_g4_pipeline_t *)pipeline;
	kinc_g4_shader_t *sh = (kinc_g4_shader_t *)shader;
	pipe->fragment_shader = sh;
}

void hl_kore_pipeline_set_geometry_shader(vbyte *pipeline, vbyte *shader) {
	kinc_g4_pipeline_t *pipe = (kinc_g4_pipeline_t *)pipeline;
	kinc_g4_shader_t *sh = (kinc_g4_shader_t *)shader;
	pipe->geometry_shader = sh;
}

void hl_kore_pipeline_set_tesscontrol_shader(vbyte *pipeline, vbyte *shader) {
	kinc_g4_pipeline_t *pipe = (kinc_g4_pipeline_t *)pipeline;
	kinc_g4_shader_t *sh = (kinc_g4_shader_t *)shader;
	pipe->tessellation_control_shader = sh;
}

void hl_kore_pipeline_set_tesseval_shader(vbyte *pipeline, vbyte *shader) {
	kinc_g4_pipeline_t *pipe = (kinc_g4_pipeline_t *)pipeline;
	kinc_g4_shader_t *sh = (kinc_g4_shader_t *)shader;
	pipe->tessellation_evaluation_shader = sh;
}

void hl_kore_pipeline_compile(vbyte *pipeline, vbyte *structure0, vbyte *structure1, vbyte *structure2, vbyte *structure3) {
	kinc_g4_pipeline_t *pipe = (kinc_g4_pipeline_t *)pipeline;
	pipe->input_layout[0] = (kinc_g4_vertex_structure_t *)structure0;
	pipe->input_layout[1] = (kinc_g4_vertex_structure_t *)structure1;
	pipe->input_layout[2] = (kinc_g4_vertex_structure_t *)structure2;
	pipe->input_layout[3] = (kinc_g4_vertex_structure_t *)structure3;
	pipe->input_layout[4] = NULL;
	kinc_g4_pipeline_compile(pipe);
}

void hl_kore_pipeline_set_states(vbyte *pipeline, int cullMode, int depthMode, int stencilFrontMode, int stencilFrontBothPass, int stencilFrontDepthFail,
                                 int stencilFrontFail, int stencilBackMode, int stencilBackBothPass, int stencilBackDepthFail, int stencilBackFail,
                                 int blendSource, int blendDestination, int alphaBlendSource, int alphaBlendDestination, bool depthWrite,
                                 int stencilReferenceValue, int stencilReadMask, int stencilWriteMask, bool colorWriteMaskRed, bool colorWriteMaskGreen,
                                 bool colorWriteMaskBlue, bool colorWriteMaskAlpha, int colorAttachmentCount, int colorAttachment0, int colorAttachment1,
                                 int colorAttachment2, int colorAttachment3, int colorAttachment4, int colorAttachment5, int colorAttachment6,
                                 int colorAttachment7, int depthAttachmentBits, int stencilAttachmentBits, bool conservativeRasterization) {
	kinc_g4_pipeline_t *pipe = (kinc_g4_pipeline_t *)pipeline;

	switch (cullMode) {
	case 0:
		pipe->cull_mode = KINC_G4_CULL_CLOCKWISE;
		break;
	case 1:
		pipe->cull_mode = KINC_G4_CULL_COUNTER_CLOCKWISE;
		break;
	case 2:
		pipe->cull_mode = KINC_G4_CULL_NOTHING;
		break;
	}

	pipe->depth_mode = convertCompareMode(depthMode);
	pipe->depth_write = depthWrite;

	pipe->stencil_front_mode = convertCompareMode(stencilFrontMode);
	pipe->stencil_front_both_pass = convertStencilAction(stencilFrontBothPass);
	pipe->stencil_front_depth_fail = convertStencilAction(stencilFrontDepthFail);
	pipe->stencil_front_fail = convertStencilAction(stencilFrontFail);

	pipe->stencil_back_mode = convertCompareMode(stencilBackMode);
	pipe->stencil_back_both_pass = convertStencilAction(stencilBackBothPass);
	pipe->stencil_back_depth_fail = convertStencilAction(stencilBackDepthFail);
	pipe->stencil_back_fail = convertStencilAction(stencilBackFail);

	pipe->stencil_reference_value = stencilReferenceValue;
	pipe->stencil_read_mask = stencilReadMask;
	pipe->stencil_write_mask = stencilWriteMask;

	pipe->blend_source = (kinc_g4_blending_factor_t)blendSource;
	pipe->blend_destination = (kinc_g4_blending_factor_t)blendDestination;
	pipe->alpha_blend_source = (kinc_g4_blending_factor_t)alphaBlendSource;
	pipe->alpha_blend_destination = (kinc_g4_blending_factor_t)alphaBlendDestination;

	pipe->color_write_mask_red[0] = colorWriteMaskRed;
	pipe->color_write_mask_green[0] = colorWriteMaskGreen;
	pipe->color_write_mask_blue[0] = colorWriteMaskBlue;
	pipe->color_write_mask_alpha[0] = colorWriteMaskAlpha;

	pipe->color_attachment_count = colorAttachmentCount;
	pipe->color_attachment[0] = convertColorAttachment(colorAttachment0);
	pipe->color_attachment[1] = convertColorAttachment(colorAttachment1);
	pipe->color_attachment[2] = convertColorAttachment(colorAttachment2);
	pipe->color_attachment[3] = convertColorAttachment(colorAttachment3);
	pipe->color_attachment[4] = convertColorAttachment(colorAttachment4);
	pipe->color_attachment[5] = convertColorAttachment(colorAttachment5);
	pipe->color_attachment[6] = convertColorAttachment(colorAttachment6);
	pipe->color_attachment[7] = convertColorAttachment(colorAttachment7);

	pipe->depth_attachment_bits = depthAttachmentBits;
	pipe->stencil_attachment_bits = stencilAttachmentBits;

	pipe->conservative_rasterization = conservativeRasterization;
}

void hl_kore_pipeline_set(vbyte *pipeline) {
	kinc_g4_pipeline_t *pipe = (kinc_g4_pipeline_t *)pipeline;
	kinc_g4_set_pipeline(pipe);
}

vbyte *hl_kore_pipeline_get_constantlocation(vbyte *pipeline, vbyte *name) {
	kinc_g4_pipeline_t *pipe = (kinc_g4_pipeline_t *)pipeline;
	kinc_g4_constant_location_t *location = (kinc_g4_constant_location_t *)malloc(sizeof(kinc_g4_constant_location_t));
	*location = kinc_g4_pipeline_get_constant_location(pipe, (char *)name);
	return (vbyte *)location;
}

vbyte *hl_kore_pipeline_get_textureunit(vbyte *pipeline, vbyte *name) {
	kinc_g4_pipeline_t *pipe = (kinc_g4_pipeline_t *)pipeline;
	kinc_g4_texture_unit_t *unit = (kinc_g4_texture_unit_t *)malloc(sizeof(kinc_g4_texture_unit_t));
	*unit = kinc_g4_pipeline_get_texture_unit(pipe, (char *)name);
	return (vbyte *)unit;
}
