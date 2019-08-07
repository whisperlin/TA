Shader "YuLongZhi/CharacterPBR"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Normal ("Normal", 2D) = "bump" {}
		_CubeMap ("CubeMap", CUBE) = "" {}
		_SpecRefSmoothnessEmissive ("Spec Ref Smoothness Emissive", 2D) = "white" {}
		_Spec ("Spec", Color) = (0, 0, 0, 0)
		_Ref ("Ref", Color) = (0, 0, 0, 0)
		_Smoothness ("Smoothness", Range(0, 1)) = 0
		_Emissive ("Emissive", Color) = (0, 0, 0, 0)

		_Light1Color ("Light1 Color", Color) = (1, 1, 1, 1)
		_Intensity1 ("Light1 Intensity", Range(0, 10)) = 0
		_Light1Direction ("Light1 Direction", Vector) = (0, 0, 0, 1)
		_Light2Color ("Light2 Color", Color) = (1, 1, 1, 1)
		_Intensity2 ("Light2 Intensity", Range(0, 10)) = 0
		_Light2Direction ("Light2 Direction", Vector) = (0, 0, 0, 1)

		[HideInInspector] _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
		[HideInInspector] _RimPow ("Rim Pow", Range(0, 10)) = 1
		[HideInInspector] _HighLight ("High Light", Range(0, 1)) = 0
		[HideInInspector] _DissolveTex ("Dissolve Tex", 2D) = "white" {}
		[HideInInspector] _Dissolve ("Dissolve", Range(0, 1)) = 0
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"Queue" = "AlphaTest+2"
		}

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma multi_compile __ RIM_ON
			#pragma multi_compile __ DISSOLVE_ON

			#include "UnityCG.cginc"

			struct appdata
			{
				fixed4 vertex : POSITION;
				fixed2 uv : TEXCOORD0;
				fixed3 normal : NORMAL;
				fixed4 tangent : TANGENT;
			};

			struct v2f
			{
				fixed4 pos : SV_POSITION;
				fixed2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				half3 tspace0 : TEXCOORD2;
				half3 tspace1 : TEXCOORD3;
				half3 tspace2 : TEXCOORD4;
				float3 posWorld : TEXCOORD5;
			};

			sampler2D unity_NHxRoughness;

			sampler2D _MainTex;
			sampler2D _Normal;
			samplerCUBE _CubeMap;
			sampler2D _SpecRefSmoothnessEmissive;
			fixed3 _Spec;
			fixed3 _Ref;
			fixed _Smoothness;
			fixed3 _Emissive;

			fixed3 _Light1Color;
			fixed _Intensity1;
			half3 _Light1Direction;
			fixed3 _Light2Color;
			fixed _Intensity2;
			half3 _Light2Direction;

#ifdef RIM_ON
			fixed3 _RimColor;
			fixed _RimPow;
#endif

			fixed _HighLight;

#ifdef DISSOLVE_ON
			sampler2D _DissolveTex;
			float _Dissolve;
#endif

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

			inline half2 Pow4 (half2 x) { return x*x*x*x; }

			fixed4 frag (v2f i) : SV_Target
			{
#ifdef DISSOLVE_ON
				float4 dissolve = tex2D(_DissolveTex, i.uv);
				float dis = _Dissolve * 1.05;
				float dis_width = 0.03;
				float dis_param_a = 0.0;
                float dis_param_b = 1.0;
                float dis_step_a = step((dissolve.r + dis_width), dis);
                float dis_step_b = step(dis, (dissolve.r + dis_width));
                float dis_lerp_a = lerp((dis_step_a * dis_param_a) + (dis_step_b * dis_param_b), dis_param_a, dis_step_a * dis_step_b);
                clip(dis_lerp_a - 0.5);
#endif

				fixed4 c = tex2D(_MainTex, i.uv);
				fixed3 n = UnpackNormal(tex2D(_Normal, i.uv));

				half3 normal;
                normal.x = dot(i.tspace0, n);
                normal.y = dot(i.tspace1, n);
                normal.z = dot(i.tspace2, n);

				normal = normalize(normal);
				half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.posWorld));
				half3 lightDir = normalize(_Light1Direction);
				fixed3 lightColor = _Light1Color * _Intensity1;

				half3 viewNormal = mul((float3x3) UNITY_MATRIX_V, normal);
				half3 viewDir = mul((float3x3) UNITY_MATRIX_V, worldViewDir);

				fixed4 srse = tex2D(_SpecRefSmoothnessEmissive, i.uv);
				fixed3 specColor = _Spec * srse.r;
				fixed3 refColor = _Ref * srse.g;
				half smoothness = _Smoothness * srse.b;
				fixed3 emissiveColor = _Emissive * srse.a;

				half roughness = 1 - smoothness;
				
				half reflectivity = max(max(refColor.r, refColor.g), refColor.b);
				half oneMinusReflectivity = 1 - reflectivity;

				half3 reflDir = reflect(viewDir, viewNormal);
				half nl = saturate(dot(viewNormal, lightDir));
				half nv = saturate(dot(viewNormal, viewDir));
				half nl2 = saturate(dot(viewNormal, normalize(_Light2Direction)));

				half2 rlPow4AndFresnelTerm = Pow4(half2(dot(reflDir, lightDir), 1 - nv));
				half rlPow4 = rlPow4AndFresnelTerm.x;
				half fresnelTerm = rlPow4AndFresnelTerm.y;
				half grazingTerm = saturate(smoothness + reflectivity);

				half LUT_RANGE = 16.0;
				half specular = tex2D(unity_NHxRoughness, half2(rlPow4, roughness)).UNITY_ATTEN_CHANNEL * LUT_RANGE;
				
				fixed3 ambient = 0.5 * c.rgb;
				fixed3 diffuse = ambient + lightColor * nl * c.rgb + _Light2Color * _Intensity2 * nl2 * c.rgb;
				fixed3 spec = lightColor * nl * specular * specColor;

				half3 reflUVW = reflect(-worldViewDir, normal);
				fixed3 env = texCUBE(_CubeMap, reflUVW).rgb;
				fixed3 gi = env * lerp(refColor, grazingTerm, fresnelTerm);
				
				c.rgb = diffuse * oneMinusReflectivity + gi + spec;

				c.rgb += emissiveColor;

#ifdef RIM_ON
				fixed3 rim = pow(1.0 - max(0, dot(normal, worldViewDir)), _RimPow) * _RimColor;
				c.rgb += rim;
#endif

				c.rgb += _HighLight;

#ifdef DISSOLVE_ON
				float dis_border = 3.32;
				float3 dis_c = float3(1, 0.424, 0.047);
				float dis_step_c = step(dissolve.r, dis);
                float dis_step_d = step(dis, dissolve.r);
                c.rgb = (c.rgb + ((dis_c * (dis_lerp_a - lerp((dis_step_c * dis_param_a) + (dis_step_d * dis_param_b), dis_param_a, dis_step_c * dis_step_d))) * dis_border));
#endif

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, c);
				return c;
			}
			ENDCG
		}
	}
}
