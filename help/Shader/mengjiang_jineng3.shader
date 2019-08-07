Shader "Shader Forge/mengjiang_jineng3" {
    Properties {
        _node_9059 ("node_9059", 2D) = "white" {}
        _node_6359 ("node_6359", 2D) = "white" {}
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Blend SrcAlpha One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fog
            uniform float4 _TimeEditor;
            uniform sampler2D _node_9059; uniform float4 _node_9059_ST;
            uniform sampler2D _node_6359; uniform float4 _node_6359_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float4 node_2484 = _Time + _TimeEditor;
                float2 node_3969 = (i.uv0+node_2484.g*float2(0.1,0));
                float4 _node_9059_var = tex2D(_node_9059,TRANSFORM_TEX(node_3969, _node_9059));
                float2 node_8309 = (i.uv0+node_2484.g*float2(0.2,0.1));
                float4 _node_6359_var = tex2D(_node_6359,TRANSFORM_TEX(node_8309, _node_6359));
                float3 emissive = ((_node_9059_var.rgb*_node_6359_var.rgb)*i.vertexColor.rgb);
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,(_node_6359_var.a*i.vertexColor.a));
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
}
