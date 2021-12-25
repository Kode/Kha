#pragma once

#include <kinc/graphics4/vertexstructure.h>

#include <assert.h>

#ifdef __cplusplus
extern "C" {
#endif

static inline kinc_g4_vertex_data_t kha_convert_vertex_data(int data) {
	switch (data) {
	case 0: // Float32_1X
		return KINC_G4_VERTEX_DATA_F32_1X;
	case 1: // Float32_2X
		return KINC_G4_VERTEX_DATA_F32_2X;
	case 2: // Float32_3X
		return KINC_G4_VERTEX_DATA_F32_3X;
	case 3: // Float32_4X
		return KINC_G4_VERTEX_DATA_F32_4X;
	case 4: // Float32_4X4
		return KINC_G4_VERTEX_DATA_F32_4X4;
	case 5: // Int8_1X
		return KINC_G4_VERTEX_DATA_I8_1X;
	case 6: // UInt8_1X
		return KINC_G4_VERTEX_DATA_U8_1X;
	case 7: // Int8_1X_Normalized
		return KINC_G4_VERTEX_DATA_I8_1X_NORMALIZED;
	case 8: // UInt8_1X_Normalized
		return KINC_G4_VERTEX_DATA_U8_1X_NORMALIZED;
	case 9: // Int8_2X
		return KINC_G4_VERTEX_DATA_I8_2X;
	case 10: // UInt8_2X
		return KINC_G4_VERTEX_DATA_U8_2X;
	case 11: // Int8_2X_Normalized
		return KINC_G4_VERTEX_DATA_I8_2X_NORMALIZED;
	case 12: // UInt8_2X_Normalized
		return KINC_G4_VERTEX_DATA_U8_2X_NORMALIZED;
	case 13: // Int8_4X
		return KINC_G4_VERTEX_DATA_I8_4X;
	case 14: // UInt8_4X
		return KINC_G4_VERTEX_DATA_U8_4X;
	case 15: // Int8_4X_Normalized
		return KINC_G4_VERTEX_DATA_I8_4X_NORMALIZED;
	case 16: // UInt8_4X_Normalized
		return KINC_G4_VERTEX_DATA_U8_4X_NORMALIZED;
	case 17: // Int16_1X
		return KINC_G4_VERTEX_DATA_I16_1X;
	case 18: // UInt16_1X
		return KINC_G4_VERTEX_DATA_U16_1X;
	case 19: // Int16_1X_Normalized
		return KINC_G4_VERTEX_DATA_I16_1X_NORMALIZED;
	case 20: // UInt16_1X_Normalized
		return KINC_G4_VERTEX_DATA_U16_1X_NORMALIZED;
	case 21: // Int16_2X
		return KINC_G4_VERTEX_DATA_I16_2X;
	case 22: // UInt16_2X
		return KINC_G4_VERTEX_DATA_U16_2X;
	case 23: // Int16_2X_Normalized
		return KINC_G4_VERTEX_DATA_I16_2X_NORMALIZED;
	case 24: // UInt16_2X_Normalized
		return KINC_G4_VERTEX_DATA_U16_2X_NORMALIZED;
	case 25: // Int16_4X
		return KINC_G4_VERTEX_DATA_I16_4X;
	case 26: // UInt16_4X
		return KINC_G4_VERTEX_DATA_U16_4X;
	case 27: // Int16_4X_Normalized
		return KINC_G4_VERTEX_DATA_I16_4X_NORMALIZED;
	case 28: // UInt16_4X_Normalized
		return KINC_G4_VERTEX_DATA_U16_4X_NORMALIZED;
	case 29: // Int32_1X
		return KINC_G4_VERTEX_DATA_I32_1X;
	case 30: // UInt32_1X
		return KINC_G4_VERTEX_DATA_U32_1X;
	case 31: // Int32_2X
		return KINC_G4_VERTEX_DATA_I32_2X;
	case 32: // UInt32_2X
		return KINC_G4_VERTEX_DATA_U32_2X;
	case 33: // Int32_3X
		return KINC_G4_VERTEX_DATA_I32_3X;
	case 34: // UInt32_3X
		return KINC_G4_VERTEX_DATA_U32_3X;
	case 35: // Int32_4X
		return KINC_G4_VERTEX_DATA_I32_4X;
	case 36: // UInt32_4X
		return KINC_G4_VERTEX_DATA_U32_4X;
	default:
		assert(false);
		return KINC_G4_VERTEX_DATA_NONE;
	}
}

#ifdef __cplusplus
}
#endif
