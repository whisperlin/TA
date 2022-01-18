Shader "Lch/Reflection"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_ReflectionPower("Reflection Power",Range(0,1)) = 1
		_ReflectionMinMap(" 镜面反射模糊_ReflectionMinMap",Range(0,5)) = 1
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#define REFLECTION 1
				// make fog work
				#pragma multi_compile_fog

				#include "UnityCG.cginc"
				#include "Reflection.cginc"
				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					UNITY_FOG_COORDS(1)


					float4 worldPos : TEXCOORD2;
					float4 vertex : SV_POSITION;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;



				v2f vert(appdata v)
				{
					v2f o;

					half4 worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
					o.worldPos = worldPos;
					o.vertex = mul(UNITY_MATRIX_VP, worldPos);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);



					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					// sample the texture
					fixed4 col = tex2D(_MainTex, i.uv);


#if REFLECTION

					half4 reflect = GetReflection(i.worldPos);

					col.rgb = lerp(col.rgb, reflect.rgb,_ReflectionPower);

#endif



					// apply fog
					UNITY_APPLY_FOG(i.fogCoord, col);
					return col;
				}
				ENDCG
			}
		}
}
