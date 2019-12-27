#ifndef _______VIRTUAL_LIGHT______
#define _______VIRTUAL_LIGHT______ 1



half4 VirtualDirectLight0;
half4 VirtualDirectLightColor0;


half4 VirtualDirectSceneLight0;
half4 VirtualScenDirectLightColor0;



half4 GetVirtualNdotL(half3 posWorld)
{
	half3 viewDir = normalize(UnityWorldSpaceViewDir(posWorld));
	return dot(VirtualDirectSceneLight0, viewDir);
}
//half3 viewDir = normalize(UnityWorldSpaceViewDir(i.posWorld));


#endif