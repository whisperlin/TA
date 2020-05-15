// Upgrade NOTE: upgraded instancing buffer 'VritualPointLightProperties' to new syntax.

//#pragma multi_compile_instancing
//UNITY_INSTANCE_ID
//UNITY_INSTANCE_ID

//UNITY_SETUP_INSTANCE_ID (v);
//UNITY_TRANSFER_INSTANCE_ID(v, o);

//UNITY_SETUP_INSTANCE_ID (i);
//return UNITY_ACCESS_INSTANCED_PROP(_Color);

//NITY_INSTANCING_CBUFFER_START (MyProperties)
//UNITY_DEFINE_INSTANCED_PROP(float4, _VirtualPointLightPos)
//UNITY_DEFINE_INSTANCED_PROP(float4, _VirtualPointLightColor)
//UNITY_INSTANCING_CBUFFER_END

UNITY_INSTANCING_BUFFER_START(VritualPointLightProperties)
UNITY_DEFINE_INSTANCED_PROP(float4, _VirtualPointLightPos)
#define _VirtualPointLightPos_arr VritualPointLightProperties
UNITY_DEFINE_INSTANCED_PROP(float4, _VirtualPointLightColor)
#define _VirtualPointLightColor_arr VritualPointLightProperties
UNITY_INSTANCING_BUFFER_END(VritualPointLightProperties)

// UNITY_SETUP_INSTANCE_ID (i);


void GetVirtualPointLightData(float4 _VirtualPointLightPos ,float4 _VirtualPointLightColor , float3 posWorld, out float3 lightDirection,out float3 lightColor)
{
	lightDirection =  normalize(_VirtualPointLightPos.xyz - posWorld.xyz);
	float distanceToLight = distance(_VirtualPointLightPos.xyz, posWorld.xyz);
	float _att = distanceToLight * _VirtualPointLightPos.w;
	_att = 1 - _att * _att;
	lightColor = _VirtualPointLightColor.rgb *_att;
}