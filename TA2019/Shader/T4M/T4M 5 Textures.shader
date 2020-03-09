// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TA/T4MShaders/ShaderModel3/Diffuse/T4M 5 Textures" {
Properties {
	_Splat0 ("Layer 1 (R)", 2D) = "white" {}
	_Splat1 ("Layer 2 (G)", 2D) = "white" {}
	_Splat2 ("Layer 3 (B)", 2D) = "white" {}
	_Splat3 ("Layer 4 (A)", 2D) = "white" {}
	_Tiling3("_Tiling4 x/y", Vector)=(1,1,0,0)
	_Splat4 ("Layer 5", 2D) = "white" {}
	_Tiling4("_Tiling5 x/y", Vector)=(1,1,0,0)
	_Control ("Control (RGBA)", 2D) = "white" {}
	_Control2 ("Control2 (RGBA)", 2D) = "black" {}
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
	
			//shadow mark
			#pragma   multi_compile  _  COMBINE_SHADOWMARK
			//shadow mark
			#pragma multi_compile_instancing
			#include "T4M 5 Textures.cginc"
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

			//shadow mark
			#pragma   multi_compile  _  COMBINE_SHADOWMARK
			//shadow mark
			#pragma multi_compile_instancing
			#include "T4M 5 Textures.cginc"
			ENDCG
		}
	}

	FallBack "Mobile/Diffuse"
}
