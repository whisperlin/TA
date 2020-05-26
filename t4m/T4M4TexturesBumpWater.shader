// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "T4MShaders/ShaderModel3/BumpSpec/T4M 4 Textures Bump Spec Water" {
Properties {
	//_SpecColor ("Specular Color", Color) = (1, 1, 1, 1)
	_SpecColor0("第一层高光色", Color) = (1, 1, 1, 1)
	_ShininessL0 ("Layer1Shininess", Range (0.03, 1)) = 0.078125
	_Splat0 ("Layer 1 (R)", 2D) = "white" {}
	_SpecColor1("第二层高光色", Color) = (1, 1, 1, 1)
	_ShininessL1 ("Layer2Shininess", Range (0.03, 1)) = 0.078125
	_Splat1 ("Layer 2 (G)", 2D) = "white" {}
	_SpecColor2("第三层高光色", Color) = (1, 1, 1, 1)
	_ShininessL2 ("Layer3Shininess", Range (0.03, 1)) = 0.078125
	_Splat2 ("Layer 3 (B)", 2D) = "white" {}
	_ShininessL3 ("Layer4Shininess", Range (0.03, 1)) = 0.078125
	_Splat3 ("Layer 4 (A)", 2D) = "white" {}
	_BumpSplat0 ("Layer1Normalmap", 2D) = "bump" {}
	_BumpSplat1 ("Layer2Normalmap", 2D) = "bump" {}
	_BumpSplat2 ("Layer3Normalmap", 2D) = "bump" {}
	_BumpSplat3 ("Layer4Normalmap", 2D) = "bump" {}
	_Control ("Control (RGBA)", 2D) = "white" {}
	_MainTex ("Never Used", 2D) = "white" {}
	_TopColor("浅水色", Color) = (0.619, 0.759, 1, 1)
	_ButtonColor("深水色", Color) = (0.35, 0.35, 0.35, 1)
	_Gloss("水高光亮度", Range(0,1)) = 0.5
	_WaveNormalPower("水法线强度",Range(0,1)) = 1
	_WaveScale("水波纹缩放", Range(0.02,0.15)) = .07
	_WaveSpeed("水流动速度", Vector) = (19,9,-16,-7)
	_SpecColor3("水高光色", Color) = (1, 1, 1, 1)
	[KeywordEnum(Off, On)] _IsMetallic("是否开启金属度", Float) = 0
	metallic_power("天空强度", Range(0,1)) = 1
	metallic_color("天空颜色", Color) = (1, 1, 1, 0)

	[HideInInspector]cubemapCenter("cubemapCenter",Vector) = (1, 1, 1, 1)
	[HideInInspector]boxMin("boxMin",Vector) = (1, 1, 1, 1)
	[HideInInspector]boxMax("boxMax",Vector) = (1, 1, 1, 1)
} 

