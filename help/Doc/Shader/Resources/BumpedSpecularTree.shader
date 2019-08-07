Shader "YuLongZhi/BumpedSpecularTree"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_Normal ("Normal", 2D) = "bump" {}
		_SpecMap ("SpecMap", 2D) = "white" {}
		_Spec ("Spec", Color) = (1, 1, 1, 1)
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5

		_CutAlpha ("CutAlpha", Range(0, 1)) = 0.5

		_Frequency ("Frequency", float) = 1
		_Wind ("Wind", Vector) = (0, 0, 0.1, 0)
	}

	SubShader
	{
		Tags { "Queue" = "AlphaTest" }
		Cull Off

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				half4 vertex : POSITION;
				fixed4 color : COLOR;
				half2 uv : TEXCOORD0;
				half2 uv2 : TEXCOORD1;
				half3 normal : NORMAL;
				half4 tangent : TANGENT;
			};

			struct v2f
			{
				half4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				half3 tspace0 : TEXCOORD2;
				half3 tspace1 : TEXCOORD3;
				half3 tspace2 : TEXCOORD4;
				float3 posWorld : TEXCOORD5;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				half2 uv2 : TEXCOORD6;
#endif
			};

			//sampler2D unity_NHxRoughness;

			fixed4 _Color;
			sampler2D _MainTex;
			half4 _MainTex_ST;
			sampler2D _Normal;

			sampler2D _SpecMap;
			fixed3 _Spec;
			half _Smoothness;

			fixed _CutAlpha;

			half _Frequency;
			half4 _Wind;

#ifdef BRIGHTNESS_ON
			fixed3 _Brightness;
#endif

			v2f vert (appdata v)
			{
				v2f o;

				fixed wave_offset = v.color.r;
				fixed wave_weight = v.color.g;

				v.vertex.xyz += _Wind.xyz * cos(_Time.y * _Frequency + wave_offset * 3.14159) * wave_weight;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;

				half3 normal = UnityObjectToWorldNormal(v.normal);
                half3 tangent = UnityObjectToWorldDir(v.tangent.xyz);
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 bitangent = cross(normal, tangent) * tangentSign;

				o.tspace0 = half3(tangent.x, bitangent.x, normal.x);
                o.tspace1 = half3(tangent.y, bitangent.y, normal.y);
                o.tspace2 = half3(tangent.z, bitangent.z, normal.z);

#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				o.uv2 = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
#endif

				UNITY_TRANSFER_FOG(o, o.pos);
				return o;
			}

			//inline half2 Pow4 (half2 x) { return x*x*x*x; }

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv) * _Color;
				clip(c.a - _CutAlpha);

				fixed3 n = UnpackNormal(tex2D(_Normal, i.uv));

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

				half3 reflDir = reflect(viewDir, normal);
				half nl = saturate(dot(normal, lightDir));
				half nv = saturate(dot(normal, viewDir));
				half2 rlPow4AndFresnelTerm = Pow4(half2(dot(reflDir, lightDir), 1 - nv));
				half rlPow4 = rlPow4AndFresnelTerm.x;
				half LUT_RANGE = 16.0;
				half specular = tex2D(unity_NHxRoughness, half2(rlPow4, 1 - smoothness)).UNITY_ATTEN_CHANNEL * LUT_RANGE;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * c.rgb;
				fixed3 diffuse = ambient + lightColor * nl * c.rgb;
				fixed3 spec = lightColor * specular * specColor;

#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));
				diffuse *= lm;
#endif

				c.rgb = diffuse + spec;

#ifdef BRIGHTNESS_ON
				c.rgb = c.rgb * _Brightness * 2;
#endif

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, c);
				return c;
			}
			ENDCG
		}
	}
}
