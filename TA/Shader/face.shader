// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Ta/Cartoon face bh3 "
{
	Properties
	{
		_MainTex("主贴图", 2D) = "white" {}
		_LightMapTex("光照贴图", 2D) = "white" {}
		_FaceMapTex("阴影调亮", 2D) = "white" {}
		_Color("颜色",Color) = (0.93137, 0.93137, 0.93137, 0.95)
		_EnvColor("环境光色",Color) = (1.00, 1.00, 1.00, 1.00)
		_ShadowColor("阴影色",Color) = (0.92157, 0.74002, 0.76398)
		_ShadowFeather("阴影区域调节",Range(0,1)) = 0.5


		_Shininess("高光锐度", Range(0.1, 100)) = 10
		_SpecMulti("高光强度", Range(0, 1)) = 0.20
		_EdgeThickness("描边宽度", Range(0, 0.1)) = 0.01
		_OutlineScaledMaxDistance("描边不缩放最远距离", Range(1, 10)) = 1
		_brightnessFactor("描边明暗", Range(0, 1)) = 0.8
		_saturationFactor("描边主色调节", Range(0, 1)) = 0.6

		[Space]
		_BloomFactor("bloom Factor", Range(0,1)) = 0
	}



		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100

			Pass {
				Name "Outline"
				Tags {
				}
				Cull Front

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				#define MTOON_OUTLINE_WIDTH_SCREEN 1
				#include "outline.cginc"

				#pragma multi_compile_shadowcaster
				#pragma multi_compile_fog

				#define BRIGHTNESS_FACTOR 0.8
				#define SATURATION_FACTOR 0.5


			//uniform float _EdgeThickness;
			//uniform float4 _OutlineColor;
			uniform float4 _Color;
			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};
			struct VertexOutput {
				float4 pos : SV_POSITION;
				UNITY_FOG_COORDS(0)
				float2 uv : TEXCOORD1;
			};
			sampler2D _MainTex;
			float4 _MainTex_ST;

			VertexOutput vert(VertexInput v) {
				VertexOutput o = (VertexOutput)0;
				o.pos = CalculateOutlineVertexClipPosition(v.vertex,v.normal);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			half4 frag(VertexOutput i) : COLOR{

					half4 diffuseMapColor = tex2D(_MainTex, i.uv);
					CalculateOutlineColor(diffuseMapColor.rgb);
					return half4(diffuseMapColor.rgb * _Color.rgb,0);

			}
			ENDCG
		}

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				// make fog work
				#pragma multi_compile_fog

				#include "UnityCG.cginc"



 
				uniform float _lightProbToggle; //0
				uniform float4 _lightProbColor;//(0,0,0,0)

				uniform float4 _Color;
				uniform float4 _EnvColor;
				uniform float _BloomFactor;
				uniform float3 _ShadowColor;
				uniform float _ShadowFeather;

				uniform sampler2D _LightMapTex;
				uniform sampler2D _FaceMapTex;

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;

					float3 normal:NORMAL;

				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float3 wnormal: TEXCOORD1;
					float3 wpos : TEXCOORD2;
					float4 param3 : TEXCOORD3;
					float hlambert : TEXCOORD4;
					float3 param5 : TEXCOORD5;
					float4 vertex : SV_POSITION;
					float4 color : COLOR;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;

				v2f vert(appdata v)
				{
					v2f o;
 
					float3 wpos = mul(unity_ObjectToWorld, v.vertex);
					o.wpos = wpos;
					o.vertex = UnityWorldToClipPos(wpos);
					o.color = float4(0.0, 0.0, 0.0, 0.0);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);




					float3 wNormal = UnityObjectToWorldNormal(v.normal);
					o.wnormal = wNormal;

					o.hlambert = dot(o.wnormal, normalize(_WorldSpaceLightPos0.xyz)) * 0.4975 + 0.5;

					 
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{

					fixed4  maincolor = tex2D(_MainTex, i.uv);
					fixed4  tex_Light_Color = tex2D(_LightMapTex, i.uv);
					fixed4  diffuse = float4(1.0, 1.0, 1.0, _BloomFactor);
 
					float hlambert = i.hlambert;

					float  _diffusemask = tex_Light_Color.r;
					float t = tex2D(_FaceMapTex, i.uv).r;
					
					hlambert += t ;
					hlambert = clamp(hlambert,0,1);
					hlambert = hlambert * tex_Light_Color.g;
					if (hlambert > _ShadowFeather)
					{
						diffuse.xyz = maincolor.xyz;
					}
					else
					{
						diffuse.xyz = maincolor.xyz*_ShadowColor.xyz;
					}

					//

					diffuse.xyz *= _EnvColor.xyz;
					diffuse.a = _BloomFactor * tex_Light_Color.r;
					return diffuse;


				}
				ENDCG
			}
		}
}
