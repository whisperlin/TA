 Shader "TA/Scene/灌木(烘培)"
{
    Properties
    {
		_Cutoff("Mask Clip Value", Float) = 0.5
		[NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
		_HueVariation("Hue Variation", Color) = (1,0.5,0,0.184)
		[NoScaleOffset]_BumpMap("BumpMap", 2D) = "bump" {}
		_TransmissionColor("Transmission Color", Color) = (1,1,1,0)
		_AmbientOcclusion("AmbientOcclusion", Range(0 , 1)) = 0
		_MaxWindStrength("MaxWindStrength", Range(0 , 1)) = 0.1164738
		_FlatLighting("FlatLighting", Range(0 , 1)) = 0
		_WindAmplitudeMultiplier("WindAmplitudeMultiplier", Float) = 1
		_GradientBrightness("GradientBrightness", Range(0 , 2)) = 1
		_Smoothness("Smoothness", Range(0 , 1)) = 0
		[Toggle]_UseSpeedTreeWind("UseSpeedTreeWind", Float) = 0
		[HideInInspector] _uv2("", 2D) = "white" {}
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
			
			//#pragma multi_compile_fwdbase//第二步//
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

			#define _ISWEATHER_ON 1
			#define SHADOWS_SHADOWMASK 1
			#pragma multi_compile __ SNOW_ENABLE
			#pragma   multi_compile  _ HARD_SNOW
			#pragma   multi_compile  _ MELT_SNOW
			#pragma multi_compile __ RAIN_ENABLE
			#pragma multi_compile __ COMBINE_SHADOWMARK
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			//#pragma   multi_compile  _  GLOBAL_SH9
			#include "FAE_TreeBranchVF.cginc"
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
			#define DISABLE_BUMP_MAP 1
			//#pragma multi_compile_fwdbase//第二步//
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma   multi_compile  _ _ALPHA_CLIP
			#include "FAE_TreeBranchVF.cginc"
			ENDCG
		}

		 
    }
	Fallback "Legacy Shaders/Transparent/Cutout/Diffuse"
}
