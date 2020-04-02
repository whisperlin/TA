#pragma target 3.0
#ifdef UNITY_PASS_SHADOWCASTER
#undef INTERNAL_DATA
#undef WorldReflectionVector
#undef WorldNormalVector
#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
#endif


#ifndef USER_DATA
#define USER_DATA
#endif
struct Input
{
	float2 uv_texcoord;
	float3 worldNormal;
	float3 worldPos;
	float4 _fogCoord;
	INTERNAL_DATA
	USER_DATA
};

#include  "../FogCommon.cginc"
#include "../Weather.cginc"
#include "../snow.cginc"


void common_final(inout Input data, inout SurfaceOutputStandard o, inout fixed4 color)
{
	UBPA_APPLY_FOG(data, color);
}
void common_vert(inout appdata_full v, inout Input data)
{
 
	data._fogCoord = GetExponentialHeightFog(-WorldSpaceViewDir(v.vertex));
}

void common_surf(inout Input i, inout SurfaceOutputStandard o)
{
#if _ISWEATHER_ON
#if RAIN_ENABLE 

	calc_weather_info(i.worldPos.xyz, o.Normal, o.Albedo, o.Normal, o.Albedo.rgb);
	o.Smoothness = saturate(o.Smoothness* get_smoothnessRate());
#endif
#if SNOW_ENABLE 
	fixed nt;
	float3 ase_worldNormal = WorldNormalVector(i, float3(0, 0, 1));
	float3 ase_worldTangent = WorldNormalVector(i, float3(1, 0, 0));
	float3 ase_worldBitangent = WorldNormalVector(i, float3(0, 1, 0));
	float3x3 ase_worldToTangent = float3x3(ase_worldTangent, ase_worldBitangent, ase_worldNormal);
	float3 tUp = mul(ase_worldToTangent, float3(0, 1, 0));
	CmpSnowNormalAndPowerSurFace(i.uv_texcoord, float3(0, 0, 1), nt, o.Normal, tUp);
	o.Albedo.rgb = lerp(o.Albedo.rgb, _SnowColor.rgb, nt *_SnowColor.a);
	o.Metallic = lerp(o.Metallic, 0, nt *_SnowColor.a);
	o.Smoothness = lerp(o.Smoothness, _SnowGloss, nt);
#endif
#endif
}

 

