#include "UnityCG.cginc"
#include "../../Shader/FogCommon.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc" //µÚÈý²½// 
#include "../../Shader/bake.cginc"
#include "../../Shader/LCHCommon.cginc"

#pragma multi_compile_instancing

#include "../../Shader/shadowmarkex.cginc"

struct appdata
{
	float4 vertex : POSITION;
	LIGHTMAP_UVS(0, 1, 2)
	float3 normal : NORMAL;
	float4 tangent: TANGENT;
	float4 color:COLOR;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
	float2 uv : TEXCOORD0;

	SHADOW_UVS(1, 2)
 
 
	float4 wpos:TEXCOORD3;
	UBPA_FOG_COORDS(4)
	WORLD_NORMAL_DECALE(5,6,7)
 

	float2 uv2 : TEXCOORD8; 
	float4 color:COLOR;
	
	float3 SH : TEXCOORD10;
	float4 pos : SV_POSITION;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

sampler2D _MainTex;

#ifdef BRIGHTNESS_ON
fixed3 _Brightness;
#endif

#define UNITY_SAMPLE_TEX2D(tex,coord) tex.Sample (sampler##tex,coord)

#include "UnityGlobalIllumination.cginc"
fixed UnitySampleBakedOcclusion2(float2 lightmapUV, float3 worldPos)
{

	half bakedAtten = UnitySampleBakedOcclusion(lightmapUV.xy, worldPos);
	//return bakedAtten;
	float zDist = dot(_WorldSpaceCameraPos - worldPos, UNITY_MATRIX_V[2].xyz);
	float fadeDist = UnityComputeShadowFadeDistance(worldPos, zDist);
	float shadowFade = UnityComputeShadowFade(fadeDist);

	return bakedAtten;

}
uniform float _WindSpeed;
uniform float _TrunkWindSpeed;
uniform float4 _WindDirection;
uniform float _TrunkWindSwinging;
uniform half _TrunkWindWeight;
uniform float _UseSpeedTreeWind;
uniform sampler2D _BumpMap;
uniform float4 _BumpMap_ST;
uniform float _GradientBrightness;
 
uniform float4 _MainTex_ST;
uniform float _Smoothness;
uniform float _AmbientOcclusion;
uniform float _AlphaCut;
void vertexDataFunc(inout appdata v)
{

	float3 ase_objectScale = float3(length(unity_ObjectToWorld[0].xyz), length(unity_ObjectToWorld[1].xyz), length(unity_ObjectToWorld[2].xyz));
	float3 windDirV3 = (float3(_WindDirection.x, 0.0, _WindDirection.z));
	windDirV3 = mul(unity_WorldToObject, windDirV3);
	float3 _Vector1 = float3(1, 1, 1);
	float3 break94 = (float3(0, 0, 0) + (sin(((((_WindSpeed * 0.05) * _Time.w) * (_TrunkWindSpeed / ase_objectScale)) * windDirV3)) - (float3(-1, -1, -1) + _TrunkWindSwinging)) * (_Vector1 - float3(0, 0, 0)) / (_Vector1 - (float3(-1, -1, -1) + _TrunkWindSwinging)));
	float3 appendResult93 = (float3(break94.x, 0.0, break94.z));
	float3 temp_output_41_0 = (appendResult93 * _TrunkWindWeight * lerp(v.color.a, (v.uv0.xy.y * 0.01), _UseSpeedTreeWind));
	float3 Wind111 = temp_output_41_0;
	v.vertex.xyz += Wind111;
}


v2f vert(appdata v)
{


	v2f o;
	UNITY_INITIALIZE_OUTPUT(v2f, o);

	o.uv2 = v.uv1;
#if COMBINE_SHADOWMARK
	UNITY_SETUP_INSTANCE_ID(v);
	UNITY_TRANSFER_INSTANCE_ID(v, o);
#endif
	vertexDataFunc(v);
	o.pos = UnityObjectToClipPos(v.vertex);
	float4 wpos = mul(unity_ObjectToWorld, v.vertex);
	o.wpos = wpos;
	o.uv = v.uv0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	o.uv1 = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
	TRANSFER_VERTEX_TO_FRAGMENT(o);
#endif

	float3 wNormal = UnityObjectToWorldNormal(v.normal);
	FILL_WORLD_NORMAL_DECALE(o, wNormal)
 
	
	o.color = v.color;
	o.SH = ShadeSH9(half4(wNormal, 1));
	UBPA_TRANSFER_FOG(o, v.vertex);


	return o;
}
float3 unityBRDF(float3 specularColor, float roughness, float NdotL, float NdotV, float NdotH, float VdotH, float LdotH)
{
	float visTerm = SmithJointGGXVisibilityTerm(NdotL, NdotV, roughness);
	float normTerm = GGXTerm(NdotH, roughness);
	float specularPBL = (visTerm*normTerm) * UNITY_PI;
#ifdef UNITY_COLORSPACE_GAMMA
	specularPBL = sqrt(max(1e-4h, specularPBL));
#endif
	specularPBL = max(0, specularPBL * NdotL);
#if defined(_SPECULARHIGHLIGHTS_OFF)
	specularPBL = 0.0;
#endif
	specularPBL *= any(specularColor) ? 1.0 : 0.0;
	float3 directSpecular = specularPBL * FresnelTerm(specularColor, LdotH);
	return directSpecular;
}
fixed4 frag(v2f i) : SV_Target
{
#if COMBINE_SHADOWMARK
	UNITY_SETUP_INSTANCE_ID(i);
#endif
	fixed4 c = tex2D(_MainTex, i.uv);
#if _ALPHA_CLIP
	clip(c.a - _AlphaCut);
#endif

	half Roughness109 = (c.a * _Smoothness);
	half Smoothness = Roughness109;
	float lerpResult120 = lerp(1.0, i.color.r, _AmbientOcclusion);
	float AmbientOcclusion = lerpResult120;

	c = lerp((_GradientBrightness * c), c, lerp((1.0 - (i.color.a * 10.0)), i.uv2.y, _UseSpeedTreeWind));

	half3 worldNormal;
	GET_WORLD_NORMAL(i, worldNormal, _BumpMap);
 

	half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

	half perceptualRoughness = 1.0 - _Smoothness;
	half roughness = perceptualRoughness * perceptualRoughness;
	float3 viewDir = normalize(UnityWorldSpaceViewDir(i.wpos));

 
	float3 halfDirection = normalize(viewDir + lightDir);
	float LdotH = saturate(dot(lightDir, halfDirection));
	float NdotH = saturate(dot(worldNormal, halfDirection));
	half NdotL = saturate(dot(worldNormal, lightDir));
	float NdotV = abs(dot(worldNormal, viewDir));
	float VdotH = saturate(dot(viewDir, halfDirection));
	float3 specularColor = unity_ColorSpaceDielectricSpec.rgb;
	float3 specular = unityBRDF(specularColor, roughness, NdotL, NdotV, NdotH, VdotH, LdotH);
			

	GET_LIGHT_MAP_DATA(i,uv1);

	float3 lightColor = _LightColor0.rgb * attenuation;
 
	c.rgb = lightColor * NdotL * c.rgb + lightmap * c.rgb + specular * c.rgb;
#ifdef BRIGHTNESS_ON
		c.rgb = c.rgb * _Brightness * 2;
#endif

	UBPA_APPLY_FOG(i, c);
	return c;
}