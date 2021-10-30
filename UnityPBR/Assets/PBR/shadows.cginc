

//UsePass "Mobile/VertexLit/ShadowCaster" 
//UsePass "Legacy Shaders/Transparent/Cutout/VertexLit/ShadowCaster" // _Cutoff  _MainTex
#ifndef LCH_SHADOW

#define LCH_SHADOW

inline half4 VertexGIForward(float2 uv1, float3 posWorld, half3 normalWorld)
{
	half4 ambientOrLightmapUV = 0;
	// Static lightmaps
#ifdef LIGHTMAP_ON
	ambientOrLightmapUV.xy = uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
	ambientOrLightmapUV.zw = 0;
	 
#elif UNITY_SHOULD_SAMPLE_SH
	#ifdef VERTEXLIGHT_ON
		// Approximated illumination from non-important point lights
		ambientOrLightmapUV.rgb = Shade4PointLights(
			unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
			unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
			unity_4LightAtten0, posWorld, normalWorld);
	#endif

	ambientOrLightmapUV.rgb += ShadeSH9( half4(normalWorld,1 ) );
#endif

/*#ifdef DYNAMICLIGHTMAP_ON
	ambientOrLightmapUV.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif*/

	return ambientOrLightmapUV;
}

#endif
