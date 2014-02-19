/*
uniform sampler2D DiffuseSampler;
uniform sampler2D shadowSampler;
uniform sampler2D normalmap;
uniform sampler2D ambientmap;
uniform sampler2D environmentmap;
uniform bool texturing;
uniform bool lighting;
uniform bool shadows;
uniform bool normalmapping;
uniform bool ambienOcclusion;
uniform bool environmentmapping;
uniform bool fog;
uniform vec4 lightDir;
uniform float shininess;
uniform vec4 emissiveColor;
uniform vec4 lightColor;
uniform vec4 ambientColor;
uniform vec4 diffuseColor;
uniform vec4 specularColor;
uniform float specularFactor;
uniform vec4 eyePos;

varying vec4 in_col;
varying vec2 in_vTex;
varying vec4 in_worldPosition;
varying vec3 in_normal;
varying vec4 in_positionFromLight;
varying vec3 in_tangent;
varying vec4 in_clipPosition;

#define BLOCKER_SEARCH_NUM_SAMPLES 16 
#define PCF_NUM_SAMPLES 16 
#define NEAR_PLANE 9.5 
#define LIGHT_WORLD_SIZE .002 
#define LIGHT_FRUSTUM_WIDTH 3.75 
// Assuming that LIGHT_FRUSTUM_WIDTH == LIGHT_FRUSTUM_HEIGHT 
#define LIGHT_SIZE_UV (LIGHT_WORLD_SIZE / LIGHT_FRUSTUM_WIDTH) 
//Texture2D<float> tDepthMap;

vec2 getPoisson(int i) {
	switch (i) {
	case 0: return vec2( -0.94201624, -0.39906216 );
	case 1: return vec2( 0.94558609, -0.76890725 );
	case 2: return vec2( -0.094184101, -0.92938870 );
	case 3: return vec2( 0.34495938, 0.29387760 );
	case 4: return vec2( -0.91588581, 0.45771432 );
	case 5: return vec2( -0.81544232, -0.87912464 );
	case 6: return vec2( -0.38277543, 0.27676845 );
	case 7: return vec2( 0.97484398, 0.75648379 );
	case 8: return vec2( 0.44323325, -0.97511554 );
	case 9: return vec2( 0.53742981, -0.47373420 );
	case 10: return vec2( -0.26496911, -0.41893023 );
	case 11: return vec2( 0.79197514, 0.19090188 );
	case 12: return vec2( -0.24188840, 0.99706507 );
	case 13: return vec2( -0.81409955, 0.91437590 );
	case 14: return vec2( 0.19984126, 0.78641367 );
	case 15: return vec2( 0.14383161, -0.14100790 );
	}
	return vec2(0, 0);
}

//Parallel plane estimation
float PenumbraSize(float zReceiver, float zBlocker) {
	return (zReceiver - zBlocker) / zBlocker;
}

void FindBlocker(out float avgBlockerDepth, out float numBlockers, float2 uv, float zReceiver) {
	//This uses similar triangles to compute what
	//area of the shadow map we should search
	float searchWidth = LIGHT_SIZE_UV * (zReceiver - NEAR_PLANE) / zReceiver;
	float blockerSum = 0;
	numBlockers = 0;

	for (int i = 0; i < BLOCKER_SEARCH_NUM_SAMPLES; ++i) {
		float shadowMapDepth = tex2D(shadowSampler, uv + getPoisson(i) * searchWidth).r;
		if (shadowMapDepth < zReceiver) {
			blockerSum += shadowMapDepth;
			++numBlockers;
		}
	}
	avgBlockerDepth = blockerSum / numBlockers;
}

float PCF_Filter(vec2 uv, float zReceiver, float filterRadiusUV) {
	float sum = 0.0;
	for (int i = 0; i < PCF_NUM_SAMPLES; ++i) {
		vec2 offset = getPoisson(i) * filterRadiusUV;
		//float2 offset = float2(0.001*i, 0.001*i);
		float sample = tex2D(shadowSampler, uv + offset).r;
		if (sample > zReceiver) sum += 1;
		//sum += tDepthMap.SampleCmpLevelZero(PCF_Sampler, uv + offset, zReceiver);
	}
	return sum / PCF_NUM_SAMPLES;
}

float PCSS(vec3 coords) {
	vec2 uv = coords.xy;
	float zReceiver = coords.z; // Assumed to be eye-space z in this code
	
	// STEP 1: blocker search
	float avgBlockerDepth = 0;
	float numBlockers = 0;
	FindBlocker(avgBlockerDepth, numBlockers, uv, zReceiver);
	if (numBlockers < 1) //There are no occluders so early out (this saves filtering)
		return 1.0f; 
	// STEP 2: penumbra size
	float penumbraRatio = PenumbraSize(zReceiver, avgBlockerDepth);     
	float filterRadiusUV = penumbraRatio * LIGHT_SIZE_UV * NEAR_PLANE / coords.z; 
	
	// STEP 3: filtering 
	return PCF_Filter(uv, zReceiver, filterRadiusUV);
}
*/
void kore() {
	gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
	/*
	float shadowX;
	float shadowY;
	float shadowZ;
	//float4 shadow;

	if (shadows) {
		shadowX = in_positionFromLight.x / in_positionFromLight.w;
		shadowY = in_positionFromLight.y / in_positionFromLight.w;
		shadowZ = in_positionFromLight.z / in_positionFromLight.w;
		//shadow = tex2D(shadowSampler, vec2((shadowX + 1) * 0.5, 1 - (shadowY + 1) * 0.5));
	}

	vec3 normal = normalize(in_normal);
	if (normalmapping) {
		vec3 tangentnormal = tex2D(normalmap, in_vTex).rgb * 2 - 1;
		normal.x = dot(tangentnormal, cross(in_tangent, in_normal));
		normal.y = dot(tangentnormal, in_tangent);
		normal.z = dot(tangentnormal, in_normal);
		normal = normalize(normal);
	}

	vec4 col = in_col;
	float alpha = 1;
	if (lighting) {
		vec3 surfaceToLight = -lightDir.xyz;
		vec3 surfaceToView = normalize((eyePos - In.worldPosition).xyz);
		vec3 halfVector = normalize(surfaceToLight + surfaceToView);
		vec4 litR = lit(dot(normal, surfaceToLight), dot(normal, halfVector), shininess);
		if (shadows) {
			if (shadowX >= -1 && shadowX <= 1 && shadowY >= -1 && shadowY <= 1) { // && shadow.r <= shadowZ - 0.1) {
				float shadow = PCSS(vec3((shadowX + 1) * 0.5, 1 - (shadowY + 1) * 0.5, shadowZ - 0.001));
				litR.y *= shadow;
				litR.z *= shadow;
			}
		}
		vec4 texColor = vec4(1, 1, 1, 1);
		if (texturing) {
			texColor = tex2D(DiffuseSampler, In.vTex);
			alpha = texColor.a;
			texColor += vec4(0, 0, 0, 1);
		}
		vec4 ambient = ambientColor;
		if (ambienOcclusion) {
			ambient /= 3.0;
			ambient += tex2D(ambientmap, vec2((in_clipPosition.x / in_clipPosition.w + 1) * 0.5, (-in_clipPosition.y / in_clipPosition.w + 1) * 0.5));
		}
		if (environmentmapping) {
			vec3 u = -surfaceToView;
			vec3 n = normal;
			vec3 r = reflect(u, n);
			float m = 2.0 * sqrt(r.x * r.x + r.y * r.y + (r.z + 1.0) * (r.z + 1.0));
			float tu = r.x / m + 0.5;
			float tv = r.y / m + 0.5;
			vec4 reflection = tex2D(environmentmap, vec2(tu, tv));
			litR *= reflection;
		}
		col = vec4((emissiveColor + lightColor * (texColor * ambient * litR.x + texColor * diffuseColor * litR.y + specularColor * litR.z * specularFactor)).rgb, diffuseColor.a);
	}
	
	if (fog) {
		in_clipPosition.z = in_clipPosition.z / in_clipPosition.w;
		float fogintensity = 0.9975;
		if (In.clipPosition.z > fogintensity) {
			float div = In.clipPosition.z - fogintensity;
			div *= 1 / (1 - fogintensity) / 1.5;
			col = vec4(0.1, 0.1, 1, 1) * div + col * (1 - div);
		}

		col.w = 1.0;
	}

	col.a = alpha;
	return col;
	*/
}
