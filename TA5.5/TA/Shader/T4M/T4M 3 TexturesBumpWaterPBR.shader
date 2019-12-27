// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TA/T4MShaders/ShaderModel3/Diffuse/T4M 3 Textures Bump PBR Simple" 
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

		_Splat3("Layer 4 (B)", 2D) = "white" {}
		_BumpSplat0("_BumpSplat0", 2D) = "bump" {}
		_BumpSplat1("_BumpSplat1", 2D) = "bump" {}
		_BumpSplat2("_BumpSplat2", 2D) = "bump" {}
		_BumpSplat3("_BumpSplat3", 2D) = "bump" {}

		_TopColor("浅水色", Color) = (0.619, 0.759, 1, 1)
		_ButtonColor("深水色", Color) = (0.35, 0.35, 0.35, 1)
		_Gloss3("水高光锐度", Range(0,1)) = 0.5

	 
		_WaveNormalPower("水法线强度",Range(0,1)) = 1
		_GNormalPower("地表法线强度",Range(0,1)) = 1
		_WaveScale("水波纹缩放", Range(0.02,0.15)) = .07
		_WaveSpeed("水流动速度", Vector) = (19,9,-16,-7)
		_SpecColor3("水高光色", Color) = (1, 1, 1, 1)

		[KeywordEnum(Off, On)] _IsMetallic("是否开启金属度", Float) = 0

		metallic_power("天空强度", Range(0,1)) = 1
 
		_Shininess("三层高光锐度", Vector) = (0.078125,0.078125,0.078125,0.078125)
		
		_Control ("Control (RGBA)", 2D) = "white" {}
		_MainTex ("Never Used", 2D) = "white" {}

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
			#include "UnityCG.cginc"
			#include "../height-fog.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc" //第三步// 

			#pragma multi_compile _ISMETALLIC_OFF _ISMETALLIC_ON  

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
				UNITY_FOG_COORDS_EX(3)
				float3 normalDir : TEXCOORD4;
				float3 SH : TEXCOOR7;

				float3 tangentDir : TEXCOORD8;
				float3 bitangentDir : TEXCOORD9;
				float4 pos : SV_POSITION;
			};

			sampler2D _Control;
			sampler2D _Splat0,_Splat1,_Splat2, _Splat3;
			float4 _Splat0_ST,_Splat1_ST,_Splat2_ST, _Splat3_ST;
			sampler2D _BumpSplat0, _BumpSplat1, _BumpSplat2,_BumpSplat3;
 
			float4 _SpColor0, _SpColor1, _SpColor2, _SpecColor3;
			uniform sampler2D _NormaLMap; uniform float4 _NormaLMap_ST;
#ifdef BRIGHTNESS_ON
			fixed3 _Brightness;
