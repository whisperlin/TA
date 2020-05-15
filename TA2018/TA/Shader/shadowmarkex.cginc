#ifndef  __SHADOW_MARK_EX____
#define __SHADOW_MARK_EX____ 1


#if COMBINE_SHADOWMARK
#define SHADOWS_SHADOWMASK 1`
#endif
	/*

	#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

	//#define UNITY_SHADOW 1

	UNITY_VERTEX_INPUT_INSTANCE_ID

	UNITY_VERTEX_INPUT_INSTANCE_ID

	SHADOW_UVS(11,12)


	vs:

	#if COMBINE_SHADOWMARK
	UNITY_SETUP_INSTANCE_ID(v);
	UNITY_TRANSFER_INSTANCE_ID(v, o);
	#endif

	VS_FILL_SHADOW_DATA(o);

	fs:
	#if COMBINE_SHADOWMARK
		UNITY_SETUP_INSTANCE_ID(i);
	#endif



	GET_LIGHT_MAP_DATA(i,uv1);


	//GETLIGHTMAP(i.uv1)

	//#if    SHADOWS_SHADOWMASK
	//_LightColor0.rgb *= attenuation;
	//c.rgb *= lightmap;


	//#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)

	//#else
	//	float attenuation = LIGHT_ATTENUATION(i);
	//#endif
	*/


	half4 LightMapInf;
	#if COMBINE_SHADOWMARK

	#pragma multi_compile_instancing
	UNITY_INSTANCING_BUFFER_START(MyShadoeMarkProperties)
	UNITY_DEFINE_INSTANCED_PROP(float, _lightMapIndex)
	UNITY_INSTANCING_BUFFER_END(MyShadoeMarkProperties)
	UNITY_DECLARE_TEX2DARRAY(CmbShadowMark);
	#endif




	#if SHADOWS_SHADOWMASK
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




	#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON) 
		#define SHADOW_UVS(id0,id1) float2 uv1 : TEXCOORD##id0;
	#else
		#define SHADOW_UVS(id0,id1) UNITY_LIGHTING_COORDS(##id0, ##id1)  
		/*#if UNITY_SHADOW
			#define SHADOW_UVS(id0,id1) UNITY_LIGHTING_COORDS(##id0, ##id1)  
		#else
			#define SHADOW_UVS(id0,id1)  
		#endif*/
	#endif




#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	#define VS_FILL_SHADOW_DATA(o,uv) o.uv1 = uv * unity_LightmapST.xy + unity_LightmapST.zw;
#else
	#if UNITY_SHADOW
		#define VS_FILL_SHADOW_DATA(o,uv) TRANSFER_VERTEX_TO_FRAGMENT(o);
	#else
		#define VS_FILL_SHADOW_DATA(o,uv)
	#endif
#endif

#if UNITY_SHADOW
#define GET_SHADOW_ATTENUATION  UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos) //float attenuation = LIGHT_ATTENUATION(i);
#else
#define GET_SHADOW_ATTENUATION float attenuation = 1;
#endif

#if SHADOWS_SHADOWMASK
#define RETURN_LIGHT_MAP
#else
#define RETURN_LIGHT_MAP return float4(lightmap.rgb,1);
#endif
 

#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
#define GET_LIGHT_MAP_DATA(i,uvname)\
	GETLIGHTMAP(i.##uvname);\
	lightmap.rgb *= LightMapInf.rgb *(1 + LightMapInf.a);\
	RETURN_LIGHT_MAP
#else
#define GET_LIGHT_MAP_DATA(i,uvname)\
	float4 lightmap = 0;\
	GET_SHADOW_ATTENUATION; 
#endif


#endif