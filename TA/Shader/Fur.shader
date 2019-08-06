Shader "TA/Fur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_AmbientPower("环境球调节",Range(0,2)) = 1

		_FurLength ("毛发长度", Range (.0002, 1)) = .25
		_Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5 // how "thick"
		//_CutoffEnd ("Alpha Cutoff end", Range(0,1)) = 0.5 // how thick they are at the end
		//_EdgeFade ("Edge Fade", Range(0,1)) = 0.4

		_Gravity ("重力方向", Vector) = (0,-1,0,0)
		_Extend ("水平展开", Vector) = (1,0,1,0)
		_GravityStrength ("重力影响大小", Range(0,0.5)) = 0.25
		[KeywordEnum(  On ,Shadow2)] _virtual_light ("非场景光照方向", Float) = 0
	}


	


	SubShader
	{
	 //Tags{ "RenderType" = "AlphaTest+300" "RenderType"="Opaque" }
		Tags {  "Queue"="AlphaTest+300" "IgnoreProjector"="True" "RenderType"="Opaque"}
		Pass
		{
			
			Tags {"LightMode" = "ForwardBase"  }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

			#pragma   multi_compile  _  ENABLE_NEW_FOG
			#pragma   multi_compile  _  _POW_FOG_ON
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#pragma   multi_compile  _ ENABLE_BACK_LIGHT
			#pragma  multi_compile  _VIRTUAL_LIGHT_ON   _VIRTUAL_LIGHT_SHADOW2
			#define FUR_MULTIPLIER 0.05
			#define DONT_CLIP 1
			#define GLOBAL_SH9 1
			#include "FurPass.cginc"
			ENDCG
		}
		Pass
		{
			
			Tags {"LightMode" = "ForwardBase"  }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma   multi_compile  _  ENABLE_NEW_FOG
			#pragma   multi_compile  _  _POW_FOG_ON
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#pragma   multi_compile  _ ENABLE_BACK_LIGHT
			#pragma  multi_compile  _VIRTUAL_LIGHT_ON   _VIRTUAL_LIGHT_SHADOW2
			#define GLOBAL_SH9 1
			#define FUR_MULTIPLIER 0.15

			#include "FurPass.cginc"
			ENDCG
		}
		Pass
		{
			
			Tags {"LightMode" = "ForwardBase"  }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma   multi_compile  _  ENABLE_NEW_FOG
			#pragma   multi_compile  _  _POW_FOG_ON
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#pragma   multi_compile  _ ENABLE_BACK_LIGHT
			#pragma  multi_compile  _VIRTUAL_LIGHT_ON   _VIRTUAL_LIGHT_SHADOW2
			#define FUR_MULTIPLIER 0.25
			#define GLOBAL_SH9 1
			#include "FurPass.cginc"
			ENDCG
		}
		Pass
		{
			
			Tags {"LightMode" = "ForwardBase"  }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
		#pragma   multi_compile  _  ENABLE_NEW_FOG
			#pragma   multi_compile  _  _POW_FOG_ON
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#pragma   multi_compile  _ ENABLE_BACK_LIGHT
			#pragma  multi_compile  _VIRTUAL_LIGHT_ON   _VIRTUAL_LIGHT_SHADOW2
			#define FUR_MULTIPLIER 0.35
			#define GLOBAL_SH9 1
			#include "FurPass.cginc"
			ENDCG
		}
		Pass
		{
 
			Tags {"LightMode" = "ForwardBase"  }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma   multi_compile  _  ENABLE_NEW_FOG
			#pragma   multi_compile  _  _POW_FOG_ON
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#pragma   multi_compile  _ ENABLE_BACK_LIGHT
			#pragma  multi_compile  _VIRTUAL_LIGHT_ON   _VIRTUAL_LIGHT_SHADOW2
			#define FUR_MULTIPLIER 0.45
			#define GLOBAL_SH9 1
			#include "FurPass.cginc"
			ENDCG
		}
		Pass
		{
		 
			Tags {"LightMode" = "ForwardBase"  }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma  multi_compile  _VIRTUAL_LIGHT_ON   _VIRTUAL_LIGHT_SHADOW2
			#pragma   multi_compile  _  ENABLE_NEW_FOG
			#pragma   multi_compile  _  _POW_FOG_ON
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#pragma   multi_compile  _ ENABLE_BACK_LIGHT
			#define FUR_MULTIPLIER 0.55
			#define GLOBAL_SH9 1
			#include "FurPass.cginc"
			ENDCG
		}
		Pass
		{
 
			Tags {"LightMode" = "ForwardBase"  }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma  multi_compile  _VIRTUAL_LIGHT_ON   _VIRTUAL_LIGHT_SHADOW2
			#pragma   multi_compile  _  ENABLE_NEW_FOG
			#pragma   multi_compile  _  _POW_FOG_ON
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#pragma   multi_compile  _ ENABLE_BACK_LIGHT
			#define FUR_MULTIPLIER 0.65
			#define GLOBAL_SH9 1
			#include "FurPass.cginc"
			ENDCG
		}
		Pass
		{
	 
			Tags {"LightMode" = "ForwardBase"  }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma  multi_compile  _VIRTUAL_LIGHT_ON   _VIRTUAL_LIGHT_SHADOW2
			#pragma   multi_compile  _  ENABLE_NEW_FOG
			#pragma   multi_compile  _  _POW_FOG_ON
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#pragma   multi_compile  _ ENABLE_BACK_LIGHT
			#define FUR_MULTIPLIER 0.75
			#define GLOBAL_SH9 1
			#include "FurPass.cginc"
			ENDCG
		}
		Pass
		{
			//Blend SrcAlpha OneMinusSrcAlpha
			Tags {"LightMode" = "ForwardBase"  }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma  multi_compile  _VIRTUAL_LIGHT_ON   _VIRTUAL_LIGHT_SHADOW2
			#pragma   multi_compile  _  ENABLE_NEW_FOG
			#pragma   multi_compile  _  _POW_FOG_ON
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#pragma   multi_compile  _ ENABLE_BACK_LIGHT
			#define FUR_MULTIPLIER 0.85
			#define GLOBAL_SH9 1
			#include "FurPass.cginc"
			ENDCG
		}

		Pass
		{
			//Blend SrcAlpha OneMinusSrcAlpha
			
			Tags {"LightMode" = "ForwardBase"  }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma  multi_compile  _VIRTUAL_LIGHT_ON   _VIRTUAL_LIGHT_SHADOW2
			#pragma   multi_compile  _  ENABLE_NEW_FOG
			#pragma   multi_compile  _  _POW_FOG_ON
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#pragma   multi_compile  _ ENABLE_BACK_LIGHT
			#define FUR_MULTIPLIER 0.95
			#define GLOBAL_SH9 1
			#include "FurPass.cginc"
			ENDCG
		}

		 
		
	}
}