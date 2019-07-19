Shader "TA/Water (Primary)" {
	Properties{
		[NoScaleOffset] _ColorControl("深度控制图", 2D) = "white" { }
		[NoScaleOffset] _BumpMap("NormalTexture", 2D) = "" { }

		_TopColor("浅水色", Color) = (0.619, 0.759, 1, 1)
		_ButtonColor("深水色", COLOR) = (.172 , .463 , .435 , 0)
		_WaveScale("水波浪缩放", Range(0.02,0.15)) = .07
		_WaveSpeed("水波浪速度", Vector) = (19,9,-16,-7)
		_WaveNormalPower("水法线强度",Range(0,1)) = 1
		_ShininessL("水光照调节", Range(0.03, 1)) = 0.03
		_WSpecColor("水高光颜色",Color) = (1,1,1,1)
		_Gloss("水高光亮度", Range(0,1)) = 0.5


		_Sky("天空", 2D) = "white" {}
 
		metallic_power("天空强度", Range(0,1)) = 1
		metallic_color("天空颜色", Color) = (1, 1, 1, 0)

		waterPower("深水区域深度",Range(0.1,10)) = 10
		waterAlpha("Alpha区域深度",Range(0.1,10)) = 10
		_Alpha("透明度",Range(0,1)) = 0.8
		 
		//[NoScaleOffset] _developCamera("调试相机", 2D) = "white" { }
		
	}

		CGINCLUDE


		#pragma multi_compile __  __CREATE_DEPTH_MAP 
		#pragma multi_compile __  __CREATE_DEPTH_MAP2 
		#include "UnityCG.cginc"
		#define ENABLE_FOG_EX  1

		#if ENABLE_FOG_EX
		#include "../Shader/height-fog.cginc"
		#endif
		#include "UnityLightingCommon.cginc" // for _LightColor0


		uniform half4 _ButtonColor;
		uniform half4 _TopColor;
		uniform half4 _WSpecColor;
		uniform half4 _WaveSpeed;
		uniform float _WaveScale;
		uniform half _ShininessL;
		uniform half _Gloss;
		uniform sampler2D _Sky;
 
 
		uniform half waterPower;
		uniform half waterToolctrlPower;
		uniform half waterAlpha;
		uniform half _WaveNormalPower;
		struct appdata {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 tangent : TANGENT;
			float2 uv : TEXCOORD0;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			float2 bumpuv[2] : TEXCOORD0;
			float3 viewDir : TEXCOORD2;
			half4 temp : TEXCOORD3;
			float2 uv : TEXCOORD4;

			half3 tspace0 : TEXCOORD5;
			half3 tspace1 : TEXCOORD6;
			half3 tspace2 : TEXCOORD7;
			#if ENABLE_FOG_EX
			UNITY_FOG_COORDS_EX(8)
			#else
			UNITY_FOG_COORDS(8)
			#endif
			float4 wpos: TEXCOORD9;
#ifdef __CREATE_DEPTH_MAP
			float4 projPos : TEXCOORD10;
			float3 ray : TEXCOORD11;
#endif
		};


		
		v2f vert(appdata v)
		{
			v2f o;
			half4 s;

			o.pos = UnityObjectToClipPos(v.vertex);

 
			float4 wpos = mul(unity_ObjectToWorld, v.vertex);




			o.temp.xyzw = wpos.xzxz * _WaveScale + _WaveSpeed * _WaveScale * _Time.y;
			o.bumpuv[0] = o.temp.xy * float2(.4, .45);
			o.bumpuv[1] = o.temp.wz;

			// object space view direction
			//o.viewDir.xzy = normalize(WorldSpaceViewDir(v.vertex));
			o.viewDir.xzy = normalize(WorldSpaceViewDir(v.vertex));
			o.uv = v.uv;


			half3 wNormal = UnityObjectToWorldNormal(v.normal);
			half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
			half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
			half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
			o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
			o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
			o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);

			o.wpos = wpos;
#ifdef __CREATE_DEPTH_MAP

			o.ray = wpos.xyz - _WorldSpaceCameraPos;
			o.projPos = ComputeScreenPos(o.pos);
			o.projPos.z = -mul(UNITY_MATRIX_V, wpos).z;
#endif

#ifdef __CREATE_DEPTH_MAP2
 
			float2 uv0 = v.uv;
#if defined(SHADER_API_D3D9)||defined(SHADER_API_D3D11)||defined(SHADER_API_D3D11_9X)
			uv0.y = 1.0 - uv0.y;
#endif

			o.pos.xy = uv0 * 2 - float2(1, 1);
			o.pos.z = 0.5;
			o.pos.w = 1;
			o.pos.y = o.pos.y;
			 
#endif
		
			#if ENABLE_FOG_EX
				UNITY_TRANSFER_FOG_EX(o, o.pos);
			#else
				UNITY_TRANSFER_FOG(o, o.pos);
			#endif




			return o;
		}
		ENDCG

		Subshader{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Cull Off
			
			Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }
			Pass{

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog

				sampler2D _BumpMap;
				sampler2D _ColorControl;

				sampler2D _developCamera;
				inline float2 ToRadialCoords(float3 coords)
				{
					float3 normalizedCoords = normalize(coords);
					float latitude = acos(normalizedCoords.y);
					float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
					float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
					return float2(0.5, 1.0) - sphereCoords;
				}
				float metallic_power;
				float3 metallic_color;

#ifdef __CREATE_DEPTH_MAP

				uniform float4x4 WorldToWaterCamera;
				sampler2D WaterDepthTex;
				float waterRangeScale;

				sampler2D _CameraDepthTexture;

#endif

				half _Alpha;
				half4 frag(v2f i) : COLOR
				{
	 
					half4 c0 =  tex2D(_ColorControl, i.uv);
					half inWater = c0.r*c0.a;

					//return float4(inWater, 0, 0,1);

#ifdef __CREATE_DEPTH_MAP


					float sceneDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
					float3 worldPosition = sceneDepth * i.ray / i.projPos.z + _WorldSpaceCameraPos;

					 

					float distance = length(i.wpos.xyz - worldPosition.xyz)/ waterToolctrlPower;
				
					return float4(distance, distance, distance,1);
 
#endif

					half4 col;
					col.a = saturate(inWater * waterAlpha)*_Alpha;
			 

				 
					inWater = saturate(inWater*waterPower);
					
					//return float4(inWater, 0, 0, 1);
					

			 

					half3 bump1 = UnpackNormal(tex2D(_BumpMap, i.bumpuv[0])).rgb;
					half3 bump2 = UnpackNormal(tex2D(_BumpMap, i.bumpuv[1])).rgb;
					half3 bump0 = (bump1 + bump2) * 0.5;

					bump0 = lerp(half3(0, 0, 1), bump0, _WaveNormalPower);


					half3 wNormal;
					wNormal.x = dot(i.tspace0, bump0);
					wNormal.y = dot(i.tspace1, bump0);
					wNormal.z = dot(i.tspace2, bump0);

					//平面的法线默认向上.
					//half3 planeNormal = half3(0,1,0);
					half ndotl = dot(i.viewDir, wNormal);
					 
 
					 
					//
			  

					
					half3 light_dir = _WorldSpaceLightPos0.xyz;

					half3 h = normalize(light_dir + i.viewDir);

					 

					float nh = max(0, dot(wNormal, h));

					

					float spec = pow(nh, _ShininessL*128.0) * _Gloss;



					half3 viewReflectDirection = reflect(-i.viewDir, wNormal);

					half2 skyUV = half2(ToRadialCoords(viewReflectDirection));
					fixed4 localskyColor = tex2D(_Sky, skyUV) ;
					localskyColor.rgb *= metallic_color;

					
					localskyColor.rgb *= exp2(localskyColor.w * 14.48538f - 3.621346f);

					metallic_power = metallic_power*inWater;


					//return float4(_LightColor0 * _WSpecColor.rgb * spec,1);
					 
					col.rgb = (_LightColor0 *(1.0 - metallic_power) + metallic_power*localskyColor.rgb)* lerp(_TopColor,_ButtonColor , inWater) + _LightColor0 * _WSpecColor.rgb * spec;

					//col.rgb = lerp(_TopColor, _ButtonColor, inWater);
					//return float4(_LightColor0 * _WSpecColor.rgb * spec,1);

					//col.rgb = _LightColor0* _ButtonColor + _LightColor0 * _WSpecColor.rgb * spec;



					
					//col.rgb  += spec;
 
					//APPLY_HEIGHT_FOG(col,i.wpos);
					#if ENABLE_FOG_EX
					APPLY_HEIGHT_FOG(col,i.wpos,i.normalWorld,i.fogCoord);
					UNITY_APPLY_FOG_MOBILE(i.fogCoord, col);
					#else
					UNITY_APPLY_FOG(i.fogCoord, col);
					#endif
	 
					return col;
				}
				ENDCG
			}
		}
		CustomEditor "WaterGUI"
			
}
