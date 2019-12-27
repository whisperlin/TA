Shader "TA/Test/Reflection"
{
	Properties
	{
		_Cubemap("Cubemap", Cube) = "" {}
		_ReflectionAmount("Reflection Amount", Range(0, 1)) = 0.5
	}

		SubShader
		{
			Pass
			{
				Tags
				{
					"LightMode" = "ForwardBase"
				}
				Cull Off

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase

				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "AutoLight.cginc"

				samplerCUBE _Cubemap;
				float _ReflectionAmount;

				struct appdata
				{
					float4 vertex : POSITION;
					float3 normal : NORMAl;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					fixed4 color : COLOR;
					half3 worldNormal : TEXCOORD0;
					half3 worldPos : TEXCOORD1;
				};

				v2f vert(appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);  
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex);
					return o;
				}

				fixed4 frag(v2f i) : SV_TARGET
				{
				 
					half3 worldView = UnityWorldSpaceViewDir(i.worldPos);
					half3 refDir = reflect(-worldView, i.worldNormal);
					fixed4 refCol = texCUBE(_Cubemap, refDir);

					return refCol;
				 
				}

				ENDCG
			}
		}

			Fallback "VertexLit"
}