Shader "YuLongZhi/LiuGuangGlsl" {
    Properties {
        _Mask_r ("_Mask_r", 2D) = "white" {}
        _Noise_rgba ("_Noise_rgba", 2D) = "white" {}
        _Color_rgba ("_Color_rgba", Color) = (0.5,0.5,0.5,1)
        _U_speed ("U_speed", Float ) = 0
        _V_speed ("V_speed", Float ) = 0
        _Power ("_Power", Float ) = 1
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha One
			Cull Off
            ZWrite Off
            ColorMask RGB

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            uniform sampler2D _Mask_r; uniform float4 _Mask_r_ST;
            uniform sampler2D _Noise_rgba; uniform float4 _Noise_rgba_ST;
            uniform float4 _Color_rgba;
            uniform half _U_speed;
            uniform half _V_speed;
            uniform half _Power;
            struct VertexInput {
                fixed4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                fixed4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex);
                //o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
				float4 _Mask_r_var = tex2D(_Mask_r, TRANSFORM_TEX(i.uv0, _Mask_r));
				float4 node_4370 = _Time;	
				float2 node_9840 = (i.uv0 + frac((node_4370.g*float2(_U_speed, _V_speed))));
				float4 _Noise_rgba_var = tex2D(_Noise_rgba, TRANSFORM_TEX(node_9840, _Noise_rgba));

				//拆开写解决魅族显示黑色问题.
				//float3 finalColor = ((i.vertexColor.rgb*i.vertexColor.a*_Mask_r_var.r)*_Noise_rgba_var.rgb*(_Noise_rgba_var.rgb*_Color_rgba.rgb* _Color_rgba.a* _Noise_rgba_var.a)*_Power);
				float3 finalColor = i.vertexColor.rgb;
				finalColor *= i.vertexColor.a;
				finalColor *= _Mask_r_var.a;
				finalColor *= _Noise_rgba_var.rgb;
				finalColor *= _Noise_rgba_var.rgb;
				finalColor *= _Color_rgba.rgb;
				finalColor *= _Noise_rgba_var.a;
				finalColor *= _Power;
                float4 finalRGBA = float4(finalColor,_Color_rgba.a);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
