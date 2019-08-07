#if RAIN_ENABLE || SNOW_ENABLE

sampler2D _WeatherCtrlTex0;
float4 weather_intensity;
#ifndef FRAMETIME_DEFINED
#define FRAMETIME_DEFINED
float FrameTime;
#endif

inline void calc_weather_info(float3 posWorld, fixed3 normal, fixed3 originNormal, fixed3 diffuseColor,
	out fixed3 newNormal, out fixed3 newColor)
{
	fixed local_66 = weather_intensity.x;
	fixed local_67 = weather_intensity.y;
	fixed local_68 = weather_intensity.z;
	const half local_70 = 0.0f;
	const half local_71 = 1.0f;
	//const fixed3 metallic = 1.0f; 
	const fixed roughness = 0.0f;
	const float time = FrameTime * 0.25;
	const half uvScale = 18.0;
	// Function calc_weather_info Begin 
	{
		fixed3 local_77;
		fixed3 local_78;
		fixed local_79;
#if RAIN_ENABLE
		float local_81 = posWorld.x;
		float local_82 = posWorld.y;
		float local_83 = posWorld.z;
		float local_87 = local_71 * 0.0048f;
		float2 local_89 = float2(local_81 + local_82, local_83) * local_87;
		float2 local_94 = float2(0.022f, 0.0273f) * time;
		float2 local_95 = local_89 + local_94;
		float local_99 = local_71 * 0.00378f;
		float2 local_101 = float2(local_81, local_83 + local_82) * local_99;
		float2 local_106 = float2(0.033f, 0.0184f) * time;
		float2 local_107 = local_101 - local_106;
		const float local_109 = 2.0f;
		const half local_112 = 1.0f;
		half4 local_114 = tex2D(_WeatherCtrlTex0, local_95 * uvScale) * 2.0 - 1.0;
		half4 local_119 = tex2D(_WeatherCtrlTex0, local_107 * uvScale) * 2.0 - 1.0;
		half4 local_123 = (local_114 * local_119) * (local_71 * local_67);
		half local_135 = lerp(0.0f, 0.3f, roughness) + 0.7f;
		half local_137 = lerp(local_112, 0.4f, local_135);
		half local_138 = lerp(local_112, local_137, local_66);
		half local_140 = lerp(local_112, local_137, local_66);
		local_77 = normalize(normal + half3(local_123.x, 0.0, local_123.y));
		local_78 = diffuseColor * local_140;
#else
		local_77 = normal;
		local_78 = diffuseColor;
#endif
		half3 local_142;
		half3 local_143;
		half local_144;
		half3 local_145;
#if SNOW_ENABLE
		const half local_149 = 0.1f;
		half local_152 = (dot(originNormal.xy, originNormal.xy) + local_149) * 2.0f;
		half local_153 = local_78.x;
		half local_154 = local_78.y;
		half local_155 = local_78.z;
		half local_156 = max(local_153, local_154);
		half local_157 = max(local_156, local_155);
		half local_158 = min(local_153, local_154);
		half local_159 = min(local_158, local_155);
		const half local_160 = 1.0f;
		const half local_161 = 0.01f;
		half local_164 = local_160 - (local_159 / (local_161 + local_157));
		half local_173 = saturate(local_77.y / local_160) + local_149;
		half local_176 = (local_160 / (local_160 - local_68)) - local_160;
		half local_180 = saturate(local_176 * local_164 * local_152 * local_173);
		half local_184 = pow(local_180 + local_161, local_67 * 0.8f);
		half3 local_185 = { local_184, local_184, local_184 };
		half3 local_186 = { local_180, local_180, local_180 };
		newNormal = local_77;
		newColor = lerp(local_78, local_185, local_186);
#else
		newNormal = local_77;
		newColor = local_78;
#endif
	}
}

#endif