Shader "TA/SimpleCartoonCharactor"
{
	Properties
	{
		_Color ("Main Color", Color) = (1, 1, 1, 1)
		_ShadowColor("Shadow Color",COLOR) = (0.5,0.5,0.5,1)
		_ShadowPower("Shader Power",Range(-1,0)) = 0
		_MainTex ("Texture", 2D) = "white" {}

		_EdgeThickness ("Outline Thickness", Float) = 1
		_EdgeColor ("_EdgeColor", Color) = (0,0,0,1)
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

			half4 VirtualDirectLight0;
			half4 VirtualDirectLightColor0;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 normal: TEXCOORD1;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			half4 _MainTex_ST;
			half4 _ShadowColor;
			half4 _Color;
			half _ShadowPower;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 normal = normalize(i.normal);

				half ndl = dot(normal,  VirtualDirectLight0.rgb );

				float t = step(_ShadowPower,ndl);
				half4 col0 = lerp(_ShadowColor,_Color,t);
				col0.rgb*=VirtualDirectLightColor0.rgb*VirtualDirectLightColor0.a;
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv)*col0;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}

		Pass
		{
			Cull Front
			ZTest Less
			CGPROGRAM

			#define _SIMPLE_OUTLINE 1
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "CharaOutline.cg"
			ENDCG
		}
	}
}
