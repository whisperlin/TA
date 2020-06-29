Shader "LCH/PBR Height Fog" {

	Properties {
		_Tint ("Tint", Color) = (0.5, 0.5, 0.5, 1)
		//_BackLight("BackLight",Color)=(0.15,0.15,0.15,1)
		_MainTex ("Albedo", 2D) = "white" {}
		[NoScaleOffset] _NormalMap ("Normals", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1
		[Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
		_Smoothness ("Smoothness", Range(0, 1)) = 0.1
		_MetallicTex("Metallic Tex", 2D) = "white" {}
		
		[KeywordEnum(None,Aniso,SSS)]_EffectMode("Color Mode",Float) = 0
		//[Toggle(_ANISOTROPIC_ENABLE)] _button("各向异性", Float) = 0
		_Anisotropic("Anisotropic",  Range(-20,1)) = 0
		_BRDFTex("_BRDFTex", 2D) = "white" {}
	}

	CGINCLUDE

	#define BINORMAL_PER_FRAGMENT 1
	//#define ENABLE_DETIAL_TEXTURE 1
	ENDCG

	SubShader {

		Pass {
			Tags {
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma target 3.0
			#define UNITY_SHADOW 1
			#pragma multi_compile _ SHADOWS_SCREEN
			#pragma multi_compile _ VERTEXLIGHT_ON
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

			#pragma multi_compile _EFFECTMODE_NONE _EFFECTMODE_ANISO _EFFECTMODE_SSS

			#pragma vertex VertexProgramSample
			#pragma fragment FragmentProgramSample

			#define FORWARD_BASE_PASS

			#include "pbr_lighting.cginc"

			ENDCG
		}

		/*Pass {
			Tags {
				"LightMode" = "ForwardAdd"
			}

			Blend One One
			ZWrite Off

			CGPROGRAM

			#pragma target 3.0

			#pragma multi_compile_fwdadd_fullshadows
			
			#pragma vertex VertexProgramSample
			#pragma fragment FragmentProgramSample

			#include "pbr_lighting.cginc"

			ENDCG
		}*/

		Pass {
			Tags {
				"LightMode" = "ShadowCaster"
			}

			CGPROGRAM

			#pragma target 3.0

			#pragma vertex MyShadowVertexProgram
			#pragma fragment MyShadowFragmentProgram

			#include "shadows.cginc"

			ENDCG
		}
	}
	//FallBack "Diffuse"
}