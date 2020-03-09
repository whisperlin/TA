// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TA/T4MShaders/ShaderModel3/Diffuse/T4M 5 Textures Water Bump ARM Simple" 
{
	Properties
	{
		_Splat0 ("Layer 1 (R)", 2D) = "white" {}
		_SpColor0("_SpColor0", Color) = (1,1,1,1)
		_Gloss0("_Gloss0",Range(0,1)) = 0.23
		_Splat1 ("Layer 2 (G)", 2D) = "white" {}
		_SpColor1("_SpColor1", Color) = (1,1,1,1)
		_Gloss1("_Gloss1",Range(0,1)) = 0.23
		_Splat2 ("Layer 3 (B)", 2D) = "white" {}
		_SpColor2("_SpColor2", Color) = (1,1,1,1)
		_Gloss2("_Gloss2",Range(0,1)) = 0.23

		_Splat3("Layer 3 (B)", 2D) = "white" {}
		_SpColor3("_SpColor3", Color) = (1,1,1,1)
		_Gloss3("_Gloss3",Range(0,1)) = 0.23

		_Splat4("Layer 4 (B)", 2D) = "white" {}
		_SpColor4("_SpColor4", Color) = (1,1,1,1)
		_Gloss4("_Gloss4",Range(0,1)) = 0.23


		_Splat5("Layer 5 (B)", 2D) = "white" {} 
		_BumpSplat0("_BumpSplat0", 2D) = "bump" {}
		_BumpSplat1("_BumpSplat1", 2D) = "bump" {}
		_BumpSplat2("_BumpSplat2", 2D) = "bump" {}
		_BumpSplat3("_BumpSplat3", 2D) = "bump" {}
		_BumpSplat4("_BumpSplat4", 2D) = "bump" {}
		_BumpSplat5("_BumpSplat5", 2D) = "bump" {}
		_TopColor("浅水色", Color) = (0.619, 0.759, 1, 1)
		_ButtonColor("深水色", Color) = (0.35, 0.35, 0.35, 1)
		_Gloss5("水高光锐度", Range(0,1)) = 0.5

	 
		_WaveNormalPower("水法线强度",Range(0,1)) = 1
		_GNormalPower("地表法线强度",Range(0,1)) = 1
		_WaveScale("水波纹缩放", Range(0.02,0.15)) = .07
		_WaveSpeed("水流动速度", Vector) = (19,9,-16,-7)
		_SpColor5("水高光色", Color) = (1, 1, 1, 1)

		[KeywordEnum(Off, On)] _IsMetallic("是否开启金属度", Float) = 0

		metallic_power("天空强度", Range(0,1)) = 1
 
		_Shininess("三层高光锐度", Vector) = (0.078125,0.078125,0.078125,0.078125)
		
		_Control ("Control (RGBA)", 2D) = "white" {}
		_Control2("Control2 (RGBA)", 2D) = "black" {}
		_MainTex ("Never Used", 2D) = "white" {}
 
	}
	SubShader
	{

		 
		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
 
			//#pragma   multi_compile  _  _POW_FOG_ON
			#define   _HEIGHT_FOG_ON 1 // #pragma   multi_compile  _  _HEIGHT_FOG_ON
			#define   ENABLE_DISTANCE_ENV 1 // #pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			//#pragma   multi_compile  _ ENABLE_BACK_LIGHT
			

			#pragma   multi_compile  _ _BAKED_LIGHT

			//shadow mark
			#pragma   multi_compile  _  COMBINE_SHADOWMARK

			//shadow mark
			#pragma multi_compile_instancing

			#pragma multi_compile _ISMETALLIC_OFF _ISMETALLIC_ON  
			#include "T4M 5 TexturesBumpWaterPBR.cginc"
			ENDCG
		}

		Pass
		{
			Name "FORWARD_DELTA"
			Tags {
				"LightMode" = "ForwardAdd"
			}
			Blend One One

			CGPROGRAM
			#pragma multi_compile_fwdadd_fullshadows
			#define ADD_PASS 1		
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

 


			#pragma   multi_compile  _ _BAKED_LIGHT

			//shadow mark
			#pragma   multi_compile  _  COMBINE_SHADOWMARK

			//shadow mark
			#pragma multi_compile_instancing

			#pragma multi_compile _ISMETALLIC_OFF _ISMETALLIC_ON  
			#include "T4M 5 TexturesBumpWaterPBR.cginc"

			ENDCG
		}
	}

	FallBack "Mobile/Diffuse"
}