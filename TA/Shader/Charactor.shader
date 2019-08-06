Shader "TA/Charactor"
{
	Properties
	{
		_Color("颜色", Color) = (1, 1, 1, 1)
		_MainTex("主贴图", 2D) = "white" {}
		_Normal("法线", 2D) = "bump" {}
		_LightPower("受光强度",Range(0,1)) = 1
		_AmbientPower("环境球调节",Range(0,2))=1
 
		_Spec("高光色", Color) = (1, 1, 1, 1)

		_SpecMap("高光强度贴图", 2D) = "white" {}
		_SpPower("高光强度", Range(0,2)) = 1
		
 
		_GlossMap("高光粗糙贴图", 2D) = "black" {}
		_Gloss("高光粗糙度", Range(0, 1)) = 0.5


		//_IntensityColor("Intensity Color", Color) = (0, 0, 0, 0)
		[KeywordEnum( On,Back)] _IsS3("是否开启SSS", Float) = 0
		_DifSC("漫反射色差",Range(0,0.5)) = 0  //因为pbr漫反射的颜色部分会贡献给高光，所以对比相对会弱点. 
		sss_scatter0("背光强度",Range(0,0.5)) = 0.2
			
		_BackColor("背光", Color) = (0, 0, 0, 1)

		_BRDFTex ("SSS brdf贴图", 2D) = "gray" {}
		_S3SPower("SSS强度",Range(0,1)) = 1
		_AO("SSS控制", 2D) = "white" {}
		//[KeywordEnum(Off, On)] _IsEmissive ("是否开启自发光", Float) = 0
		//_Emissive("自发光", 2D) = "black" {}
		//_EmissiveColor("自发光颜色", Color) = (1, 1, 1, 1)

		[KeywordEnum(Off, On)] _IsMetallic("是否开启金属度", Float) = 0

		[KeywordEnum(Off,On)] _IsSun("是否开启太阳", Float) = 0
		[KeywordEnum(OFF,ON )] _IsMetaDiffuseColor("金属乘漫反射", Float) = 0
		environment_reflect("金属反射贴图", 2D) = "black" {}
		metallic_color("金属颜色", Color) = (1, 1, 1, 0)
		metallic_power("金属强度", Range(0,2)) = 1

 
		metallic_ctrl_tex("金属控制贴图", 2D) = "white" {}

		_MetalShadow("金属接收阴影强度",Range(0,1)) = 0.5 
		_CtrlTex("控制图", 2D) = "white" {}


		
		[KeywordEnum(  On ,Shadow2)] _virtual_light ("非场景光照方向", Float) = 0
		[KeywordEnum(Off, On,Col)] _IsMEmission("自发光或变色", Float) = 0
		_ClothColor("衣服颜色", Color) = (1, 0, 0, 0.5)

		[KeywordEnum(Off, On)] _cloth("变色2", Float) = 0
	 
		_ClothColor2("衣服颜色2", Color) = (0, 0, 1, 0.5)
		_Emission("自发光", Color) = (0.5, 0.5, 0.5, 1)
	 


 

		[Enum(UnityEngine.Rendering.CullMode)] _Cull("Off为双面贴图", Float) = 2
		//_SnowPower()
		[Toggle(S_DEVELOP)] S_DEVELOP("开发者模式", Float) = 0
		[Toggle(S_BAKE)] S_BAKE("烘焙模式", Float) = 0
		[HideInInspector] _Shadow("Shadow", 2D) = "black" {}
		[HideInInspector] _ShadowFade("ShadowFade", 2D) = "black" {}
		[HideInInspector] _ShadowStrength("ShadowStrength", Range(0, 1)) = 1
 
		[HideInInspector] _RedCtrl("", 2D) = "white" {}
		[HideInInspector] _GreenCtrl("", 2D) = "white" {}
		[HideInInspector] _BlueCtrl("", 2D) = "white" {}
		[HideInInspector] _AlphaCtrl("", 2D) = "white" {}



	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		Cull[_Cull]

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fwdbase
			
			#pragma multi_compile_fog

 

	 		//#pragma multi_compile __ SHADOW_ON
			#pragma multi_compile __ BRIGHTNESS_ON
			//#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
 
			#pragma multi_compile _ISMETALLIC_OFF _ISMETALLIC_ON  
			#pragma multi_compile _ISMEMISSION_OFF   _ISMEMISSION_ON _ISMEMISSION_COL


			#pragma multi_compile _CLOTH_OFF _CLOTH_ON
			#pragma multi_compile _ISMETADIFFUSECOLOR_OFF   _ISMETADIFFUSECOLOR_ON             
			#pragma multi_compile _ISSUN_ON  _ISSUN_OFF 

			#pragma   multi_compile  _  ENABLE_NEW_FOG
			#pragma   multi_compile  _  _POW_FOG_ON
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			//#pragma  multi_compile  _VIRTUAL_LIGHT_ON _VIRTUAL_LIGHT_OFF _VIRTUAL_LIGHT_SHADOW _VIRTUAL_LIGHT_SHADOW2
			
			#pragma  multi_compile  _VIRTUAL_LIGHT_ON   _VIRTUAL_LIGHT_SHADOW2
			#pragma multi_compile  _ISS3_ON _ISS3_BACK
			#pragma shader_feature S_BAKE
			#pragma shader_feature S_DEVELOP
			#pragma shader_feature HARD_SNOW
			#pragma shader_feature MELT_SNOW
			#pragma   multi_compile  _  GLOBAL_ENV_SH9
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#pragma   multi_compile  _ ENABLE_BACK_LIGHT
		
			//#pragma multi_compile __ GLOBAL_SH9
	 
			#define GLOBAL_SH9 1
			#define _CHARACTOR 1
		 
			#include "pbr-brdf.cginc"

			//#define GLOBAL_SH9 1
			//#if GLOBAL_SH9
			//#include "../SHGlobal.cginc"
			//#endif


			ENDCG
		}

		//UsePass "VertexLit/SHADOWCOLLECTOR"
	}
	Fallback "Mobile/VertexLit"

	CustomEditor "CharactorGUI"
}
