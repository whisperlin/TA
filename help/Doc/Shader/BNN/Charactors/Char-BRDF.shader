Shader "BNN/Charactors/Char-BRDF"
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
		[HideInInspector] sam_normalCtrl("", 2D) = "black" {}
		[HideInInspector] sam_metallicCtrl("", 2D) = "white" {}
		[HideInInspector] sam_3sCtrl("", 2D) = "white" {}
		[HideInInspector] sam_srCtrl("", 2D) = "white" {}
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
#pragma shader_feature DEV_MODE_ON
#pragma multi_compile _TRANSPARENT_MODE

#include "Char-BRDF.inc"

			ENDCG
		}
	}
	CustomEditor "CharBRDFShaderEditor"
}
