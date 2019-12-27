Shader "TA/Skybox/Skybox Sun Clound" {
	Properties{
		//[KeywordEnum(None, Simple, High Quality)] _SunDisk ("Sun", Int) = 2
		//_SunSize ("Sun Size", Range(0,1)) = 0.04

		//_AtmosphereThickness ("Atmoshpere Thickness", Range(0,5)) = 1.0
		//_SkyTint ("Sky Tint", Color) = (.5, .5, .5, 1)
		_SkyColorTop("_SkyColorTop", Color) = (0.00392156862745098, 0.13725490196078433, 0.49019607843137253, 1)
		_SkyColorButtom("_SkyColorButtom", Color) = (0.3254901960784314, 0.6, 0.9450980392156862, 1)


		_SkyCtrl("SkyCtrl",Range(0.1,1)) = 0.305
		_SkyButtomCtrl("_SkyButtomCtrl",Range(-1,0)) = 0

		//_Exposure("Exposure", Range(0, 8)) = 1.3
		[Toggle(_SUN)] _SUN("太阳", Float) = 1
		_SunColor("太阳色",Color) = (0.8,0.8,0.8,1)
		_SunDir("太阳方向",Vector) = (0.0,0.3,0.0,1.0)
		_Radius("太阳半径",Range(0.001,0.5)) = 0.2
		_SunPower("太阳强度",Range(0,2)) = 1

		[Toggle(_SUN_RAY)] _SUN_RAY("太阳辉光", Float) = 1
		_RadiusRay("太阳辉光半径",Range(0.3,1)) = 0.5
		_SunRayColor("太阳色辉光色",Color) = (0.8,0.8,0.8,1)
		_SunRayPower("太阳阳辉强度",Range(0,0.5)) = 0.5


		[Toggle(_CLOUND)] _CLOUND("云", Float) = 1

		_ClondColor("云层色",Color) = (1,1,1,1)

		_CloundTex("Texture", 2D) = "white" {}
		_CloundSpeed("云层速度",Range(0,1)) = 0.01

		[Toggle(_BUTTOM)] _BUTTOM("底部压暗", Float) = 1
		_ButtomBrightness("底部亮度调节",Range(0.01,1.2)) = 0.01
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

				#pragma shader_feature _MODE
				#pragma shader_feature _SUN
				#pragma shader_feature _SUN_RAY

				#pragma shader_feature _BUTTOM
				#pragma shader_feature _CLOUND
				#include "UnityCG.cginc"



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

					//float speed : TEXCOORD3;
				};


				float4 _SkyColorTop;
				float4 _SkyColorButtom;
				float _SkyCtrl;
				float _SkyButtomCtrl;
				float4 _SunColor;
				float4 _SunDir;
				float _Radius;
				float _SunPower;

				float _RadiusRay;
				float4 _SunRayColor;
				float _SunRayPower;
				sampler2D _CloundTex;
				float4 _CloundTex_ST;
				float4 _ClondColor;
				float _CloundSpeed;
				float _ButtomBrightness;
				//samplerCUBE _Tex;

				inline float2 ToRadialCoords(float3 coords)
				{
					float3 normalizedCoords = normalize(coords);
					float latitude = acos(normalizedCoords.y);
					float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
					float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
					return float2(0.5, 1.0) - sphereCoords;
				}

				v2f vert(appdata v)
				{
					v2f o;


					o.posWorld = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
					o.vertex = mul(UNITY_MATRIX_VP, o.posWorld);
		#if _MODE
					o.pos = v.vertex;


		#endif


		#if _MODE
					float3 viewDirection = normalize(o.pos.xyz);
					o.uv = v.uv;

		#else
					float3 viewDirection = normalize(o.posWorld.xyz - _WorldSpaceCameraPos.xyz);


		#endif

					//o.speed = _Time.x*_CloundSpeed;

					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
		#if _MODE
					float3 viewDirection = normalize(i.pos.xyz);

		#else
					float3 viewDirection0 = i.posWorld.xyz - _WorldSpaceCameraPos.xyz;
					float3 viewDirection = normalize(viewDirection0);


					//i.uv.y = (viewDirection.y + 1)*0.5;

					i.uv.y = saturate(viewDirection.y);





					float longitude = atan2(viewDirection.z, viewDirection.x);
					i.uv.x = 0.5 - longitude * 0.5 / UNITY_PI;
		#endif
					float3 sunDir = normalize(_SunDir.xyz);


					float t = viewDirection.y;
					t = saturate((t - _SkyButtomCtrl) / (1 - _SkyButtomCtrl));
					t = pow(t, _SkyCtrl);
					t = saturate(t);
		#if UNITY_COLORSPACE_GAMMA
					_SkyColorTop.rgb = GammaToLinearSpace(_SkyColorTop.rgb);
					_SkyColorButtom.rgb = GammaToLinearSpace(_SkyColorButtom.rgb);
					_SunColor.rgb = GammaToLinearSpace(_SunColor.rgb);
		#endif


					float4 cout = lerp(_SkyColorButtom,_SkyColorTop, t);
		#if UNITY_COLORSPACE_GAMMA
					cout.rgb = LinearToGammaSpace(cout.rgb);
		#endif

		#if _SUN
					float _a0 = saturate(dot(sunDir, viewDirection));

					float _s1 = smoothstep((1 - _Radius), 1, _a0);

					cout.rgb += _SunColor.rgb*_s1*_SunPower;


		#if _SUN_RAY
					float _s2 = smoothstep((1 - _RadiusRay), 1, _a0);

					cout.rgb += _SunRayColor.rgb*_s2*_SunRayPower;
					cout.rgb = saturate(cout.rgb);
		#endif




		#endif
		#if _CLOUND
					_CloundTex_ST.z += _Time.x*_CloundSpeed;
					//fixed4 col = tex2Dlod(_CloundTex, float4(i.uv.xy*_CloundTex_ST.xy + _CloundTex_ST.zw, 0, 0));
					fixed4 col = tex2D(_CloundTex,  i.uv.xy*_CloundTex_ST.xy + _CloundTex_ST.zw);

					cout.rgb = lerp(cout.rgb, _ClondColor, col.a);


		#endif


#if _BUTTOM
					float _d = viewDirection.y*_ButtomBrightness + 1;
					float _t0 = lerp(0.5,1 , saturate(_d));
					//float _t0 = saturate((_d + 1) / _ButtomBrightness);
					//_t0 = _t0 * _t0*(1.5 - (_t0))+0.5;
					cout.rgb = cout.rgb*_t0;
#endif

					//
					return cout;

				}
				ENDCG
			}
		}


			Fallback Off

}
