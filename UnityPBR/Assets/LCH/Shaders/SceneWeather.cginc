#ifndef ________SCENE_____WEATHER_____________
#define ________SCENE_____WEATHER_____________

#include "UnityCG.cginc"
 
fixed _SnowPower;
fixed _SnowNormalPower;
fixed4 _SnowColor;
fixed _SnowEdge;
sampler2D _SnowNoise;
half _SnowNoiseScale;
half _SnowGloss;
half _SnowLocalPower;
half _SnowMeltPower;
half HARD_SNOW;
half MELT_SNOW;

/*
[Toggle]_snow_options("----------雪选项-----------",int) = 0
_SnowNormalPower("  雪法线强度", Range(0.3, 1)) = 1
//_SnowColor("雪颜色", Color) = (0.784, 0.843, 1, 1)
_SnowEdge("  雪边缘过渡", Range(0.01, 0.3)) = 0.2
//_SnowNoise("雪噪点", 2D) = "white" {}
_SnowNoiseScale("  雪噪点缩放", Range(0.1, 20)) = 1.28
//_SnowGloss("雪高光", Range(0, 1)) = 1
//_SnowMeltPower("  雪_消融影响调节", Range(1, 2)) =  1
_SnowLocalPower("  雪_法线影响调节", Range(-5, 0.3)) = 0
[MaterialToggle] HARD_SNOW("硬边雪", Float) = 0
[MaterialToggle] MELT_SNOW("消融雪", Float) = 0
//[KeywordEnum(ON, OFF)] _IsWeather("是否接收天气", Float) = 0
*/
 
float global_weather_state;
void CmpSnowNormalAndPower(in half2 uv,in float3 VertexNormal,out fixed t, inout float3 normalDirection)
{
 
	half snoize = 0;
	half snl = 0;
	if (MELT_SNOW > 0)
	{
		half snoize = tex2D(_SnowNoise, uv*_SnowNoiseScale).r;
		snl = snoize * _SnowMeltPower;
		t = smoothstep(_SnowPower, _SnowPower + _SnowEdge, snl);
		if (HARD_SNOW > 0)
		{
			t = step(snoize, t);
		}
	}
	else
	{
		snl = dot(normalDirection, half3(0, 1, 0));
		snl = (1.0 - _SnowLocalPower)*snl + _SnowLocalPower;
		t = smoothstep(_SnowPower, _SnowPower + _SnowEdge, snl);
		if (HARD_SNOW > 0)
		{
			half snoize = tex2D(_SnowNoise, uv*_SnowNoiseScale).r;
			t = step(snoize, t);
		}
	}
	normalDirection = lerp(VertexNormal.xyz, normalDirection, _SnowNormalPower);

 
}



void CmpSnowNormalAndPowerSurFace(in half2 uv, in float3 VertexNormal, out fixed t, inout float3 normalDirection, float3 tUp)//切线空间上方向
{
 
	half snoize = 0;
	half snl = 0;
	if (MELT_SNOW > 0)
	{
		half snoize = tex2D(_SnowNoise, uv*_SnowNoiseScale).r;
		snl = snoize * _SnowMeltPower;
		t = smoothstep(_SnowPower, _SnowPower + _SnowEdge, snl);
		if (HARD_SNOW > 0)
		{
			t = step(snoize, t);
		}
	}
	else
	{
		snl = dot(normalDirection, tUp);
		snl = (1.0 - _SnowLocalPower)*snl + _SnowLocalPower;
		t = smoothstep(_SnowPower, _SnowPower + _SnowEdge, snl);
		if (HARD_SNOW > 0)
		{
			half snoize = tex2D(_SnowNoise, uv*_SnowNoiseScale).r;
			t = step(snoize, t);
		}
	}
	normalDirection = lerp(half3(0, 0, 1), normalDirection, _SnowNormalPower);

 
}


sampler2D _WeatherCtrlTex0;
float4 weather_intensity;
#ifndef FRAMETIME_DEFINED
#define FRAMETIME_DEFINED

float SmoothnessRate;
#endif

inline void calc_weather_info(float3 posWorld, fixed3 normal , fixed3 diffuseColor,
	out fixed3 newNormal, out fixed3 newColor)
{


	float FrameTime = _Time.y;
	const fixed roughness = 0.0f;
	const float time = FrameTime * 0.25;
	const half uvScale = 18.0;
 
	{
		fixed3 nor;
		fixed3 col;

		float2 w2uv0 = float2(posWorld.x + posWorld.y, posWorld.z) * 0.0048f;
		float2 uv0offset = float2(0.022f, 0.0273f) * time;
		float2 uv0 = w2uv0 + uv0offset;
		float2 w2uv1 = float2(posWorld.x, posWorld.z + posWorld.y) * 0.00378f;
		float2 uv1offset = float2(0.033f, 0.0184f) * time;
		float2 uv1 = w2uv1 - uv1offset;

		half4 bump0 = tex2D(_WeatherCtrlTex0, uv0 * uvScale) * 2.0 - 1.0;
		half4 bump1 = tex2D(_WeatherCtrlTex0, uv1 * uvScale) * 2.0 - 1.0;
		half4 bump = (bump0 * bump1) * (weather_intensity.y);
		half weatherColor = weather_intensity.x;
		//nor = normalize(normal + bump.xyz);
		nor = normalize(normal + half3(bump.x, 0.0, bump.y));
		col = diffuseColor * weatherColor;

		half3 local_142;
		half3 local_143;
		half local_144;
		half3 local_145;

		newNormal = nor;
		newColor = col;

	}
}
//for surface
inline void calc_weather_info_surface(float3 posWorld, fixed3 normal , fixed3 diffuseColor,
	out fixed3 newNormal, out fixed3 newColor)
{


	float FrameTime = _Time.y;
	const fixed roughness = 0.0f;
	const float time = FrameTime * 0.25;
	const half uvScale = 18.0;
	// Function calc_weather_info Begin 
	{
		fixed3 nor;
		fixed3 col;

		float2 w2uv0 = float2(posWorld.x + posWorld.y, posWorld.z) * 0.0048f;
		float2 uv0offset = float2(0.022f, 0.0273f) * time;
		float2 uv0 = w2uv0 + uv0offset;
		float2 w2uv1 = float2(posWorld.x, posWorld.z + posWorld.y) * 0.00378f;
		float2 uv1offset = float2(0.033f, 0.0184f) * time;
		float2 uv1 = w2uv1 - uv1offset;

		half4 bump0 = tex2D(_WeatherCtrlTex0, uv0 * uvScale) * 2.0 - 1.0;
		half4 bump1 = tex2D(_WeatherCtrlTex0, uv1 * uvScale) * 2.0 - 1.0;
		half4 bump = (bump0 * bump1) * (1.0f * weather_intensity.y);
		half weatherColor = lerp(1.0f, 0.58f, weather_intensity.x);
		//nor = normalize(normal + bump.xyz);
		nor = normalize(normal + half3(bump.x, bump.y, 0.0));
		col = diffuseColor * weatherColor;

		half3 local_142;
		half3 local_143;
		half local_144;
		half3 local_145;

		newNormal = nor;
		newColor = col;

	}
}

inline float get_smoothnessRate()
{
	return SmoothnessRate;
}

#endif