float4 _VirtualPointLightPos;
float4 _VirtualPointLightColor;


void GetVirtualPointLightData(float4 _VirtualPointLightPos ,float4 _VirtualPointLightColor , float3 posWorld, out float3 lightDirection,out float3 lightColor)
{
	lightDirection =  normalize(_VirtualPointLightPos.xyz - posWorld.xyz);
	float distanceToLight = distance(_VirtualPointLightPos.xyz, posWorld.xyz);
	float _att = distanceToLight * _VirtualPointLightPos.w;
	_att = 1 - _att * _att;
	lightColor = _VirtualPointLightColor.rgb *_att;
}