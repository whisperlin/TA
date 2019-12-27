Shader "SH/SHResult"
{
	Properties
	{
		[Toggle(ENABLE_FANCY)] _Fancy("Fancy?", Float) = 0
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
			#pragma shader_feature ENABLE_FANCY
			#include "UnityCG.cginc"
			#include "SHGlobal.cginc"
			
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal:NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
			 	float3 worldNormal : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
		 		o.worldNormal = worldNormal;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
#if ENABLE_FANCY
				fixed3 c = g_sh3(i.worldNormal);
#else
				fixed3 c = g_sh(i.worldNormal);
#endif
				
				fixed4 col = float4(c,1);
				//fixed4 col = float4(i.worldNormal,1);
				// apply fog
			 
				return col;
			}
			ENDCG
		}
	}
}
