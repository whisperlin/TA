 
Shader "TA/Substance PBR EX Tree" {
	Properties{
		_BumpMap("Normal Map", 2D) = "bump" {}
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		_MetallicPower("MetallicPower", Range(0, 1)) = 1
		_GlossPower("GlossPower", Range(0, 1)) = 0.3
		emissive_power("自发光强度", Range(0, 1)) = 1
		//[KeywordEnum(On,Off)] _IsMetallic("是否开启金属度", Float) = 0

		[Toggle]_snow_options("----------雪选项-----------",int) = 0

		_SnowNormalPower("  雪法线强度", Range(0.3, 1)) = 1
		//_SnowColor("雪颜色", Color) = (0.784, 0.843, 1, 1)
		_SnowEdge("  雪边缘过渡", Range(0.01, 0.3)) = 0.2
		//_SnowNoise("雪噪点", 2D) = "white" {}
		_SnowNoiseScale("  雪噪点缩放", Range(0.1, 20)) = 1.28
		//_SnowGloss("雪高光", Range(0, 1)) = 1

		//_SnowMeltPower("  雪_消融影响调节", Range(1, 2)) =  1
		_SnowLocalPower("  雪_法线影响调节", Range(-5, 0.3)) = 0
		

		[MaterialToggle] HARD_SNOW("硬边雪", Float) = 0
		[MaterialToggle] MELT_SNOW("消融雪", Float) = 0
		_AlphaClip("AlphaClip", Range(0.01, 1)) = 0.01
		[Enum(UnityEngine.Rendering.CullMode)] _Cull("Off为双面贴图", Float) = 2
		//[Toggle(NORM_TERM_ONLY)] NORM_TERM_ONLY("  NORM_TERM_ONLY", Float) = 0
	}
		SubShader{
			Tags { "Queue" = "Transparent-10" "RenderType" = "Transparent" }
			Cull Off
			Pass {
				Name "FORWARD"
				Tags {
					"LightMode" = "ForwardBase"
				}
				Blend SrcAlpha OneMinusSrcAlpha
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				//#pragma multi_compile_fwdbase

				#define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
				#define _GLOSSYENV 1
				
				
				#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
 
				//#pragma multi_compile_fog

				#define _ISMETALLIC_OFF 1

				//#pragma   multi_compile  _  FOG_LIGHT
 
				#define _ISWEATHER_ON 1
				
				#pragma multi_compile __ SNOW_ENABLE
 
				#pragma multi_compile __ RAIN_ENABLE

				#pragma multi_compile __ GLOBAL_SH9
				#pragma  multi_compile  __ _SCENE_SHADOW2

				#define BACK_LIGHT_DIFFUSE 1
				#define ALPHA_CLIP 1

				//#pragma   multi_compile  _ NORM_TERM_ONLY
				//#define NORM_TERM_ONLY 1
				
				#define NO_CTRL_TEXTURE 1
				//#define DISABLE_VISIBLE_TERM
				//#define DISABLE_FRESNEL  1
				//#define _ISS3_ON 1
				//#pragma multi_compile __ SSS_EFFECT  

				#include "AutoLight.cginc" 
				#include "Lighting.cginc"
				#include "unity_pbr-simple.cginc"   
				ENDCG
				}
																											 
		}
		FallBack "Diffuse"
																																																	CustomEditor "ShaderForgeMaterialInspector"
}
