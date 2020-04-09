// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TA/T4MShaders/ShaderModel3/Diffuse/T4M 5 Textures Water Bump ARM Simple" 
{
	Properties
	{
		_Splat0 ("Layer 1 (R)", 2D) = "white" {}
		_SpColor0("_SpColor0", Color) = (1,1,1,1)
		_Gloss0("_Gloss0",Range(0,1)) = 0.23
		_Splat1 ("Layer 2 (G)", 2D) = "white" {}
		_SpColor1("_SpColor1", Color) = (1,1,1,1)
		_Gloss1("_Gloss1",Range(0,1)) = 0.23
		_Splat2 ("Layer 3 (B)", 2D) = "white" {}
		_SpColor2("_SpColor2", Color) = (1,1,1,1)
		_Gloss2("_Gloss2",Range(0,1)) = 0.23

		_Splat3("Layer 3 (B)", 2D) = "white" {}
		_SpColor3("_SpColor3", Color) = (1,1,1,1)
		_Gloss3("_Gloss3",Range(0,1)) = 0.23

		_Splat4("Layer 4 (B)", 2D) = "white" {}
		_SpColor4("_SpColor4", Color) = (1,1,1,1)
		_Gloss4("_Gloss4",Range(0,1)) = 0.23


		_Splat5("Layer 5 (B)", 2D) = "white" {} 
		_Gloss5("水高光锐度", Range(0,1)) = 0.5
		_SpColor5("水高光色", Color) = (1, 1, 1, 1)
		_BumpSplat0("_BumpSplat0", 2D) = "bump" {}
		_BumpSplat1("_BumpSplat1", 2D) = "bump" {}
		_BumpSplat2("_BumpSplat2", 2D) = "bump" {}
		_BumpSplat3("_BumpSplat3", 2D) = "bump" {}
		_BumpSplat4("_BumpSplat4", 2D) = "bump" {}
		_BumpSplat5("_BumpSplat5", 2D) = "bump" {}
		 
		

	 
		
		_Control ("Control (RGBA)", 2D) = "white" {}
		_Control2("Control2 (RGBA)", 2D) = "white" {}
		_MainTex ("Never Used", 2D) = "white" {}
		[Toggle(_ALWAYR_AMB_LIGHT)] _ALWAYR_AMB_LIGHT("烘培不包含环境光", Float) = 1


	}

	//sampler2D _BumpSplat0, _BumpSplat1, _BumpSplat2;

	SubShader
	{
		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma   multi_compile  _  ENABLE_NEW_FOG
			//#pragma   multi_compile  _  _POW_FOG_ON
			#define   _HEIGHT_FOG_ON 1 // #pragma   multi_compile  _  _HEIGHT_FOG_ON
			#define   ENABLE_DISTANCE_ENV 1 // #pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			//#pragma   multi_compile  _ ENABLE_BACK_LIGHT
			#pragma   multi_compile  _  GLOBAL_ENV_SH9

			#pragma   multi_compile  _ _BAKED_LIGHT

			#include "UnityCG.cginc"
			#include "../../Shader/FogCommon.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc" //第三步// 
			
			#include "t4m.cginc"
			#pragma multi_compile _ISMETALLIC_OFF _ISMETALLIC_ON  
			
			#pragma   multi_compile  _ _ALWAYR_AMB_LIGHT

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				float2 uv2 : TEXCOORD1;
#else
 
#endif
				
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				float2 uv2 : TEXCOORD1;
#else
				LIGHTING_COORDS(5,6)
#endif
				
				float4 posWorld:TEXCOORD2;
				UBPA_FOG_COORDS(3)
				float3 normalDir : TEXCOORD4;
				float3 SH : TEXCOOR7;

				float3 tangentDir : TEXCOORD8;
				float3 bitangentDir : TEXCOORD9;
				float4 pos : SV_POSITION;
			};

			sampler2D _Control;
			sampler2D _Control2;
			sampler2D _Splat0,_Splat1,_Splat2, _Splat3, _Splat4, _Splat5;
			float4 _Splat0_ST,_Splat1_ST,_Splat2_ST, _Splat3_ST, _Splat4_ST, _Splat5_ST;
			sampler2D _BumpSplat0, _BumpSplat1, _BumpSplat2, _BumpSplat3,_BumpSplat4, _BumpSplat5;
			float _Gloss0, _Gloss1, _Gloss2, _Gloss3, _Gloss4, _Gloss5;
 
			float4 _SpColor0, _SpColor1, _SpColor2, _SpColor3, _SpColor4, _SpColor5;
			uniform sampler2D _NormaLMap; uniform float4 _NormaLMap_ST;
#ifdef BRIGHTNESS_ON
			fixed3 _Brightness;
#endif

			float4 GlobalTotalColor;

			inline half fixHalf(half f)
			{
				return floor(f * 10000)*0.0001;
			}
			half ArmBRDF(half roughness, half NdotH, half LdotH)
			{

				half n4 = roughness * roughness*roughness*roughness;
				//n4 = fixHalf(n4);
				half c = NdotH * NdotH   *   (n4 - 1) + 1;
				half b = 4 * 3.14*c*c*LdotH*LdotH*(roughness + 0.5);
				b = fixHalf(b);
				return n4 / b;

			}
			v2f vert (appdata v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.pos = UnityObjectToClipPos(v.vertex);
				float4 posWorld = mul(unity_ObjectToWorld, v.vertex); 
				o.posWorld = posWorld;
				o.uv = v.uv;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				o.uv2 = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
				TRANSFER_VERTEX_TO_FRAGMENT(o);
#endif
				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.tangentDir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
				o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);

				o.SH = ShadeSH9(float4(o.normalDir, 1));
				UBPA_TRANSFER_FOG(o, v.vertex);
				return o;
			}
			
 
			float _Gloss;


			float metallic_power;
 

			inline float2 ToRadialCoords(float3 coords)
			{
				float3 normalizedCoords = normalize(coords);
				float latitude = acos(normalizedCoords.y);
				float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
				float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
				return float2(0.5, 1.0) - sphereCoords;
			}
			fixed4 frag (v2f i) : SV_Target
			{


				half3 viewDir = normalize(UnityWorldSpaceViewDir(i.posWorld));
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
 

				T4M_NORMAL_TEXTURE(0);
				T4M_NORMAL_TEXTURE(1);
				T4M_NORMAL_TEXTURE(2);
				T4M_NORMAL_TEXTURE(3);
				T4M_NORMAL_TEXTURE(4);
				T4M_NORMAL_TEXTURE(5);


				T4M_TEXTURE(0);
				T4M_TEXTURE(1);
				T4M_TEXTURE(2);
				T4M_TEXTURE(3);
				T4M_TEXTURE(4);
				T4M_TEXTURE(5);
				
				
				half4 splat_control = tex2D (_Control, i.uv); 
				half4 splat_control2 = tex2D(_Control2, i.uv);
				

 
				half3 nor = normalDirection0 * splat_control.r;
				nor += normalDirection1 * splat_control.g;
				nor += normalDirection2 * splat_control.b;
				nor += normalDirection3 * splat_control.a;
				nor += normalDirection4 * splat_control2.r;
				nor += normalDirection5 * splat_control2.g;
				
			
				float3 normalDirection = normalize(nor);
 
				half3 col;
				col = splat_control.r * splat0.rgb;
				col += splat_control.g * splat1.rgb;
				col += splat_control.b * splat2.rgb;
				col += splat_control.a * splat3.rgb;
				col += splat_control2.r * splat4.rgb;

				col += splat_control2.g * splat5.rgb;
				
 

				//splat3
				half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				half4 c = half4(col.rgb,1);
				fixed3 lm = 1;
#if _ALWAYR_AMB_LIGHT
				half nl = saturate(dot(normalDirection, lightDir));

#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));
				c.rgb = (i.SH * c.rgb + _LightColor0 * nl * c.rgb)* lm;
#else
				c.rgb = i.SH * c.rgb + _LightColor0 * nl * c.rgb * LIGHT_ATTENUATION(i);
#endif



#else
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));
				c.rgb *= lm;
