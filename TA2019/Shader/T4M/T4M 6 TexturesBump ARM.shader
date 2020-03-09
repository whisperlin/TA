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
		_Gloss5("水高光锐度", Range(0,1)) = 0.5
		_SpColor5("水高光色", Color) = (1, 1, 1, 1)
		_BumpSplat0("_BumpSplat0", 2D) = "bump" {}
		_BumpSplat1("_BumpSplat1", 2D) = "bump" {}
		_BumpSplat2("_BumpSplat2", 2D) = "bump" {}
		_BumpSplat3("_BumpSplat3", 2D) = "bump" {}
		_BumpSplat4("_BumpSplat4", 2D) = "bump" {}
		_BumpSplat5("_BumpSplat5", 2D) = "bump" {}
		 
		

	 
		
		_Control ("Control (RGBA)", 2D) = "white" {}
		_Control2("Control2 (RGBA)", 2D) = "black" {}
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
			#define   _HEIGHT_FOG_ON 1 // #pragma   multi_compile  _  _HEIGHT_FOG_ON
			#define   ENABLE_DISTANCE_ENV 1 // #pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			//#pragma   multi_compile  _ ENABLE_BACK_LIGHT
			#pragma   multi_compile  _ _BAKED_LIGHT

			//shadow mark
			#pragma   multi_compile  _  COMBINE_SHADOWMARK
			//shadow mark
			#pragma multi_compile_instancing
			#pragma multi_compile _ISMETALLIC_OFF _ISMETALLIC_ON  
			#include "T4M 6 TexturesBump ARM.cginc"
			ENDCG
		}

			Pass
		{
			Name "FORWARD_DELTA"
			Tags {
				"LightMode" = "ForwardAdd"
			}
			Blend  One One
			CGPROGRAM
			#define ADD_PASS 1	
			#pragma multi_compile_fwdadd_fullshadows
						
			#pragma vertex vert
			#pragma fragment frag
			
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
			#include "T4M 6 TexturesBump ARM.cginc"
			ENDCG
		}
	}

	FallBack "Mobile/Diffuse"
}