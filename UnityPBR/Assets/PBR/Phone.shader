Shader "Lch/Phone(Shadow Mask)"
{
	Properties
	{
		_Color("Color", Color) = (1, 1, 1, 1)
		_MainTex("Texture", 2D) = "white" {}

		[Toggle(_NORMAL_MAP)]_NORMAL_MAP("法线",Int) = 0
		_Normal("Normal[_NORMAL_MAP]", 2D) = "bump" {}
		[Toggle(_SPEC_ENABLE)]_SPEC_ENABLE("高光",Int) = 0
		_SpecMap("SpecMap[_SPEC_ENABLE]", 2D) = "white" {}

		_Gloss("Gloss[_SPEC_ENABLE]", Range(0.04, 1)) = 0.5
		_SpeColor("SpeColor[_SPEC_ENABLE]",Color) = (1,1,1,1)


		[Toggle(_ALPHA_CLIP)]_ALPHA_CLIP("透明剔除",Int) = 0
		_AlphaClip("剔除值[_ALPHA_CLIP]", Range(0, 1)) = 0.01
 
	}

	SubShader
	{
		Pass
		{
			Tags {"LightMode"="ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#define FORWARD_BASE_PASS
 
			#pragma multi_compile  LIGHTPROBE_SH
			#pragma multi_compile  DIRECTIONAL

			#pragma multi_compile   _ _NORMAL_MAP
			#pragma multi_compile   _ _SPEC_ENABLE

			#pragma multi_compile   _ GLOBAL_BACK_LIGHT
		 
			#pragma multi_compile  SHADOWS_SHADOWMASK
			#pragma multi_compile LIGHTMAP_SHADOW_MIXING

			//#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			

			#pragma multi_compile _ SHADOWS_SCREEN 
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON


			#pragma multi_compile   _  _ALPHA_CLIP

			#include "phone.cginc"
 

			
			ENDCG
		}

		
		UsePass "Mobile/VertexLit/ShadowCaster"
		UsePass "Hidden/PhoneMeta/Meta"
 
	
		
		 
	
	}
	 CustomEditor "LCHShaderGUIBase" 
}