SubShader {
	Tags {
		"SplatCount" = "4"
		"Queue" = "Geometry-100"
		"RenderType" = "Opaque"
	}
CGPROGRAM
#pragma surface surf BlinnPhong vertex:vert
#pragma target 3.0
#pragma exclude_renderers gles xbox360 ps3

#pragma multi_compile __  BOX_PROJECT_SKY_BOX
#include "boxproject.cginc" 
#include "UnityCG.cginc"

		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
			
		#endif
		#define WorldNormalVectorFun(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
struct Input {
	float3 worldPos;
	float2 uv_Control : TEXCOORD0;
	float2 uv_Splat0 : TEXCOORD1;
	float2 uv_Splat1 : TEXCOORD2;
	float2 uv_Splat2 : TEXCOORD3;
	float2 uv_Splat3 : TEXCOORD4;
	float3 worldRefl;
	half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
};

void vert (inout appdata_full v) {

	float3 T1 = float3(1, 0, 1);
	float3 Bi = cross(T1, v.normal);
	float3 newTangent = cross(v.normal, Bi);
	
	normalize(newTangent);

	v.tangent.xyz = newTangent.xyz;
	
	if (dot(cross(v.normal,newTangent),Bi) < 0)
		v.tangent.w = -1.0f;
	else
		v.tangent.w = 1.0f;
}

sampler2D _Control;
sampler2D _BumpSplat0, _BumpSplat1, _BumpSplat2, _BumpSplat3;
sampler2D _Splat0,_Splat1,_Splat2,_Splat3;
fixed _ShininessL0;
fixed _ShininessL1;
fixed _ShininessL2;
fixed _ShininessL3;

uniform float _WaveNormalPower;
uniform float4 _WaveSpeed;
uniform float _WaveScale;
float metallic_power;
float3 metallic_color;
float _Gloss;
float4 _TopColor;
float4	_ButtonColor;
fixed4 _Shininess;

half4 _SpecColor0;
half4 _SpecColor1;
half4 _SpecColor2;
half4 _SpecColor3;
inline float2 ToRadialCoords(float3 coords)
{
	float3 normalizedCoords = normalize(coords);
	float latitude = acos(normalizedCoords.y);
	float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
	float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
	return float2(0.5, 1.0) - sphereCoords;
}
void surf (Input IN, inout SurfaceOutput o) {

	half4 splat_control = tex2D (_Control, IN.uv_Control);
	half3 col;
	half4 splat0 = tex2D (_Splat0, IN.uv_Splat0);
	half4 splat1 = tex2D (_Splat1, IN.uv_Splat1);
	half4 splat2 = tex2D (_Splat2, IN.uv_Splat2);
 
	
	col  = splat_control.r * splat0.rgb;
	o.Normal = splat_control.r * UnpackNormal(tex2D(_BumpSplat0, IN.uv_Splat0));
	o.Gloss = splat0.a * splat_control.r ;
	o.Specular = _ShininessL0 * splat_control.r;

	col += splat_control.g * splat1.rgb;
	o.Normal += splat_control.g * UnpackNormal(tex2D(_BumpSplat1, IN.uv_Splat1));
	o.Gloss += splat1.a * splat_control.g;
	o.Specular += _ShininessL1 * splat_control.g;
	
	col += splat_control.b * splat2.rgb;
	o.Normal += splat_control.b * UnpackNormal(tex2D(_BumpSplat2, IN.uv_Splat2));
	o.Gloss += splat2.a * splat_control.b;
	o.Specular += _ShininessL2 * splat_control.b;

	half4 temp = IN.worldPos.xzxz * _WaveScale + _WaveSpeed * _WaveScale * _Time.y;
		temp.xy *= float2(.4, .45);
	half3 bump1 = UnpackNormal(tex2D(_BumpSplat3, temp.xy)).rgb;
	half3 bump2 = UnpackNormal(tex2D(_BumpSplat3, temp.zw)).rgb;
	half3 bump = (bump1 + bump2) * 0.5;
	half3 baseNormal = half3(0, 0, 1);

	half3 waterNormal =   lerp(baseNormal,bump ,  _WaveNormalPower)  ;

	metallic_power = metallic_power*splat_control.a;
 
	float3 viewReflectDirection = reflect(IN.worldRefl, half3(dot(IN.internalSurfaceTtoW0, waterNormal), dot(IN.internalSurfaceTtoW1, waterNormal), dot(IN.internalSurfaceTtoW2, waterNormal)));
 
 
#if BOX_PROJECT_SKY_BOX
	viewReflectDirection = BoxProjectedCubemapDirectionT4M(viewReflectDirection, IN.worldPos, cubemapCenter, boxMin, boxMax);
#endif
	half2 skyUV = half2(ToRadialCoords(viewReflectDirection));
	//half2 skyUV = half2(ToRadialCoords(viewReflectDirection) );
	fixed4 localskyColor = tex2D(_Splat3, skyUV);

	/*o.Normal = float3(0, 0, 1);
	o.Gloss = 0;

	o.Specular = 0;
	o.Emission = localskyColor;
	return;*/
	float3 waterColor = lerp(_TopColor,_ButtonColor, splat_control.a).rgb;
 
    col += splat_control.a * (1-metallic_power)*waterColor;
 
 	o.Normal += splat_control.a * waterNormal;
	
	o.Normal = normalize(o.Normal);
	_SpecColor =  _SpecColor0*splat_control.r + _SpecColor1*splat_control.g + _SpecColor2*splat_control.b + _SpecColor3*splat_control.a;
	_SpecColor = 0;
	o.Gloss +=   splat_control.a;
	o.Specular += _Gloss * splat_control.a;
	o.Emission =  localskyColor.rgb * metallic_power  * splat_control.a;
	o.Albedo = col;
 
	o.Alpha = 0.0;
}
ENDCG  
}
FallBack "Specular"
}