#else

				half nl = saturate(dot(normalDirection, lightDir));
				c.rgb = i.SH * c.rgb + _LightColor0 * nl * c.rgb* LIGHT_ATTENUATION(i);
#endif

#endif
				


				float _Gloss = _Gloss0 * splat_control.r;
				_Gloss += _Gloss1 * splat_control.g;
				_Gloss += _Gloss2 * splat_control.b;
				_Gloss += _Gloss3 * splat_control.a;
				_Gloss += _Gloss4 * splat_control2.r;
				_Gloss += _Gloss5 * splat_control2.g;
				float4 _SpColor = _SpColor0 * splat_control.r;
				_SpColor += _SpColor1 * splat_control.g;
				_SpColor += _SpColor2 * splat_control.b;
				_SpColor += _SpColor3 * splat_control.a;
				_SpColor += _SpColor4 * splat_control2.r;
				_SpColor += _SpColor5 * splat_control2.g;
				half perceptualRoughness = 1.0 - _Gloss;
				half roughness = perceptualRoughness * perceptualRoughness;
				float3 halfDirection = normalize(viewDir + lightDir);
				float LdotH = saturate(dot(lightDir, halfDirection));
				float NdotH = saturate(dot(normalDirection, halfDirection));
				float specular = saturate( ArmBRDF(roughness, NdotH, LdotH));
				specular = saturate(specular);
				float ml0 = min(min(lm.r, lm.b), lm.g);
				ml0 = ml0 * ml0*ml0;
				c.rgb += _SpColor.rgb*specular*ml0;
#ifdef BRIGHTNESS_ON
				c.rgb = c.rgb * _Brightness * 2;
#endif
				
				c.rgb *= GlobalTotalColor.rgb;
				UBPA_APPLY_FOG(i, c);

				return c;
			}
			ENDCG
		}
	}

	FallBack "Mobile/Diffuse"
}