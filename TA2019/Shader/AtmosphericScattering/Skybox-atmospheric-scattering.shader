Shader "Skybox/Atmospheric Scattering" {
	Properties{
		//[KeywordEnum(None, Simple, High Quality)] _SunDisk ("Sun", Int) = 2
		//_SunSize ("Sun Size", Range(0,1)) = 0.04

		//_AtmosphereThickness ("Atmoshpere Thickness", Range(0,5)) = 1.0
		//_SkyTint ("Sky Tint", Color) = (.5, .5, .5, 1)
		
		_SkyTint("Sky Tint", Color) = (.5, .5, .5, 1)
		_AtmosphereThickness("Atmoshpere Thickness", Range(0,5)) = 1.0
		_SkyColorTop("_SkyColorTop", Color) = (0.00392156862745098, 0.13725490196078433, 0.49019607843137253, 1)
		_GroundColor("Ground", Color) = (.369, .349, .341, 1)
		[Toggle(_SUN)] _SUN("太阳", Float) = 1
		_SunColor("太阳色",Color) = (0.8,0.8,0.8,1)

		_SunSize("太阳半径",Range(0.001,0.5)) = 0.04
		[Toggle(_MODE)] _MODE("模型", Float) = 0
	}


		SubShader{
			Tags {
					"Queue" = "Geometry-999"
					"RenderType" = "Opaque"
				}

			Cull Off // ZWrite Off

			Pass {

				CGPROGRAM
					#pragma vertex vert
					#pragma fragment frag
				// make fog work
				#pragma multi_compile_fog

				#pragma   multi_compile  _ _MODE
				#pragma   multi_compile  _ _SUN
				#pragma   multi_compile  _ _SUN_RAY

				#pragma   multi_compile  _ _BUTTOM
				#pragma   multi_compile  _ _CLOUND
				#pragma   multi_compile  _ _CLOUND2
 
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "AtmosphericScattering.cginc"


				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					//float2 uv : TEXCOORD0;
					float4 posWorld:TEXCOORD0;
					float4 vertex : SV_POSITION;
		#if _MODE
					float4 pos : TEXCOORD1;
		#endif

					float2 uv : TEXCOORD2;//云uv.
					float3 skyColor : TEXCOORD3;
					float3 sunColor : TEXCOORD4;
					float3 groundColor : TEXCOORD5;
					//float speed : TEXCOORD3;
				};


				float4 _SkyColorTop;
				float4 _SunColor;
				float _SunSize;
				float _SunPower;
				half _AtmosphereThickness;
				half3 _GroundColor;
 
				//samplerCUBE _Tex;


				float smoothstep0(  float b, float x)
				{
					float t = saturate(x / b );
					return t * t*(3.0 - (2.0*t));
				}
				inline float2 ToRadialCoords(float3 coords)
				{
					float3 normalizedCoords = normalize(coords);
					float latitude = acos(normalizedCoords.y);
					float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
					float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
					return float2(0.5, 1.0) - sphereCoords;
				}

				uniform half3 _SkyTint;

				v2f vert(appdata v)
				{
					v2f o;
					float3 kSkyTintInGammaSpace = COLOR_2_GAMMA(_SkyTint); // convert tint from Linear back to Gamma
					half3 cIn, cOut;
					o.posWorld = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
					
#if _MODE
					o.pos = v.vertex;
#endif
#if _MODE
					float3 eyeRay = normalize(o.pos.xyz);
					o.uv = v.uv;
#else
					float3 eyeRay = normalize(o.posWorld.xyz - _WorldSpaceCameraPos.xyz);
#endif
					RayLeight(kSkyTintInGammaSpace, _AtmosphereThickness, eyeRay, cIn,    cOut);
					o.vertex = mul(UNITY_MATRIX_VP, o.posWorld);
		
					//o.skyColor =    getRayleighPhase(_WorldSpaceLightPos0.xyz, -eyeRay);
					o.skyColor.rgb = cIn * getRayleighPhase(_WorldSpaceLightPos0.xyz, -eyeRay);
					o.sunColor =   cOut * _LightColor0.xyz;

					//o.groundColor =  (cIn + COLOR_2_LINEAR(_GroundColor) * cOut);
					o.groundColor = cIn + COLOR_2_LINEAR(_GroundColor)*cOut;// (cIn + COLOR_2_LINEAR(_GroundColor) * cOut);


#if defined(UNITY_COLORSPACE_GAMMA) && SKYBOX_COLOR_IN_TARGET_COLOR_SPACE
					o.groundColor = sqrt(o.groundColor);
					o.skyColor = sqrt(o.skyColor);
#if SKYBOX_SUNDISK != SKYBOX_SUNDISK_NONE
					o.sunColor = sqrt(o.sunColor);
#endif
#endif
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
		#if _MODE
					float3 viewDirection = normalize(i.pos.xyz);

		#else
					float3 viewDirection0 = i.posWorld.xyz - _WorldSpaceCameraPos.xyz;
					float3 viewDirection = normalize(viewDirection0);

					i.uv.y = saturate(viewDirection.y);

					float longitude = atan2(viewDirection.z, viewDirection.x);
					i.uv.x =  0.5 - longitude * 0.5 / UNITY_PI;
		#endif
					float3 sunDir = normalize(_WorldSpaceLightPos0.xyz);
 
					half y = -viewDirection.y / SKY_GROUND_THRESHOLD;
					half4 cout = half4(lerp(i.skyColor, i.groundColor, saturate(y)), 1);
					//return float4(i.groundColor, 1);
					//cout.rgb = y;
					//half4 cout = half4(i.skyColor,1);
					//return cout;
					//half4 cout = half4(i.groundColor, 1);
					//return cout;
					//float4 cout = _SkyColorTop;
		#if UNITY_COLORSPACE_GAMMA
					cout.rgb = LinearToGammaSpace(cout.rgb);
		#endif

		#if _SUN

					half eyeCos = dot(sunDir, -viewDirection);
					half eyeCos2 = eyeCos * eyeCos;
					half mie = getMiePhase(eyeCos, eyeCos2, _SunSize);
					cout.rgb += mie * i.sunColor;

		#endif
		 
					return cout;

				}
				ENDCG
			}
		}


			Fallback Off

}
