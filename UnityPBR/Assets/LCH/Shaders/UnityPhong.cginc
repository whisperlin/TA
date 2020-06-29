// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_PHONG_INCLUDED
#define UNITY_PHONG_INCLUDED

//#include "UnityCG.cginc"
//#include "UnityStandardConfig.cginc"
#include "UnityLightingCommon.cginc"
#include "SceneWeather.cginc" 



inline half DotClamped(half3 a, half3 b)
{
#if (SHADER_TARGET < 30)
	return saturate(dot(a, b));
#else
	return max(0.0h, dot(a, b));
#endif
}

float4 _BackLight;

inline fixed4 LightingBlinnPhong(half3 diffColor, half3 specColor, half smoothness,half gloss, float3 normal, half3 viewDir,  UnityLight light, UnityIndirect gi)
{
	
	
	
	fixed4 c;
	half3 h = normalize(light.dir + viewDir);
	

	float nl0 = dot(normal, light.dir);
	float nl = saturate(nl0);
	float invNL = saturate(-nl0);
	fixed diff = nl;

	
	 
	

	 

	float nh = max(0, dot(normal, h));

	float spec = pow(nh, smoothness*128.0) * gloss;


	c.rgb = diffColor * (light.color * diff + gi.diffuse) 

#if defined(FORWARD_BASE_PASS)
	+_BackLight * invNL
#endif
	+ light.color * specColor.rgb * spec;
	c.a = 1;

 

	return c;
}

#endif // UNITY_STANDARD_BRDF_INCLUDED
