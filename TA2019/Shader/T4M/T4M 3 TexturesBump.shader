// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TA/T4MShaders/ShaderModel3/Diffuse/T4M 3 Textures Bump" 
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
		_BumpSplat0("_BumpSplat0", 2D) = "bump" {}
		_BumpSplat1("_BumpSplat1", 2D) = "bump" {}
		_BumpSplat2("_BumpSplat2", 2D) = "bump" {}
		
		_Control ("Control (RGBA)", 2D) = "white" {}
		_MainTex ("Never Used", 2D) = "white" {}

	}

	//sampler2D _BumpSplat0, _BumpSplat1, _BumpSplat2;

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
			//#define   _HEIGHT_FOG_ON 1 // #pragma   multi_compile  _  _HEIGHT_FOG_ON
			#define   ENABLE_DISTANCE_ENV 1 // #pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			//#pragma   multi_compile  _ ENABLE_BACK_LIGHT

			//shadow mark
			#pragma   multi_compile  _  COMBINE_SHADOWMARK

			//shadow mark
			#pragma multi_compile_instancing
			
#include "T4M 3 TexturesBump.cginc"
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
			#define ADD_PASS 1	
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			
			//#pragma   multi_compile  _  _POW_FOG_ON
			//#define   _HEIGHT_FOG_ON 1 // #pragma   multi_compile  _  _HEIGHT_FOG_ON
			#define   ENABLE_DISTANCE_ENV 1 // #pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			//#pragma   multi_compile  _ ENABLE_BACK_LIGHT

			//shadow mark
			#pragma   multi_compile  _  COMBINE_SHADOWMARK

			//shadow mark
			#pragma multi_compile_instancing

#include "T4M 3 TexturesBump.cginc"
			ENDCG
		}
	}

	FallBack "Mobile/Diffuse"
}