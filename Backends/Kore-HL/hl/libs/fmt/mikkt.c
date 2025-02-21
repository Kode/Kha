#define HL_NAME(n) fmt_##n
#include <mikktspace.h>
#include <hl.h>

typedef struct {
	hl_type *t;
	float *buffer;
	int stride;
	int xpos;
	int normalPos;
	int uvPos;
	float *tangents;
	int tangentsStride;
	int tangentPos;
	int *indexes;
	int indices;
} user_info;

typedef const SMikkTSpaceContext Mikkt;

static int get_num_faces( Mikkt *ctx ) {
	user_info *i = (user_info*)ctx->m_pUserData;
	return i->indices / 3;
}

static int get_num_vertices( Mikkt *ctx, int face ) {
	return 3;
}

static void get_position( Mikkt *ctx, float fvPosOut[], const int iFace, const int iVert ) {
	user_info *i = (user_info*)ctx->m_pUserData;
	int idx = iFace * 3 + iVert;
	int v = i->indexes[idx];
	int p = v * i->stride + i->xpos;
	fvPosOut[0] = i->buffer[p++];
	fvPosOut[1] = i->buffer[p++];
	fvPosOut[2] = i->buffer[p++];
}

static void get_normal( Mikkt *ctx, float fvPosOut[], const int iFace, const int iVert ) {
	user_info *i = (user_info*)ctx->m_pUserData;
	int idx = iFace * 3 + iVert;
	int v = i->indexes[idx];
	int p = v * i->stride + i->normalPos;
	fvPosOut[0] = i->buffer[p++];
	fvPosOut[1] = i->buffer[p++];
	fvPosOut[2] = i->buffer[p++];
}

static void get_tcoord( Mikkt *ctx, float fvPosOut[], const int iFace, const int iVert ) {
	user_info *i = (user_info*)ctx->m_pUserData;
	int idx = iFace * 3 + iVert;
	int v = i->indexes[idx];
	int p = v * i->stride + i->uvPos;
	fvPosOut[0] = i->buffer[p++];
	fvPosOut[1] = i->buffer[p++];	
}

static void set_tangent( Mikkt *ctx, const float fvTangent[], const float fSign, const int iFace, const int iVert ) {
	user_info *i = (user_info*)ctx->m_pUserData;
	int idx = iFace * 3 + iVert;
	int p = idx * i->tangentsStride + i->tangentPos;
	i->tangents[p++] = fvTangent[0];
	i->tangents[p++] = fvTangent[1];
	i->tangents[p++] = fvTangent[2];
	i->tangents[p++] = fSign;
}

HL_PRIM bool HL_NAME(compute_mikkt_tangents)( user_info *inf, double threshold ) {
	SMikkTSpaceContext ctx;
	SMikkTSpaceInterface intf;
	intf.m_getNumFaces = get_num_faces;
	intf.m_getNumVerticesOfFace = get_num_vertices;
	intf.m_getPosition = get_position;
	intf.m_getNormal = get_normal;
	intf.m_getTexCoord = get_tcoord;
	intf.m_setTSpaceBasic = set_tangent;
	intf.m_setTSpace = NULL;
	ctx.m_pInterface = &intf;
	ctx.m_pUserData = inf;
	return genTangSpace(&ctx, (float)threshold);
}

DEFINE_PRIM(_BOOL, compute_mikkt_tangents, _DYN _F64);
