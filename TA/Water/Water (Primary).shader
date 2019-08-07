Shader "TA/Water (Primary)" {
	Properties{
		[NoScaleOffset] _ColorControl("深度控制图", 2D) = "white" { }
		[NoScaleOffset] _BumpMap("NormalTexture", 2D) = "" { }
		__BumpMapPower("法线强度",Range(0,1)) = 1
		_TopColor("浅水色", Color) = (0.619, 0.759, 1, 1)
		_ButtonColor("深水色", COLOR) = (.172 , .463 , .435 , 0)
		_WaveScale("水波浪缩放", Range(0.02,0.15)) = .07
		_WaveSpeed("水波浪速度", Vector) = (19,9,-16,-7)

		_ShininessL("水光照调节", Range(0.03, 1)) = 0.03
		_WSpecColor("水高光颜色",Color) = (1,1,1,1)
		_Gloss("水高光亮度", Range(0,1)) = 0.5


		_Sky("天空", 2D) = "white" {}

		metallic_power("天空强度", Range(0,1)) = 1
		metallic_color("天空颜色", Color) = (1, 1, 1, 0)

		waterPower("深水区域深度",Range(0.1,10)) = 10
		waterAlpha("Alpha区域深度",Range(0.1,10)) = 10
		_Alpha("透明度",Range(0,1)) = 0.8

		_lodLevel("lod等级",Range(0,8)) = 0
		 //_Cube("CubeMap", CUBE) = ""{}

		[Toggle(OPEN_SUN)] _OPEN_SUN("开启太阳", Float) = 0
		_SunPower("Sun Power",Range(1,14)) = 1
		_SunBright("_SunBright",Range(-0.25,0.25)) = 0
		[Space]
			//[HideInInspector]
		[HideInInspector]cubemapCenter("cubemapCenter",Vector) = (1, 1, 1, 1)
		[HideInInspector]boxMin("boxMin",Vector) = (1, 1, 1, 1)
		[HideInInspector]boxMax("boxMax",Vector) = (1, 1, 1, 1)


			//[NoScaleOffset] _developCamera("调试相机", 2D) = "white" { }

	}

		CGINCLUDE


#pragma multi_compile __  __CREATE_DEPTH_MAP 
#pragma multi_compile __  __CREATE_DEPTH_MAP2 
#pragma multi_compile __  BOX_PROJECT_SKY_BOX

#pragma   multi_compile  _  ENABLE_NEW_FOG
#pragma   multi_compile  _  _POW_FOG_ON
#pragma   multi_compile  _  _HEIGHT_FOG_ON
#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
#pragma   multi_compile  _ ENABLE_BACK_LIGHT
#pragma   multi_compile  _  GLOBAL_ENV_SH9

#pragma shader_feature OPEN_SUN
#include "UnityCG.cginc"
#include "../Shader/LCHCommon.cginc"
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

		uniform half _lodLevel;

		half _SunPower;
		half _SunBright;


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

			NORMAL_TANGENT_BITANGENT_COORDS(5, 6, 7)

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
			o.viewDir = normalize(WorldSpaceViewDir(v.vertex));

 
			 

			o.uv = v.uv;

			NTBYAttribute ntb = GetWorldNormalTangentBitangent(v.normal, v.tangent);
			o.normal = ntb.normal;
			o.tangent = ntb.tangent;
			o.bitangent = ntb.bitangent;


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
			 
			UNITY_TRANSFER_FOG_EX(o, o.pos, o.wpos, o.normal);
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



				#include "boxproject.cginc"
				#include "../Shader/LCHCommon.cginc"
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
				//samplerCUBE _Cube;
				half __BumpMapPower;
				half4 frag(v2f i) : COLOR
				{

					half4 c0 = tex2D(_ColorControl, i.uv);
					half inWater = c0.r*c0.a;
					half3 worldView = UnityWorldSpaceViewDir(i.wpos);
					//return float4(inWater, 0, 0,1);

#ifdef __CREATE_DEPTH_MAP


					float sceneDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
					float3 worldPosition = sceneDepth * i.ray / i.projPos.z + _WorldSpaceCameraPos;



					float distance = length(i.wpos.xyz - worldPosition.xyz) / waterToolctrlPower;

					return float4(distance, distance, distance,1);

#endif

					half4 col;
					col.a = saturate(inWater * waterAlpha)*_Alpha;



					inWater = saturate(inWater*waterPower);

					//return float4(inWater, 0, 0, 1);




					half3 bump1 = UnpackNormal(tex2Dlod(_BumpMap, float4(i.bumpuv[0],0,_lodLevel))).rgb;
					half3 bump2 = UnpackNormal(tex2Dlod(_BumpMap, float4(i.bumpuv[1],0,_lodLevel))).rgb;
					half3 bump0 = (bump1 + bump2) * 0.5;

					bump0 = lerp(half3(0, 0, 1), bump0, __BumpMapPower);
					//half3 _normal_val = UnpackNormalRG(e);
					float3x3 tangentTransform = GetNormalTranform(i.normal, i.tangent, i.bitangent);
					half3 wNormal = normalize(mul(bump0, tangentTransform));
 
					//平面的法线默认向上.
					//half3 planeNormal = half3(0,1,0);
					half ndotl = dot(worldView, wNormal);

				

					//



					half3 light_dir = _WorldSpaceLightPos0.xyz;

					half3 h = normalize(light_dir + worldView);



					float nh = max(0, dot(wNormal, h));



					float spec = pow(nh, _ShininessL*128.0) * _Gloss;



					half3 viewReflectDirection = reflect(-worldView, wNormal);


#if BOX_PROJECT_SKY_BOX
					viewReflectDirection = BoxProjectedCubemapDirection(viewReflectDirection, i.wpos, cubemapCenter, boxMin, boxMax);
#endif
					half2 skyUV = half2(ToRadialCoords(viewReflectDirection));

					//fixed4 localskyColor = texCUBE(_Cube, normalize(viewReflectDirection.xyz));
					fixed4 localskyColor = tex2D(_Sky, skyUV) ;

					 
					localskyColor.rgb *= metallic_color;



#if OPEN_SUN
					half p = (col.w + _SunBright) *_SunPower;
					localskyColor.rgb *= max(0, exp2(p));
#endif


					metallic_power = metallic_power * inWater;
 ;

					col.rgb = (_LightColor0 *(1.0 - metallic_power) + metallic_power * localskyColor.rgb)* lerp(_TopColor,_ButtonColor , inWater) + _LightColor0 * _WSpecColor.rgb * spec;


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
