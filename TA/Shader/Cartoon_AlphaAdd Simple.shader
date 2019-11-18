/*
*/
Shader "TA/Cartoon Anpla Add Simple"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color",Color) = (1,1,1,1)
		//_AlphaClip("AlphaClip",Range(0,1)) = 0.1

		_EdgeThickness("描边宽度", Range(0, 0.1)) = 0.01
		_OutlineScaledMaxDistance("描边不缩放最远距离", Range(1, 10)) = 1
		_brightnessFactor("描边明暗", Range(0, 1)) = 0.8
		_saturationFactor("描边主色调节", Range(0, 1)) = 0.6
		[Space]
		_BloomFactor("bloom Factor", Range(0,1)) = 0
	}

		SubShader
		{

			Tags { "Queue" = "Transparent-1" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
			


			Pass
			{
	 
					//ZWrite Off
					ColorMask 0
					//Blend Zero One
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
 
						float4 vertex : SV_POSITION;
					};

					sampler2D _MainTex;
					float4 _MainTex_ST;
					float4 _Color;
					//float _AlphaClip;
					v2f vert(appdata v)
					{
						v2f o;
						o.vertex = UnityObjectToClipPos(v.vertex);
						o.uv = TRANSFORM_TEX(v.uv, _MainTex);
						return o;
					}
					fixed4 frag(v2f i) : SV_Target
					{
						//fixed4 col = tex2D(_MainTex, i.uv)*_Color;
						//clip(col.a - _AlphaClip);
						return float4(0, 0, 0, 0);
					}
					ENDCG
				}
				 

				Pass
				{
					Cull Off
					//ZWrite Off
					ColorMask RGB
					Blend SrcAlpha One
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
						float4 vertex : SV_POSITION;

					};

					sampler2D _MainTex;
					float4 _MainTex_ST;
					float4 _Color;
					//float _AlphaClip;
					v2f vert(appdata v)
					{
						v2f o;
						o.vertex = UnityObjectToClipPos(v.vertex);
						o.uv = TRANSFORM_TEX(v.uv, _MainTex);
						UNITY_TRANSFER_FOG(o,o.vertex);
						return o;
					}

					fixed4 frag(v2f i) : SV_Target
					{
						// sample the texture
						fixed4 col = tex2D(_MainTex, i.uv)*_Color;

						//clip(col.a - _AlphaClip);
						// apply fog
						//UNITY_APPLY_FOG(i.fogCoord, col);
						return col;
					}
					ENDCG
			}

			Pass{
				Name "Outline"
				Tags {
				}
				Cull Front
				ZWrite Off
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

				uniform float4 _Color;
				struct VertexInput {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float2 uv : TEXCOORD0;
				};
				struct VertexOutput {
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD1;
				};
				sampler2D _MainTex;
				float4 _MainTex_ST;
				//float _AlphaClip;
				VertexOutput vert(VertexInput v) {
					VertexOutput o = (VertexOutput)0;
					o.pos = CalculateOutlineVertexClipPosition(v.vertex,v.normal);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					return o;
				}
				half4 frag(VertexOutput i) : COLOR {

					half4 diffuseMapColor = tex2D(_MainTex, i.uv);
					//clip(diffuseMapColor.a - _AlphaClip);
					CalculateOutlineColor(diffuseMapColor.rgb);
					return half4(diffuseMapColor.rgb * _Color.rgb,0);

				}
				ENDCG
			}

	
	}
		
}
