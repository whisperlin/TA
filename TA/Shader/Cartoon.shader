Shader "TA/bh3 Cartoon"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_BloomFactor("Bloom Factor", Float) = 1
		_LightMapTex("Light Map Tex (RGB)", 2D) = "gray" {}
		_LightSpecColor("Light Specular Color", Color) = (1,1,1,1)
		[HideInInspector] _FirstShadow("Light Area Threshold", Range(0, 1)) = 0.51
		[HideInInspector] _SecondShadow("Second Shadow Threshold", Range(0, 1)) = 0.51
		_FirstShadowMultColor("First Shadow Multiply Color", Color) = (0.9,0.7,0.75,1)
		_SecondShadowMultColor("Second Shadow Multiply Color", Color) = (0.75,0.6,0.65,1)
		_Shininess("Specular Shininess", Range(0.1, 100)) = 10
		_SpecMulti("Specular Multiply Factor", Range(0, 1)) = 0.1


		_EdgeThickness("Outline Width", Range(0, 0.01)) = 0.01
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_FadeDistance("Fade Start Distance", Range(0.1, 10)) = 0.5
		_FadeOffset("Fade Start Offset", Range(0, 10)) = 1
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
 
			#pragma multi_compile_shadowcaster
			#pragma multi_compile_fog
  
			uniform float _EdgeThickness;
			uniform float4 _OutlineColor;
			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct VertexOutput {
				float4 pos : SV_POSITION;
				UNITY_FOG_COORDS(0)
			};
			VertexOutput vert(VertexInput v) {
				VertexOutput o = (VertexOutput)0;
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float4 worldPos = mul(unity_ObjectToWorld,   v.vertex);
				worldPos.xyz /= worldPos.w;
				worldPos.w = 1;
				worldPos.xyz = worldPos.xyz + worldNormal * _EdgeThickness;
				o.pos = mul(UNITY_MATRIX_VP,worldPos);
				//o.pos = UnityObjectToClipPos( float4(v.vertex.xyz + v.normal*_EdgeThickness,1) );
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			float4 frag(VertexOutput i) : COLOR {
				return fixed4(_OutlineColor.rgb,0);
			}
			ENDCG
		}
			


			Pass
			{
				Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
				Blend SrcAlpha OneMinusSrcAlpha
				LOD 100
				//Cull Front
				CGPROGRAM
 

				#pragma vertex vert 
				#pragma fragment frag 				
				#include "UnityCG.cginc" 
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
				float _FirstShadow;
				float _SecondShadow;
				float4 _FirstShadowMultColor;
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

#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - wpos);
#endif
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
					float  _diffusemask = i.vertColor.x * tex_Light_Color.y;
					if (_diffusemask > 0.1)
					{
						float firstmask = _diffusemask > 0.5 ? _diffusemask * 1.2 - 0.1 : _diffusemask * 1.25 - 0.125;
						bool islight = (firstmask + hlambert)* 0.5 > _FirstShadow;
						diffuse.xyz = islight ? maincolor.xyz : maincolor.xyz*_FirstShadowMultColor.xyz;
					}
					else
					{
						bool isfirst = (_diffusemask + hlambert)*0.5 > _SecondShadow;
						diffuse.xyz = isfirst ? maincolor.xyz*_FirstShadowMultColor : maincolor.xyz*_SecondShadowMultColor.xyz;
					}
					diffuse.a = 1;
					diffuse = lerp(maincolor,diffuse, 1);
					//高光 
					float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
					float3 halfView = normalize(lightDirection + i.viewDir);
					half shinepow = pow(max(dot(i.wNormal, halfView), 0.0), _Shininess);
					 
					float3 specColor;
					if (shinepow >= (1.0 - tex_Light_Color.z)) {
						specColor = _LightSpecColor * _SpecMulti * tex_Light_Color.x;
					}
					else {
						specColor = float3(0.0, 0.0, 0.0);
					};
					diffuse.rgb = diffuse.rgb + specColor;
					diffuse.rgb = diffuse.rgb * _Color.rgb;


					return  diffuse;
				}

				ENDCG
			}

	
	}
		
}
