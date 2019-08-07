Shader "BNN/Charactors/Char-BRDF-Combine"
{
	Properties
	{
		sam_diffuse("", 2D) = "white" {}
		sam_environment_reflect("", 2D) = "white" {}
		sam_normal("", 2D) = "white" {}
		sam_control("", 2D) = "white" {}

		_CC_LAPE("character_light_factor/change_color_bright_add/point_light_scale/env_exposure", Vector) = (0.5, 0, 0, 1.5)
		metallic_color("", Color) = (1, 1, 1, 0)
		_CC_NMRB("normalmap_scale/metallic_offset/roughness_offset/bloom_switch", Vector) = (1, 0, 0, 0)
		sss_scatter_color0("", Color) = (0.6941, 0.0941, 0.0941, 0)
		_CC_WSAX("sss_warp0/sss_scatter0/alphaRef/alphaValue", Vector) = (0.32, 0.5, 0.588235, 1)

		[HideInInspector] _Mode("__mode", Float) = 0.0
		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
		[HideInInspector] _DevMode("__dev", Float) = 0.0
		[HideInInspector] sam_diffuse2("", 2D) = "white" {}
		[HideInInspector] sam_normal2("", 2D) = "white" {}
		[HideInInspector] sam_control2("", 2D) = "white" {}
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"Queue" = "AlphaTest+2"
		}

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_fog
#pragma shader_feature _TRANSPARENT_MODE

#define COMBINE_MODE 1
#include "Char-BRDF.inc"

			ENDCG
		}
	}
	CustomEditor "CharBRDFShaderEditor"
}
