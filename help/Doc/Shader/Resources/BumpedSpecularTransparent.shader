Shader "YuLongZhi/BumpedSpecularTransparent"
{
	Properties
	{
		_Normal ("Normal", 2D) = "bump" {}
		_SpecMap ("SpecMap", 2D) = "white" {}
		_Spec ("Spec", Color) = (1, 1, 1, 1)
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" }
		ZWrite Off
		Blend SrcAlpha One
		Offset -1, -1

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				half2 uv2 : TEXCOORD1;
				half3 normal : NORMAL;
				half4 tangent : TANGENT;
			};

			struct v2f
			{
				half4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
				half3 tspace0 : TEXCOORD2;
				half3 tspace1 : TEXCOORD3;
				half3 tspace2 : TEXCOORD4;
				float3 posWorld : TEXCOORD5;
			};

			sampler2D _Normal;

			sampler2D _SpecMap;
			fixed3 _Spec;
			half _Smoothness;

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;

				half3 normal = UnityObjectToWorldNormal(v.normal);
                half3 tangent = UnityObjectToWorldDir(v.tangent.xyz);
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 bitangent = cross(normal, tangent) * tangentSign;

				o.tspace0 = half3(tangent.x, bitangent.x, normal.x);
                o.tspace1 = half3(tangent.y, bitangent.y, normal.y);
                o.tspace2 = half3(tangent.z, bitangent.z, normal.z);

				UNITY_TRANSFER_FOG(o, o.pos);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				half3 n = UnpackNormal(tex2D(_Normal, i.uv));

				half3 normal;
                normal.x = dot(i.tspace0, n);
                normal.y = dot(i.tspace1, n);
                normal.z = dot(i.tspace2, n);

				normal = normalize(normal);
				half3 viewDir = normalize(UnityWorldSpaceViewDir(i.posWorld));
				half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 lightColor = _LightColor0;

				fixed4 specMap = tex2D(_SpecMap, i.uv);
				fixed3 specColor = _Spec * specMap.rgb;
				half smoothness = _Smoothness * specMap.a;
				
				half nl = saturate(dot(normal, lightDir));
				half roughness = 1 - smoothness;
				half3 halfDir = normalize(lightDir + viewDir);
				half lh = saturate(dot(lightDir, halfDir));
				half nh = saturate(dot(normal, halfDir));
				half roughness2 = roughness * roughness;
				half a = roughness2;
				half a2 = a*a;
				half d = nh * nh * (a2 - 1.h) + 1.00001h;
				half specular = a2 / (max(0.1h, lh*lh) * (roughness2 + 0.5h) * (d * d) * 4);
				specular = specular - 1e-4h;
				
				fixed3 spec = lightColor * specular * specColor;

				fixed4 c = spec.rgbr;

				return c;
			}
			ENDCG
		}
	}
}