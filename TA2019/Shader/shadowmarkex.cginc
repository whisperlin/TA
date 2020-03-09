
/*
UNITY_VERTEX_INPUT_INSTANCE_ID
UNITY_VERTEX_INPUT_INSTANCE_ID

vs:

#if COMBINE_SHADOWMARK
UNITY_SETUP_INSTANCE_ID(v);
UNITY_TRANSFER_INSTANCE_ID(v, o);
#endif

fs:
#if COMBINE_SHADOWMARK
			UNITY_SETUP_INSTANCE_ID(i);
#endif


GETLIGHTMAP(i.uv1)

#if    SHADOWS_SHADOWMASK
_LightColor0.rgb *= attenuation;
c.rgb *= lightmap;
*/

#if COMBINE_SHADOWMARK

#pragma multi_compile_instancing
UNITY_INSTANCING_BUFFER_START(MyShadoeMarkProperties)
UNITY_DEFINE_INSTANCED_PROP(float, _lightMapIndex)
UNITY_INSTANCING_BUFFER_END(MyShadoeMarkProperties)
UNITY_DECLARE_TEX2DARRAY(CmbShadowMark);
#endif




#if    SHADOWS_SHADOWMASK 
	#define GETSHAOWMARK(uv) float attenuation = UNITY_SAMPLE_TEX2D(unity_ShadowMask, uv).r;
#else
	#define GETSHAOWMARK(uv)  float attenuation =   saturate( dot(lightmap,float3(0.3,0.6,0.1)) );attenuation = attenuation*attenuation;attenuation = attenuation*attenuation;
#endif


#if COMBINE_SHADOWMARK
	#define GETLIGHTMAP(uv)\
	int l_lightMapIndex = UNITY_ACCESS_INSTANCED_PROP(MyShadoeMarkProperties, _lightMapIndex);\
	fixed4 lightmap = UNITY_SAMPLE_TEX2DARRAY(CmbShadowMark, float3(uv, l_lightMapIndex));\
	lightmap.rgb *= 2;\
	float attenuation = lightmap.a;
#else
	#define GETLIGHTMAP(uv)\
	fixed3 lightmap = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, uv));\
	GETSHAOWMARK(uv)
	
#endif