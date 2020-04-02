 Shader "TA/Scene/树干带法线(烘培)"
{
    Properties
    {
		_MainTex("MainTex", 2D) = "white" {}
		_BumpMap("BumpMap", 2D) = "white" {}
		_GradientBrightness("GradientBrightness", Range(0 , 2)) = 1
		_AmbientOcclusion("Ambient Occlusion", Range(0 , 1)) = 0.5
		_AlphaCut("半透明剔除", Range(0 , 1)) = 0.1
		[Toggle(_ALPHA_CLIP)] _ALPHA_CLIP("开启半透明剔除", Float) = 1
		[Toggle]_UseSpeedTreeWind("UseSpeedTreeWind", Float) = 0
		_Smoothness("Smoothness", Range(0 , 1)) = 0
		[HideInInspector] _texcoord2("", 2D) = "white" {}
		[HideInInspector] _texcoord("", 2D) = "white" {}
		[HideInInspector] __dirty("", Int) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase"} //第一步//
			Cull Off
            CGPROGRAM
			#define UNITY_SHADOW 1
			#pragma multi_compile_fwdbase//第二步//
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

			#define _ISWEATHER_ON 1
			#pragma multi_compile __ SNOW_ENABLE
			#pragma   multi_compile  _ HARD_SNOW
			#pragma   multi_compile  _ MELT_SNOW
			#pragma multi_compile __ RAIN_ENABLE
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma   multi_compile  _  COMBINE_SHADOWMARK
			#pragma   multi_compile  _ _ALPHA_CLIP
			#define SHADOWS_SHADOWMASK 1

			#define UNITY_SHADOW 1
            #include "FAE_TreeTrunkVF.cginc"
            ENDCG
        }

		Pass
		{
			Name "FORWARD_DELTA"
			Tags {
				"LightMode" = "ForwardAdd"
			}
			Blend One One
			Cull Off
			CGPROGRAM
			#define ADD_PASS 1
			#pragma   multi_compile  _ _ALPHA_CLIP
			//#pragma multi_compile_fwdbase//第二步//
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "FAE_TreeTrunkVF.cginc"
			ENDCG
		}

		/*Pass
		{
			Name "Meta"
			Tags {
				"LightMode" = "Meta"
			}
			Cull Off
			CGPROGRAM
			#pragma multi_compile_shadowcaster
			#define UNITY_PASS_META 1
 
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "FAE_TreeTrunkVF.cginc"
			ENDCG
		}*/
    }
	Fallback "Diffuse"
}
