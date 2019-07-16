Shader "TA/Cutout"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	    _CutAlpha ("CutAlpha", Range(0, 1)) = 0.5
	}

	SubShader
	{
		Tags { "Queue" = "AlphaTest" }
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#include "UnityCG.cginc"
			#include "height-fog.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				UNITY_FOG_COORDS_EX(2)
				float4 wpos:TEXCOORD3;
				float3 normalWorld : TEXCOORD4;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float _CutAlpha;

#ifdef BRIGHTNESS_ON
			fixed3 _Brightness;
#endif

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				float4 wpos = mul(unity_ObjectToWorld, v.vertex); 
				o.wpos = wpos;
				o.uv = v.uv;
				o.uv2 = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
				o.normalWorld = UnityObjectToWorldNormal(v.normal);
				UNITY_TRANSFER_FOG_EX(o, o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				clip(c.a - _CutAlpha);

				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));
				c.rgb *= lm;

#ifdef BRIGHTNESS_ON
				c.rgb = c.rgb * _Brightness * 2;
#endif
				APPLY_HEIGHT_FOG(c,i.wpos,i.normalWorld,i.fogCoord);
				UNITY_APPLY_FOG(i.fogCoord, c);
				return c;
			}
			ENDCG
		}
	}
}