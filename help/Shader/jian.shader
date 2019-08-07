Shader "Shader Forge/jian" {
    Properties {
        _emission ("emission", Float ) = 1
        _node_9837 ("node_9837", Color) = (0.5,0.5,0.5,1)
        _node_6562 ("node_6562", 2D) = "white" {}
        _node_6770 ("node_6770", 2D) = "white" {}
        _wenli ("wenli", Float ) = 2
        _node_65621 ("node_65621", 2D) = "white" {}
        _niuqu ("niuqu", Float ) = 1
        _node_3577 ("node_3577", 2D) = "white" {}
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
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform float4 _TimeEditor;
            uniform sampler2D _node_6562; uniform float4 _node_6562_ST;
            uniform float _emission;
            uniform float4 _node_9837;
            uniform sampler2D _node_6770; uniform float4 _node_6770_ST;
            uniform float _wenli;
            uniform sampler2D _node_65621; uniform float4 _node_65621_ST;
            uniform float _niuqu;
            uniform sampler2D _node_3577; uniform float4 _node_3577_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float4 vertexColor : COLOR;
                UNITY_FOG_COORDS(3)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float attenuation = 1;
                float3 attenColor = attenuation * _LightColor0.xyz;
/////// Diffuse:
                float NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                float3 indirectDiffuse = float3(0,0,0);
                indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb; // Ambient Light
                float4 _node_6770_var = tex2D(_node_6770,TRANSFORM_TEX(i.uv0, _node_6770));
                float3 node_8380 = (_wenli*_node_6770_var.rgb);
                float3 diffuseColor = node_8380;
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
////// Emissive:
                float4 node_3245 = _Time + _TimeEditor;
                float2 node_3395 = (i.uv0+node_3245.g*float2(0,-0.8));
                float4 _node_65621_var = tex2D(_node_65621,TRANSFORM_TEX(node_3395, _node_65621));
                float2 node_9883 = (i.uv0+(_niuqu*_node_65621_var.r)*float2(0.1,-0.8));
                float4 _node_6562_var = tex2D(_node_6562,TRANSFORM_TEX(node_9883, _node_6562));
                float4 _node_3577_var = tex2D(_node_3577,TRANSFORM_TEX(i.uv0, _node_3577));
                float3 emissive = ((_node_9837.rgb*_node_6562_var.rgb*_node_3577_var.rgb)*i.vertexColor.rgb*node_8380*_emission);
/// Final Color:
                float3 finalColor = diffuse + emissive;
                fixed4 finalRGBA = fixed4(finalColor,(_node_6770_var.a*i.vertexColor.a));
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