#endif



			float ArmBRDF(float roughness, float NdotH, float LdotH)
			{
				float n4 = roughness * roughness*roughness*roughness;
				float c = NdotH * NdotH   *   (n4 - 1) + 1;
				float b = 4 * 3.14*       c*c  *     LdotH*LdotH     *(roughness + 0.5);
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
				UNITY_TRANSFER_FOG_EX(o, o.pos, o.posWorld, o.normalDir);
				return o;
			}
			float _Gloss0, _Gloss1, _Gloss2 , _Gloss3,_GlossAB, _GlossCtrl;


			uniform float4 _WaveSpeed;
			uniform float _WaveScale;
			uniform float _WaveNormalPower;
			uniform float _GNormalPower;

			float4 _TopColor;
			float4	_ButtonColor;
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
				float3 _NormaLMap_var0 = UnpackNormal(tex2D(_BumpSplat0, TRANSFORM_TEX(i.uv, _Splat0)));
				float3 _NormaLMap_var1 = UnpackNormal(tex2D(_BumpSplat1, TRANSFORM_TEX(i.uv, _Splat1)));
				float3 _NormaLMap_var2 = UnpackNormal(tex2D(_BumpSplat2, TRANSFORM_TEX(i.uv, _Splat2)));
		 
				float3 normalDirection0 = normalize(mul(_NormaLMap_var0.rgb, tangentTransform));
				//return float4((normalDirection0 + 1)*0.5, 1);
				float3 normalDirection1 = normalize(mul(_NormaLMap_var1.rgb, tangentTransform));
				float3 normalDirection2 = normalize(mul(_NormaLMap_var2.rgb, tangentTransform));

				half4 temp = i.posWorld.xzxz * _WaveScale + _WaveSpeed * _WaveScale * _Time.y;
				temp.xy *= float2(.4, .45);

				half3 bump1 = UnpackNormal(tex2D(_BumpSplat3,  temp.xy )).rgb;
				half3 bump2 = UnpackNormal(tex2D(_BumpSplat3,  temp.zw )).rgb;
				half3 bump = (bump1 + bump2) * 0.5;

				float3 normalDirection3 = normalize(mul(bump.rgb, tangentTransform));
				//float3 normalDirection3 = normalize(mul(normalLocal3, tangentTransform));
				
				half3 waterNormal = normalize(lerp( i.normalDir, normalDirection3, _WaveNormalPower));
				
				half4 splat_control = tex2D (_Control, i.uv);//+ waterNormal *splat_control.a
				half3 col;

			 
				half3 nor = normalDirection0 * splat_control.r + normalDirection1 * splat_control.g + normalDirection2 * splat_control.b;
			 
				nor = nor+waterNormal * splat_control.a;
				 
				
				float3 normalDirection = normalize(nor);
 
				half4 splat0 = tex2D (_Splat0, TRANSFORM_TEX(i.uv, _Splat0));
				half4 splat1 = tex2D (_Splat1, TRANSFORM_TEX(i.uv, _Splat1));
				half4 splat2 = tex2D (_Splat2, TRANSFORM_TEX(i.uv, _Splat2));
				
 

				

				//half4 splat3 = tex2D(_Splat3, TRANSFORM_TEX(i.uv, _Splat3));
	
				col = splat_control.r * splat0.rgb;

				col += splat_control.g * splat1.rgb;
	
				col += splat_control.b * splat2.rgb;

#if _ISMETALLIC_OFF
				half3 waterColor = lerp(_TopColor, _ButtonColor, splat_control.a) ;

#else
				half3 viewReflectDirection = reflect(-viewDir, waterNormal);
				half2 skyUV = half2(ToRadialCoords(viewReflectDirection));
				half4 splat3 = tex2D(_Splat3, skyUV);
				half3 waterColor = lerp(_TopColor, _ButtonColor, splat_control.a)* lerp(half3(1,1,1),splat3.rgb,metallic_power) ;
#endif
				

				col += splat_control.a * waterColor;// splat2.rgb;

				//splat3
				half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				half4 c = half4(col.rgb,1);
				fixed3 lm = 1;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));
				c.rgb *= lm;
#else
				
				
				half nl = saturate(dot(normalDirection, lightDir));
				c.rgb = i.SH * c.rgb + _LightColor0 * nl * c.rgb* LIGHT_ATTENUATION(i);
		 
#endif
				
				


				float _Gloss = _Gloss0 * splat_control.r + _Gloss1 * splat_control.g + _Gloss2 * splat_control.b + _Gloss3 * splat_control.a;
				//_Gloss = lerp(_Gloss, _GlossAB, _ab);
				//return _ab*float4(1,0,0,1)+(1- _ab);


				float4 _SpColor = _SpColor0 * splat_control.r + _SpColor1 * splat_control.g + _SpColor2 * splat_control.b + _SpecColor3 * splat_control.a;
				half perceptualRoughness = 1.0 - _Gloss;
				half roughness = perceptualRoughness * perceptualRoughness;

				float3 halfDirection = normalize(viewDir + lightDir);
				float LdotH = saturate(dot(lightDir, halfDirection));
				float NdotH = saturate(dot(normalDirection, halfDirection));
				float specular = saturate( ArmBRDF(roughness, NdotH, LdotH));
				specular = saturate(specular);
				float ml0 = min(min(lm.r, lm.b), lm.g);
				ml0 = ml0 * ml0*ml0;
#ifdef BRIGHTNESS_ON
				c.rgb = c.rgb * _Brightness * 2 + _SpColor.rgb*ml0;
#else
				c.rgb += _SpColor.rgb*specular*ml0;

#endif
				



				
	 
				APPLY_HEIGHT_FOG(c,i.posWorld, normalDirection, i.fogCoord);

				UNITY_APPLY_FOG_MOBILE(i.fogCoord, c);
				return c;
			}
			ENDCG
		}
	}

	FallBack "Mobile/Diffuse"
}