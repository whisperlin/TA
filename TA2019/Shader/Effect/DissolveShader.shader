 
Shader "TA/Effect/DissolveShader" {
    Properties {
       
        _Albedo ("Albedo", 2D) = "white" {}
        _Noise ("Noise", 2D) = "white" {}
        _DissolvePower ("Dissolve Power", Range(0, 1)) = 0
        //_NormaLMap ("NormaLMap", 2D) = "bump" {}
		_BorderColor("BorderColor", Color) = (1,0,0,1)
		_edge("edge",Range(0,0.2)) = 0.1
		_bright("_bright",Range(1,10)) = 2

        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "Queue"="AlphaTest"
            "RenderType"="TransparentCutout"
        }
        LOD 100
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
           
            #define UNITY_PASS_FORWARDBASE

            #include "dissolve.cginc"

            ENDCG
        }
        
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Back
            
            CGPROGRAM

            #define __DISS_SHADOW 1
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "dissolve.cginc"
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
