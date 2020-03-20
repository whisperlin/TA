Shader "Unlit/RandomDemo"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
				float4 wpos : TEXCOORD2;
				float r : TEXCOORD3;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float random(float2 st, float n) {
				st = floor(st * n);
				return frac(sin(dot(st.xy, float2(12.9898, 78.233)))*43758.5453123);
			}
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float4 wpos = mul(unity_ObjectToWorld, v.vertex);
				o.wpos = wpos;
				o.r = random(wpos.xz, wpos.y);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			 
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 col = i.r;
				//float4 col = random(i.wpos.xz,i.wpos.y);
				return col;
			}
			ENDCG
		}
	}
}
