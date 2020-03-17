// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

#include "UnityCG.cginc"
#include "AutoLight.cginc" //第三步// 
#include "Lighting.cginc"

#include "../../Shader/FogCommon.cginc"
#include "../../Shader/SceneWeather.inc"
#include "../../Shader/snow.cginc"
#if UNITY_PASS_META
#include "UnityMetaPass.cginc"
#endif

struct appdata
{
	float4 vertex : POSITION;
	float3 normal :NORMAL;
	float4 tangent: TANGENT;
	float4 color: COLOR;
	float2 uv : TEXCOORD0;
	float2 uv2 : TEXCOORD1;
};

struct v2f
{
	float2 uv : TEXCOORD0;
	float2 uv2: TEXCOORD1;
	float4 vertexToFrag: TEXCOORD2;
	float4 color : TEXCOORD3;
	float3 worldPos : TEXCOORD4;


	half3 tspace0 : TEXCOORD5; // tangent.x, bitangent.x, normal.x
	half3 tspace1 : TEXCOORD6; // tangent.y, bitangent.y, normal.y
	half3 tspace2 : TEXCOORD7; // tangent.z, bitangent.z, normal.z

	half3 SH : TEXCOORD8;
	UBPA_FOG_COORDS(10)
#if UNITY_SHADOW
		LIGHTING_COORDS(11, 12) //第四步// 
#endif
		float4 pos : SV_POSITION;

	half3 normal : TEXCOORD13;
};

uniform sampler2D _WindVectors;
uniform float _WindAmplitudeMultiplier;
uniform float _WindAmplitude;
uniform float _WindSpeed;
uniform float4 _WindDirection;
uniform float _UseSpeedTreeWind;
uniform float _MaxWindStrength;
uniform float _WindStrength;
uniform float _TrunkWindSpeed;
uniform float _TrunkWindSwinging;
uniform float _TrunkWindWeight;
uniform float _FlatLighting;
uniform sampler2D _BumpMap;
uniform float _GradientBrightness;
uniform sampler2D _MainTex;
float4 _MainTex_ST;
uniform float4 _HueVariation;
uniform float _WindDebug;
uniform float4 _TransmissionColor;
uniform float _Smoothness;
uniform float _AmbientOcclusion;
uniform float _Cutoff = 0.5;

