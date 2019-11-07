/*
*/
Shader "TA/Cartoon bh3"
{
	Properties
	{
		_Color("Main Color", Color) = (0.93137,0.93137,0.93137,1)
		_MainTex("主贴图，a为不受光照影响度", 2D) = "white" {}
		
		_LightMapTex("r：高光强度 g:阴影控制b:高光加强a:阴影颜色标识，全黑为第二套阴影", 2D) = "gray" {}
		_LightSpecColor("高光颜色", Color) = (1,1,1,1)
		_LightArea("阴影范围1", Range(0, 1)) = 0.51
		_LightAreaMultColor("阴影颜色1", Color) = (0.70616,0.67565,0.816,1)
		 _SecondShadow("阴影范围二", Range(0, 1)) = 0.51
		_SecondShadowMultColor("阴影颜色2", Color) = (0.62292,0.53019,0.645,1)

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
				half4 frag(VertexOutput i) : COLOR {

					half4 diffuseMapColor = tex2D(_MainTex, i.uv);
					CalculateOutlineColor(diffuseMapColor.rgb);
					return half4(diffuseMapColor.rgb * _Color.rgb,0) ;
								 
				}
				ENDCG
			}
			


			Pass
			{
				Tags {"LightMode" = "ForwardBase"}
				LOD 100
 
				CGPROGRAM
 

				#pragma vertex vert 
				#pragma fragment frag 				
				#include "UnityCG.cginc" // for UnityObjectToWorldNormal
				#include "UnityLightingCommon.cginc" // for _LightColor0
				struct appdata
				{
					//模型空间中的顶点位置                     
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					float3 normal : NORMAL;
					fixed4 color : COLOR;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float3 wNormal : TEXCOORD1;
					float hlambert :TEXCOORD3;
					float3 viewDir : TEXCOORD2;
					float4 vertex : SV_POSITION;
					fixed4 vertColor : COLOR;
				};
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _LightMapTex;
				float4 _LightMapTex_ST;
				float4 _Color;
				float _LightArea;
				float _SecondShadow;
				float4 _LightAreaMultColor;
				float4 _SecondShadowMultColor;
				float _Shininess;
				float _SpecMulti;
				float3 _LightSpecColor;
				float _BloomFactor;

				v2f vert(appdata v)
				{
					v2f o;
					float4 wpos = mul(unity_ObjectToWorld, v.vertex);
					o.vertex = mul(UNITY_MATRIX_VP, wpos);
					o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,v.vertex).xyz);
					half3 worldNormal = UnityObjectToWorldNormal(v.normal);
					o.wNormal = worldNormal;
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.vertColor = v.color;

 
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
 
					o.hlambert = dot(o.wNormal, normalize(worldLightDir.xyz)) * 0.4975 + 0.5;
					
					return o;
				}



				fixed4 frag(v2f i) : SV_Target
				{
 
					fixed4  maincolor = tex2D(_MainTex, i.uv);
					fixed4  tex_Light_Color = tex2D(_LightMapTex, i.uv);
					fixed4  diffuse = float4(1.0, 1.0, 1.0, _BloomFactor);

					//顶点颜色r通道和lightMapColor.g通道, 两者乘积rg用来做暗面颜色选择 					
					float hlambert = i.hlambert;

					float4  _diffusemask = i.vertColor.x * tex_Light_Color.a;

					if (_diffusemask.a > 0.1)
					{
						if ((hlambert + _diffusemask.g)*0.5 > _LightArea)
						{
							diffuse.xyz = maincolor.xyz;
						}
						else
						{
							diffuse.xyz = maincolor.xyz*_LightAreaMultColor.xyz;

						}
						
					}
					else
					{
						if ((hlambert + _diffusemask.g)*0.5 > _SecondShadow)
						{
							diffuse.xyz = maincolor.xyz;
						}
						else
						{
							diffuse.xyz = maincolor.xyz*_SecondShadowMultColor.xyz;

						}
						
					}
					 
					diffuse.a = 1;
					diffuse = lerp(maincolor,diffuse, 1);
					//return diffuse;
					//高光 
					float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);


					float3 halfView = normalize(lightDirection + i.viewDir);
					half shinepow = pow(max(dot(i.wNormal, halfView), 0.0), _Shininess);
 
					float3 specColor;
					if (shinepow >= (1.0 - tex_Light_Color.b)) {
						specColor = _LightSpecColor * _SpecMulti * tex_Light_Color.r;
					}
					else {
						specColor = float3(0.0, 0.0, 0.0);
					};
					diffuse.rgb = diffuse.rgb + specColor;
					diffuse.rgb = diffuse.rgb * _Color.rgb;

					diffuse.a = _BloomFactor* tex_Light_Color.r;
					return  diffuse;
				}

				ENDCG
			}

	
	}
		
}
