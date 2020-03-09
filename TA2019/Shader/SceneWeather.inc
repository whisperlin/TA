#if RAIN_ENABLE || SNOW_ENABLE

sampler2D _WeatherCtrlTex0;
float4 weather_intensity;
#ifndef FRAMETIME_DEFINED
#define FRAMETIME_DEFINED
float FrameTime;
float SmoothnessRate;
#endif

inline void calc_weather_info(float3 posWorld, fixed3 normal, fixed3 originNormal, fixed3 diffuseColor,
	out fixed3 newNormal, out fixed3 newColor)
{
 
 
 
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
inline void calc_weather_info_surface(float3 posWorld, fixed3 normal, fixed3 originNormal, fixed3 diffuseColor,
	out fixed3 newNormal, out fixed3 newColor)
{
 
 
 
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