inline half fixHalf(half f)
{
	return floor(f * 10000)*0.0001;
}
float3 unityBRDF(float3 specularColor, float roughness, float NdotL, float NdotV, float NdotH, float VdotH, float LdotH)
{
	//float NdotL = saturate(dot(normalDirection, lightDirection));
	//float LdotH = saturate(dot(lightDirection, halfDirection));

	//float NdotV = abs(dot(normalDirection, viewDirection));
	//float NdotH = saturate(dot(normalDirection, halfDirection));
	//float VdotH = saturate(dot(viewDirection, halfDirection));
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

void vertexDataFunc(inout float4 vertex, inout float3 normal, float4 color, float2 uv, float2 uv2, float3 worldPos, out float4 vertexToFrag)
{

	float speedOffset = ((_WindSpeed * 0.05) * _Time.w);
	float2 windDir2D = (float2(_WindDirection.x, _WindDirection.z));
	float3 windNoise = UnpackNormal(tex2Dlod(_WindVectors, float4(((_WindAmplitudeMultiplier * _WindAmplitude * ((worldPos).xz * 0.01)) + (speedOffset * windDir2D)), 0, 0.0)));
	float3 ase_objectScale = float3(length(unity_ObjectToWorld[0].xyz), length(unity_ObjectToWorld[1].xyz), length(unity_ObjectToWorld[2].xyz));
	float3 windDirV3 = (float3(_WindDirection.x, 0.0, _WindDirection.z));
	windDirV3 = mul(unity_WorldToObject, windDirV3);
	float3 _One = float3(1, 1, 1);
	float3 winOffset = (((float3(0, 0, 0) + (sin(((speedOffset * (_TrunkWindSpeed / ase_objectScale)) * windDirV3)) - (float3(-1, -1, -1) + _TrunkWindSwinging)) * (_One) / (_One - (float3(-1, -1, -1) + _TrunkWindSwinging))) * _TrunkWindWeight) * lerp(color.a, (uv.xy.y * 0.01), _UseSpeedTreeWind));
	float3 winOffsetH = (float3(winOffset.x, 0.0, winOffset.z));
	float3 Wind17 = (((windNoise * lerp(color.g, uv2.xy.x, _UseSpeedTreeWind)) * _MaxWindStrength * _WindStrength) + winOffsetH);
	vertex.xyz += Wind17;
	float3 ase_vertexNormal = normal.xyz;
	float3 _Vector0 = float3(0, 1, 0);
	float3 finalNormal = lerp(ase_vertexNormal, _Vector0, _FlatLighting);
	normal = finalNormal;
#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
	float3 ase_worldlightDir = 0;
#else //aseld
	float3 ase_worldlightDir = normalize(UnityWorldSpaceLightDir(worldPos));
#endif //aseld
	ase_worldlightDir = normalize(ase_worldlightDir);
	float3 ase_worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
	float DotworldlightDir = dot(ase_worldlightDir, (1.0 - ase_worldViewDir));
#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
	float4 ase_lightColor = 0;
#else //aselc
	float4 ase_lightColor = _LightColor0;
#endif //aselc
	vertexToFrag = ((((DotworldlightDir + 1.0) * 0.5) * color.b) * _TransmissionColor.a) * (_TransmissionColor * ase_lightColor);


}
//color.r ao
//color.a 树干摆动幅度
//color.g 树叶摆动幅度
//color.b 光泽颜色


v2f vert(appdata v)
{
	v2f o;
	float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
	vertexDataFunc(v.vertex, v.normal, v.color, v.uv, v.uv2, worldPos, o.vertexToFrag);
	worldPos = mul(unity_ObjectToWorld, v.vertex);
	o.worldPos = worldPos;
	o.pos = mul(UNITY_MATRIX_VP, float4(worldPos, 1.0));
	o.color = v.color;
	o.uv2 = v.uv2;
	o.uv = TRANSFORM_TEX(v.uv, _MainTex);


	half3 wNormal = UnityObjectToWorldNormal(v.normal);
	half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
	// compute bitangent from cross product of normal and tangent
	half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
	half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
	// output the tangent space matrix
	o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
	o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
	o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
	o.SH = ShadeSH9(float4(wNormal, 1));
#if UNITY_SHADOW
	TRANSFER_VERTEX_TO_FRAGMENT(o); //第5步// 
#endif
	UBPA_TRANSFER_FOG(o, v.vertex);

	o.normal = wNormal;
	return o;
}

fixed4 frag(v2f i) : SV_Target
{

	half3 tnormal = UnpackNormal(tex2D(_BumpMap, i.uv));
	// transform normal from tangent to world space
	half3 worldNormal;
	worldNormal.x = dot(i.tspace0, tnormal);
	worldNormal.y = dot(i.tspace1, tnormal);
	worldNormal.z = dot(i.tspace2, tnormal);

	//float2 uv_BumpMap62 = i.uv_texcoord;
	//o.Normal = UnpackNormal(tex2D(_BumpMap, uv_BumpMap62));
	float2 uv_MainTex = i.uv;
	float4 tex2DMain = tex2D(_MainTex, uv_MainTex);
	float4 mainColor = lerp((_GradientBrightness * tex2DMain) , tex2DMain , lerp(saturate((i.color.a * 10.0)),(0.1 * i.uv2.y),_UseSpeedTreeWind));
	float4 transform204 = mul(unity_ObjectToWorld,float4(0,0,0,1));
	float4 lerpResult20 = lerp(mainColor , _HueVariation , (_HueVariation.a * frac(((transform204.x + transform204.y) + transform204.z))));
	float4 Color56 = saturate(lerpResult20);
	float3 worldPos = i.worldPos;
	float speedOffset = ((_WindSpeed * 0.05) * _Time.w);
	float2 windDir2D = (float2(_WindDirection.x , _WindDirection.z));
	float3 windNoise = UnpackNormal(tex2D(_WindVectors, ((_WindAmplitudeMultiplier * _WindAmplitude * ((worldPos).xz * 0.01)) + (speedOffset * windDir2D))));
	float4 diffuse = lerp(Color56 , float4(windNoise , 0.0) , _WindDebug);

	//return float4(dot(i.normal, float3(0, 1, 0)).rrr, 1);
 
	//return float4(dot(float3(i.tspace0.z, i.tspace1.z, i.tspace2.z), float3(0, 1, 0)).rrr, 1);
#if _ISWEATHER_ON

#if SNOW_ENABLE 
	fixed nt;
	CmpSnowNormalAndPower(i.uv, float3(i.tspace0.z, i.tspace1.z, i.tspace2.z), nt, worldNormal);
#endif
#endif
#if _ISWEATHER_ON
#if RAIN_ENABLE 

	calc_weather_info(i.worldPos.xyz, worldNormal, tnormal, diffuse, worldNormal, diffuse.rgb);
#endif
#endif


	float Emission = i.vertexToFrag;
#if UNITY_PASS_META
	UnityMetaInput o;

	o.Emission = Emission;
	o.Albedo = diffuse; // No gloss connected. Assume it's 0.5

	return UnityMetaFragment(o);

#endif

#if ADD_PASS
	float3 lightDir = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.worldPos.xyz, _WorldSpaceLightPos0.w));
#else
	float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
#endif

	half NdotL = saturate(dot(worldNormal, lightDir));
	float4 c = diffuse;

	float attenuation = LIGHT_ATTENUATION(i);

#if _ISWEATHER_ON
#if RAIN_ENABLE  
	_Smoothness = saturate(_Smoothness* get_smoothnessRate());
#endif
#if(SNOW_ENABLE)
	_Smoothness = lerp(_Smoothness, _SnowGloss, nt);
#endif
#endif

	half perceptualRoughness = 1.0 - _Smoothness;
	half roughness = perceptualRoughness * perceptualRoughness;
	float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

	//return  float4(perceptualRoughness, perceptualRoughness, perceptualRoughness, 1);
	float3 halfDirection = normalize(viewDir + lightDir);
	float LdotH = saturate(dot(lightDir, halfDirection));
	float NdotH = saturate(dot(worldNormal, halfDirection));

	float NdotV = abs(dot(worldNormal, viewDir));
	float VdotH = saturate(dot(viewDir, halfDirection));

	float3 specular = unityBRDF(tex2DMain.rgb, roughness, NdotL, NdotV, NdotH, VdotH, LdotH);

	
	
	float AmbientOcclusion = lerp(1.0 , 0.0 , (_AmbientOcclusion * (1.0 - i.color.r)));

	c.rgb = (i.SH + _LightColor0 * NdotL * attenuation + specular + Emission) * c.rgb;
	c.rgb *= AmbientOcclusion;

	clip(tex2DMain.a - _Cutoff);
	UBPA_APPLY_FOG(i, c);
	return c;
}