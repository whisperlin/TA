Shader "TA/Water (SimpleWave)" {
	Properties{
		[NoScaleOffset] _ColorControl("深度控制图", 2D) = "white" { }

		_TopColor("浅水色", Color) =(0.402343, 0.77343, 0.77343, 0.3)//103.198.198
		_ButtonColor("深水色", COLOR) =  (0.23828125, 0.53515625, 0.7297, 0.5)//61,137,189
		_EdgeColor("水边色", Color) = (1, 1, 1, 1)


		_SpecularTex("扰动纹理", 2D) = "white" {}
		_SpecularTexR_ST ("_SpecularTexR_ST", vector) = (20,20,1,1)
		_SpecularTexG_ST ("_SpecularTexG_ST", vector) = (20,20,0.5,-0.3)
		_SpecularTexB_ST ("_SpecularTexB_ST", vector) = (20,20,-0.7,-0.4)
		_SpecularPower("假高光强度",Range(0,100)) = 10
		_SpecularColor("高光色", Color) = (1,1,1,1)

 
		waterPower("深水区域深度",Range(0.1,10)) = 10
 
		_Alpha("透明度",Range(0,1)) = 0.8

		_DownFactor("退潮渐变",Range(0.1,0.5)) = 0.2
 
		 
		_WareTex ("波浪", 2D) = "white" {}
		_WareTex_ST ("_WareTex_ST", vector) = (0.1,20.0,0,0.2)



		_GSpeed ("海面速度", vector) = (1,1,0,0)
		_GFrequency("波浪大小",Range(0,100)) = 10
		_GHeight("波浪高度",Range(0,1)) = 0.25

		[KeywordEnum(off, on, no )] _SIMPLE_WAVE("简单浪", Float) = 0
		[KeywordEnum(on, off )] _ANIMATION("顶点起伏开关", Float) = 0
	}

		CGINCLUDE
		#define ENABLE_FOG_EX  1

		#pragma multi_compile __  __CREATE_DEPTH_MAP 
		#pragma multi_compile __  __CREATE_DEPTH_MAP2 
		#include "UnityCG.cginc"

		#if ENABLE_FOG_EX
		#include "../Shader/height-fog.cginc"
		#endif

		#include "UnityLightingCommon.cginc" // for _LightColor0
		#pragma multi_compile _SIMPLE_WAVE_OFF _SIMPLE_WAVE_ON _SIMPLE_WAVE_NO


		#pragma multi_compile _ANIMATION_ON _ANIMATION_OFF 

		uniform half4 _ButtonColor;
		uniform half4 _TopColor;
		float4 _EdgeColor;
 #if _ANIMATION_ON
		float _DownFactor;
 #endif
		uniform half waterPower;
		uniform half waterToolctrlPower;
 


		sampler2D _SpecularTex;
		uniform float _SpecularExp;
		uniform float _SpecularPower;
		uniform half4 _SpecularColor;
		uniform half4 _SpecularTexR_ST;
		uniform half4 _SpecularTexG_ST;
		uniform half4 _SpecularTexB_ST;

		sampler2D _WareTex;
		half4 _WareTex_ST;


		uniform half _GFrequency;
		uniform half4 _GSpeed;
		uniform half _GHeight;

 
		struct appdata {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 tangent : TANGENT;
			float2 uv : TEXCOORD0;
		};

		struct v2f {
			float4 pos : SV_POSITION;
 
 
 
			float2 uv : TEXCOORD4;
			float wareOffset : TEXCOORD5;
			#if _ANIMATION_ON 
			float fade : TEXCOORD6;
			#endif

			#if ENABLE_FOG_EX
			UNITY_FOG_COORDS_EX(7)
			#else
			UNITY_FOG_COORDS(7)
			#endif
			float4 wpos: TEXCOORD8;
#ifdef __CREATE_DEPTH_MAP
			float4 projPos : TEXCOORD9;
			float3 ray : TEXCOORD10;
#endif
			float3 normalWorld : TEXCOORD11;
		};


		
		v2f vert(appdata v)
		{
			v2f o;
			half4 s;

			o.normalWorld = UnityObjectToWorldNormal(v.normal);
			float4 wpos = mul(unity_ObjectToWorld, v.vertex);

			

 
			



 
			o.uv = v.uv;

 
#ifdef __CREATE_DEPTH_MAP
			o.pos = UnityObjectToClipPos(v.vertex);
			
			o.ray = wpos.xyz - _WorldSpaceCameraPos;
			o.projPos = ComputeScreenPos(o.pos);
			o.projPos.z = -mul(UNITY_MATRIX_V, wpos).z;
#else
			


			#if _ANIMATION_ON 
			float2 _p = _GFrequency * wpos.xz + _Time.yy * _GSpeed.xy;	
			float _s = sin(_p.x+_p.y);
			o.fade =  (  _s + 1 )*0.5 ;
			wpos.y -= o.fade   *_GHeight;

			#endif
			o.pos = mul(UNITY_MATRIX_VP,wpos);
			
#endif

			o.wpos = wpos;
			
			//


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
			o.wareOffset = (wpos.x+wpos.y)*_WareTex_ST.x*0.1 +_Time.y*_WareTex_ST.w;


			#if ENABLE_FOG_EX
				UNITY_TRANSFER_FOG_EX(o, o.vertex, o.wpos,o.normalWorld);
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
					half4 c0 =  tex2Dlod(_ColorControl, float4(i.uv,0,3));
	 
					half inWater = c0.r ;
 
					half2 uv0 =    i.uv * _SpecularTexR_ST.xy  +   _Time.x *    _SpecularTexR_ST.zw;
					half colr = tex2D(_SpecularTex,uv0).r;

					half2 uv1 =    i.uv  * _SpecularTexG_ST.xy  +   _Time.x *    _SpecularTexG_ST.zw;
					half colg = tex2D(_SpecularTex,uv1).g;

					half2 uv2 =    i.uv  * _SpecularTexB_ST.xy  +   _Time.x *    _SpecularTexB_ST.zw;
					half colb = tex2D(_SpecularTex,uv2).b;
					half sp =  colr * colg * colb ;
 

#ifdef __CREATE_DEPTH_MAP


					float sceneDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
					float3 worldPosition = sceneDepth * i.ray / i.projPos.z + _WorldSpaceCameraPos;

					 

					float distance = length(i.wpos.xyz - worldPosition.xyz)/ waterToolctrlPower;
				
					return float4(distance, distance, distance,1);
 
#endif

					half4 waterColor;
					//waterColor.a = saturate(inWater * _ButtonColor.a)*_Alpha;
			 


					


					//o.fade
					#if _ANIMATION_ON 
					inWater = saturate(inWater*waterPower - i.fade*_DownFactor);
					
					#else
					inWater = saturate(inWater*waterPower  );
					#endif
					
 


					float w = inWater*_WareTex_ST.y;

				
					#if _SIMPLE_WAVE_NO

						float t0 = 0;
					#else
						#if _SIMPLE_WAVE_ON
						float t0 =   step(w,0.3);
						#else
						float t2 = w * step(w,1);
						float t0 = tex2D(_WareTex,float2(i.wareOffset,t2)).r;
						#endif

					#endif

					

					waterColor =    lerp (lerp(_TopColor,_ButtonColor , inWater) ,_EdgeColor ,t0 );


					fixed4 col = lerp(waterColor,_SpecularColor*_SpecularPower,sp  );
			
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
