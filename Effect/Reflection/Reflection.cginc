
#ifndef __________REFLECTION_____________________

#define  __________REFLECTION_____________________

#if REFLECTION

sampler2D _LchReflectionTex;
half4x4 _LchReflectionMatrix;
float _ReflectionPower;
float _ReflectionMinMap;


half4 GetReflection(half4 worldPos )
{

	float4 pj = mul(_LchReflectionMatrix, worldPos);
	pj.xy /= pj.w;
	float2 refUV = pj.xy.xy*0.5 + 0.5;
	refUV = 1 - refUV;
 
	half4 reflect = tex2Dlod(_LchReflectionTex, half4(refUV,0, _ReflectionMinMap));
	return reflect;
}

half4 GetReflection3(half3 worldPos)
{

	return GetReflection(half4(worldPos,1));
}
#endif

#endif
