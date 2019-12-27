Shader "TA/Sky/FaKeReflect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_FadeEdge("",Range(0.05,0.4)) = 0.05
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
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half _FadeEdge;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);


				float3 posWorld = mul(unity_ObjectToWorld, v.vertex);
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - posWorld);
				
				

				v.uv.x = lerp(_FadeEdge,1- _FadeEdge, v.uv.x);
				v.uv.y = lerp(_FadeEdge, 1 - _FadeEdge, v.uv.y);
				v.uv += viewDirection.xz*_FadeEdge;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
