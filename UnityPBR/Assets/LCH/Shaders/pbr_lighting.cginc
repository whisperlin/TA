// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

#if !defined(MY_LIGHTING_INCLUDED)
#define MY_LIGHTING_INCLUDED

#include "AutoLight.cginc"
#include "UnityStandardUtils.cginc"
#include "UnityStandardBRDFMod.cginc"
#include "shadowmarkex.cginc"
#include "FogCommon.cginc"
#include "SceneWeather.cginc" 

float4 _Tint;
sampler2D _MainTex, _DetailTex;
float4 _MainTex_ST, _DetailTex_ST;

sampler2D _NormalMap, _DetailNormalMap;
float _BumpScale, _DetailBumpScale;

float _Metallic;
float _Smoothness;

struct VertexData {
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float2 uv : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
};

struct Interpolators {
	float4 pos : SV_POSITION;
	float4 uv : TEXCOORD0;
	float3 normal : TEXCOORD1;

	#if defined(BINORMAL_PER_FRAGMENT)
		float4 tangent : TEXCOORD2;
	#else
		float3 tangent : TEXCOORD2;
		float3 binormal : TEXCOORD3;
	#endif

	float3 worldPos : TEXCOORD4;
	float3 ambient : TEXCOORD5;

#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	float2 uv1 : TEXCOORD6;
#else
	SHADOW_COORDS(6)
#endif

	#if defined(VERTEXLIGHT_ON)
		float3 vertexLightColor : TEXCOORD7;
	#endif

	UBPA_FOG_COORDS(8)
};

void ComputeVertexLightColor (inout Interpolators i) {
	#if defined(VERTEXLIGHT_ON)
		i.vertexLightColor = Shade4PointLights(
			unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
			unity_LightColor[0].rgb, unity_LightColor[1].rgb,
			unity_LightColor[2].rgb, unity_LightColor[3].rgb,
			unity_4LightAtten0, i.worldPos, i.normal
		);
	#endif
}

float3 CreateBinormal (float3 normal, float3 tangent, float binormalSign) {
	return cross(normal, tangent.xyz) *
		(binormalSign * unity_WorldTransformParams.w);
}

Interpolators VertexProgramSample(VertexData v) {
	Interpolators i = (Interpolators)0;
	i.pos = UnityObjectToClipPos(v.vertex);
	i.worldPos = mul(unity_ObjectToWorld, v.vertex);
	i.normal = UnityObjectToWorldNormal(v.normal);

	#if defined(BINORMAL_PER_FRAGMENT)
		i.tangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
	#else
		i.tangent = UnityObjectToWorldDir(v.tangent.xyz);
		i.binormal = CreateBinormal(i.normal, i.tangent, v.tangent.w);
	#endif

	i.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
#if ENABLE_DETIAL_TEXTURE
	i.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex);
#else
	i.uv.zw = 0;
#endif
	i.ambient = ShadeSH9(float4(i.normal, 1));

#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	i.uv1 = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
	TRANSFER_SHADOW(i);
#endif
	//VS_FILL_SHADOW_DATA(i,v.uv1);
	//TRANSFER_SHADOW(i);

	ComputeVertexLightColor(i);

	UBPA_TRANSFER_FOG(i, v.vertex);
	return i;
}

UnityLight CreateLight (Interpolators i,half attenuation) {
	UnityLight light;

	#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
		light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
	#else
		light.dir = _WorldSpaceLightPos0.xyz;
	#endif

	
	//UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);

	light.color = _LightColor0.rgb * attenuation;
	light.ndotl = DotClamped(i.normal, light.dir);
	return light;
}

UnityIndirect CreateIndirectLight (Interpolators i, float3 lightmap) {
	UnityIndirect indirectLight;
	indirectLight.diffuse = 0;
	indirectLight.specular = 0;//间接高光补充

	#if defined(VERTEXLIGHT_ON)
		indirectLight.diffuse = i.vertexLightColor;//点光源色。
	#endif

	#if defined(FORWARD_BASE_PASS)
		indirectLight.diffuse += i.ambient;//环境色
	#endif

	//在这里补烘培代码.
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
		indirectLight.diffuse += lightmap;//环境色
		 
#endif
	


	return indirectLight;
}

void InitializeFragmentNormal(inout Interpolators i) {
	float3 mainNormal =
		UnpackScaleNormal(tex2D(_NormalMap, i.uv.xy), _BumpScale);

#if ENABLE_DETIAL_TEXTURE
	float3 detailNormal =
		UnpackScaleNormal(tex2D(_DetailNormalMap, i.uv.zw), _DetailBumpScale);
	float3 tangentSpaceNormal = BlendNormals(mainNormal, detailNormal);
#else
	float3 tangentSpaceNormal = mainNormal;
#endif

	#if defined(BINORMAL_PER_FRAGMENT)
		float3 binormal = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
	#else
		float3 binormal = i.binormal;
	#endif
	
	i.normal = normalize(
		tangentSpaceNormal.x * i.tangent +
		tangentSpaceNormal.y * binormal +
		tangentSpaceNormal.z * i.normal
	);
}

float4 FragmentProgramSample (Interpolators i) : SV_TARGET {


	InitializeFragmentNormal(i);

	float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

	float3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Tint.rgb;
#if ENABLE_DETIAL_TEXTURE
	albedo *=  tex2D(_DetailTex, i.uv.zw)*unity_ColorSpaceDouble;
#endif

	float3 specularTint;
	float oneMinusReflectivity;
	albedo = DiffuseAndSpecularFromMetallic(
		albedo, _Metallic, specularTint, oneMinusReflectivity
	);

	if (global_weather_state == 1)//snow
	{
		fixed nt = 0;
		CmpSnowNormalAndPower(i.uv, i.normal, nt, i.normal);
		albedo.rgb = lerp(albedo.rgb, _SnowColor.rgb, nt *_SnowColor.a);
		_Smoothness = lerp(_Smoothness, _SnowGloss, nt);
	}
	else if (global_weather_state == 2)
	{
		_Smoothness = saturate(_Smoothness* get_smoothnessRate());
		calc_weather_info(i.worldPos.xyz, i.normal, albedo, i.normal, albedo.rgb);
	}

	LIGHT_MAP_FINAL(i)
	half4 final = BRDF1_Unity_PBS(albedo, specularTint, oneMinusReflectivity, _Smoothness, i.normal, viewDir, CreateLight(i, attenuation), CreateIndirectLight(i, lightmap.rgb));


	UBPA_APPLY_FOG(i, final);
	return final;
}

#endif