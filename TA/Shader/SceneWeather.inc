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
 
#if RAIN_ENABLE
 
 
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
#else
		nor = normal;
		col = diffuseColor;
#endif
		half3 local_142;
		half3 local_143;
		half local_144;
		half3 local_145;
#if SNOW_ENABLE
		const half local_149 = 0.1f;
		half local_152 = (dot(originNormal.xy, originNormal.xy) + local_149) * 2.0f;
		half local_153 = col.x;
		half local_154 = col.y;
		half local_155 = col.z;
		half local_156 = max(local_153, local_154);
		half local_157 = max(local_156, local_155);
		half local_158 = min(local_153, local_154);
		half local_159 = min(local_158, local_155);
		const half local_160 = 1.0f;
		const half local_161 = 0.01f;
		half local_164 = local_160 - (local_159 / (local_161 + local_157));
		half local_173 = saturate(nor.y / local_160) + local_149;
		half local_176 = (local_160 / (local_160 - weather_intensity.z)) - local_160;
		half local_180 = saturate(local_176 * local_164 * local_152 * local_173);
		half local_184 = pow(local_180 + local_161, weather_intensity.y * 0.8f);
		half3 local_185 = { local_184, local_184, local_184 };
		half3 local_186 = { local_180, local_180, local_180 };
		newNormal = nor;
		newColor = lerp(col, local_185, local_186);
#else
		newNormal = nor;
		newColor = col;
#endif
	}
}
inline float get_smoothnessRate()
{
	return SmoothnessRate;
}
#endif