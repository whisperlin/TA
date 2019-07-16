Shader "TA/Fur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}



		_FurLength ("毛发长度", Range (.0002, 1)) = .25
		_Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5 // how "thick"
		//_CutoffEnd ("Alpha Cutoff end", Range(0,1)) = 0.5 // how thick they are at the end
		//_EdgeFade ("Edge Fade", Range(0,1)) = 0.4

		_Gravity ("重力方向", Vector) = (0,-1,0,0)
		_GravityStrength ("重力影响大小", Range(0,0.5)) = 0.25
	}


	


	SubShader
	{
	 Tags {  "Queue"="AlphaTest+300" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
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
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#define FUR_MULTIPLIER 0.05
			#define DONT_CLIP 1
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
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
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
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#define FUR_MULTIPLIER 0.25

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
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#define FUR_MULTIPLIER 0.35

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
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#define FUR_MULTIPLIER 0.45

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
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#define FUR_MULTIPLIER 0.55

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
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#define FUR_MULTIPLIER 0.65

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
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#define FUR_MULTIPLIER 0.75

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
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#define FUR_MULTIPLIER 0.85

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
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#define FUR_MULTIPLIER 0.95

			#include "FurPass.cginc"
			ENDCG
		}

		 
		
	}
}