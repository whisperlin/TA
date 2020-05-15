#include "UnityCG.cginc"
#include "../../Shader/FogCommon.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc" //第三步// 
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
 
 
	float4 worldPos:TEXCOORD3;
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
uniform float _GradientBrightness;
uniform float _MaxWindStrength;
uniform float _WindStrength;
uniform sampler2D _WindVectors;
uniform float _WindAmplitudeMultiplier;
uniform float _WindAmplitude;
uniform float _WindSpeed;
uniform float4 _WindDirection;
uniform float _WindSwinging;


uniform float _UseSpeedTreeWind;
uniform float _TrunkWindSpeed;
uniform float _TrunkWindSwinging;
uniform float _TrunkWindWeight;
uniform float _FlatLighting;
uniform float4 _ObstaclePosition;
uniform float _BendingStrength;
uniform float _BendingRadius;
uniform float _BendingInfluence;
uniform float4 _TerrainUV;
uniform sampler2D _PigmentMap;
uniform float _PigmentMapInfluence;
uniform float _MinHeight;
uniform float _MaxHeight;
uniform float _HeightmapInfluence;
uniform float ShakeSpeed;
uniform float ShakeCtrl;
 
uniform float4 _MainTex_ST;
uniform float _Smoothness;
uniform float _AmbientOcclusion;
uniform float _AlphaCut;
 
float _TotalShakePower;
 
//这一坨是插件的。
void vertexDataFunc(inout appdata v)
{

	float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex);
	float WindStrength522 = _WindStrength;

	float2 appendResult469 = (float2(_WindDirection.x, _WindDirection.z));
	float3 WindVector91 = UnpackNormal(tex2Dlod(_WindVectors, float4(((((ase_worldPos).xz * 0.01) * _WindAmplitudeMultiplier * _WindAmplitude) + (((_WindSpeed * 0.05) * _Time.w) * appendResult469)), 0, 0.0)));
	float3 break277 = WindVector91;
	float3 appendResult495 = (float3(break277.x, 0.0, break277.y));
	float3 temp_cast_0 = (-1.0).xxx;
	float3 lerpResult249 = lerp((float3(0, 0, 0) + (appendResult495 - temp_cast_0) * (float3(1, 1, 0) - float3(0, 0, 0)) / (float3(1, 1, 0) - temp_cast_0)), appendResult495, _WindSwinging);
	float3 lerpResult74 = lerp(((_MaxWindStrength * WindStrength522) * lerpResult249), float3(0, 0, 0), (1.0 - v.color.g));
	float3 Wind84 = lerpResult74;

	float3 temp_output_571_0 = (_ObstaclePosition).xyz;
	float3 normalizeResult184 = normalize((temp_output_571_0 - ase_worldPos));
	float temp_output_186_0 = (_BendingStrength * 0.1);
	float3 appendResult468 = (float3(temp_output_186_0, 0.0, temp_output_186_0));
	float clampResult192 = clamp((distance(temp_output_571_0, ase_worldPos) / _BendingRadius), 0.0, 1.0);
	float3 Bending201 = (v.color.g * -(((normalizeResult184 * appendResult468) * (1.0 - clampResult192)) * _BendingInfluence));
	float3 temp_output_203_0 = (Wind84 + Bending201);
	float2 appendResult483 = (float2(_TerrainUV.z, _TerrainUV.w));
	float2 TerrainUV324 = (((1.0 - appendResult483) / _TerrainUV.x) + ((_TerrainUV.x / (_TerrainUV.x * _TerrainUV.x)) * (ase_worldPos).xz));
	float4 PigmentMapTex320 = tex2Dlod(_PigmentMap, float4(TerrainUV324, 0, 1.0));
	float temp_output_467_0 = (PigmentMapTex320).a;
	float Heightmap518 = temp_output_467_0;
	float PigmentMapInfluence528 = _PigmentMapInfluence;
	float3 lerpResult508 = lerp(temp_output_203_0, (temp_output_203_0 * Heightmap518), PigmentMapInfluence528);
	float3 break437 = lerpResult508;
	float3 ase_vertex3Pos = v.vertex.xyz;
	//#ifdef _VS_TOUCHBEND_ON
	//				float staticSwitch659 = (TouchReactAdjustVertex(float4(ase_vertex3Pos, 0.0).xyz)).y;
	//#else
	//				float staticSwitch659 = 0.0;
	//#endif
	float staticSwitch659 = 0.0;
	float TouchBendPos613 = staticSwitch659;
	float temp_output_499_0 = (1.0 - v.color.r);
	float lerpResult344 = lerp((saturate(((1.0 - temp_output_467_0) - TouchBendPos613)) * _MinHeight), 0.0, temp_output_499_0);
	float lerpResult388 = lerp(_MaxHeight, 0.0, temp_output_499_0);
	float GrassLength365 = ((lerpResult344 * _HeightmapInfluence) + lerpResult388);
	float3 appendResult391 = (float3(break437.x, GrassLength365, break437.z));
	float3 VertexOffset330 = appendResult391;
	v.vertex.xyz += VertexOffset330* _TotalShakePower;

	//下面两句俺补上去的。
	float s = sin(_Time.y*ShakeSpeed*_TrunkWindSpeed*0.5 + (ase_worldPos.x + ase_worldPos.z));
	float3 localWindDir = normalize(mul((float3x3)unity_WorldToObject, _WindDirection.rgb));
	v.vertex.xz = v.vertex.xz + localWindDir.xz*s * v.color.a *ShakeCtrl*_TrunkWindWeight;

	//float s = sin(_Time.y*ShakeSpeed *_TrunkWindSpeed + (ase_worldPos.x + ase_worldPos.z));
	//v.vertex.xz = v.vertex.xz + _WindDirection.zx*s * v.color.a *ShakeCtrl*trunkWindWeight;
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
	float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
	o.worldPos = worldPos;
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
	//return i.color.gggg;
#if COMBINE_SHADOWMARK
	UNITY_SETUP_INSTANCE_ID(i);
#endif
	fixed4 c = tex2D(_MainTex, i.uv);
#if _ALPHA_CLIP2
	clip(_AlphaCut - c.a );
#endif
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
	
#if ADD_PASS
	float3 lightDir = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.worldPos.xyz, _WorldSpaceLightPos0.w));
	c.rgb = (_LightColor0 * saturate(dot(worldNormal, lightDir)) *  LIGHT_ATTENUATION(i)) * c.rgb;
	return c;
#else
	float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
#endif
	 
	GET_LIGHT_MAP_DATA(i, uv1);
	half perceptualRoughness = 1.0 - _Smoothness;
	half roughness = perceptualRoughness * perceptualRoughness;
	float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

 
	float3 halfDirection = normalize(viewDir + lightDir);
	float LdotH = saturate(dot(lightDir, halfDirection));
	float NdotH = saturate(dot(worldNormal, halfDirection));
	half NdotL = saturate(dot(worldNormal, lightDir));
	float NdotV = abs(dot(worldNormal, viewDir));
	float VdotH = saturate(dot(viewDir, halfDirection));
	float3 specularColor = unity_ColorSpaceDielectricSpec.rgb;
	float3 specular = unityBRDF(specularColor, roughness, NdotL, NdotV, NdotH, VdotH, LdotH);
			

	

	float3 lightColor = _LightColor0.rgb * attenuation;
 
	c.rgb = lightColor * NdotL * c.rgb + lightmap * c.rgb + specular * c.rgb;
#ifdef BRIGHTNESS_ON
		c.rgb = c.rgb * _Brightness * 2;
#endif

	UBPA_APPLY_FOG(i, c);
	return c;
}