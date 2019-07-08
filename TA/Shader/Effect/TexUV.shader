// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'


Shader "TA/Effect/TexUV" {
    Properties {
 
        _MainTex1 ("MainTex1", 2D) = "white" {}
        _MainTex2 ("MainTex2", 2D) = "white" {}



        _Scroll ("_Scroll", Vector) = (1,1,0.5,0.5)

      


        
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
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
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
 
            uniform float4 _LightColor0;
 

            uniform sampler2D _MainTex1; uniform float4 _MainTex1_ST;
            uniform sampler2D _MainTex2; uniform float4 _MainTex2_ST;
 

			uniform		half4 _Scroll;
		 

 

            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
                float4 color :COLOR;

            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 uv0 : TEXCOORD0;
                UNITY_FOG_COORDS(1)

            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
 
			    o.pos = UnityObjectToClipPos( v.vertex );
			    half4 u_offset = _Time.x * _Scroll;
				o.uv0.xy = v.texcoord0.xy * _MainTex1_ST.xy + _MainTex1_ST.zw   + u_offset.xy;
 
 				UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
    

			    half4 finalRGBA = tex2D(_MainTex1,i.uv0);
 				UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        
    }
    FallBack "Diffuse"
 
}
