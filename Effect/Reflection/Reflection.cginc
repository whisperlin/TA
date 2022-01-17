
#ifndef __________REFLECTION_____________________

#define  __________REFLECTION_____________________


//_ReflectionPower("Reflection Power",Range(0,1))=1

sampler2D _LchReflectionTex;
half4x4 _LchReflectionMatrix;
float _ReflectionPower;


half4 GetReflection(half4 worldPos)
{

	float4 pj = mul(_LchReflectionMatrix, worldPos);
	pj.xy /= pj.w;
	float2 refUV = pj.xy.xy*0.5 + 0.5;
	refUV = 1 - refUV;
	//refUV.x = 1 - refUV.y;
	//refUV.y = 1 - refUV.y;
	half4 reflect = tex2D(_LchReflectionTex, refUV);
	return reflect;
}

#endif
