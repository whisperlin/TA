﻿Shader "Custom/CmdBuffDrawFullScreenQuadMat" {
    SubShader {
        ZTest Always ZWrite Off Cull Off
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            sampler2D _CameraDepthTexture;
            v2f vert (appdata v) {
                v2f o;
                o.vertex = v.vertex;
                o.uv = v.uv;
                return o;
            }
            fixed4 frag (v2f i) : SV_Target {
                float depth = tex2D(_CameraDepthTexture, i.uv).r;
                #if defined (UNITY_REVERSED_Z)
                depth = 1 - depth;
                #endif
                return depth;
            }
            ENDCG
        }
    }
}