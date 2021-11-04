Shader "SimplestInstancedShader"
{
    Properties
    {
		 _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)

		_Offset ("_Offset", Range(0,1)) =1
		_OffsetDistance ("_OffsetDistance", Range(0,1)) =1
		
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				 float2 uv : TEXCOORD0;
				 float3 normal: NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				 float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID // necessary only if you want to access instanced properties in __fragment Shader__.
            };
			sampler2D _MainTex;
            float4 _MainTex_ST;
			float _OffsetDistance;
            UNITY_INSTANCING_BUFFER_START(Props)
				 UNITY_DEFINE_INSTANCED_PROP(float, _Offset)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
            UNITY_INSTANCING_BUFFER_END(Props)
           
            v2f vert(appdata v)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o); // necessary only if you want to access instanced properties in the fragment Shader.

				float _os = UNITY_ACCESS_INSTANCED_PROP(Props, _Offset);
				v.vertex.xyz+=v.normal.xyz * _os*_OffsetDistance;
				 o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }
           
            fixed4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i); // necessary only if any instanced properties are going to be accessed in the fragment Shader.

				fixed4 col = tex2D(_MainTex, i.uv);
				float _os = UNITY_ACCESS_INSTANCED_PROP(Props, _Offset);
			 
				clip(col.r - _os );
                return col*UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
            }
            ENDCG
        }
    }
}
