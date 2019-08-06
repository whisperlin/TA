Shader "TA/Scene/SkyBox"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		//_Rotation ("Rotation", Range(0, 360)) = 0
		_SunPower("Sun Power",Range(1,14)) = 1
		_SunBright("_SunBright",Range(-0.25,0.25)) = 0

		[Toggle(OPEN_SUN)] _OPEN_SUN("开启太阳", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque+800" }
		LOD 100

		Pass
		{
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#pragma multi_compile __ DEVELOP_SKY_BOX
			#pragma shader_feature OPEN_SUN
			#if DEVELOP_SKY_BOX

			float4 _SunDirect;
			#endif

			struct appdata
			{
				float4 vertex : POSITION;
				//float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float3 texcoord : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};
			half _SunPower;
			//half _Rotation;
			half _SunBright;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			float3 RotateAroundYInDegrees (float3 vertex, float degrees)
			{
				float alpha = degrees * UNITY_PI / 180.0;
				float sina, cosa;
				sincos(alpha, sina, cosa);
				float2x2 m = float2x2(cosa, -sina, sina, cosa);
				return float3(mul(m, vertex.xz), vertex.y).xzy;
			}
			
			//这个是网易的。
			inline half2 ToRadialCoordsNetEase(half3 envRefDir)
			{
 
				half k = envRefDir.x / (length(envRefDir.xz) + 1E-06f);
				half2 normalY = { k, envRefDir.y };
				half2 latitude = acos(normalY) * 0.3183099f;
				half s = step(envRefDir.z, 0.0f);
				half u = s - ((s * 2.0f - 1.0f) * (latitude.x * 0.5f));
				return half2(u, latitude.y);
			}
			//这个是unity。
			inline float2 ToRadialCoords(float3 coords)
			{
				float3 normalizedCoords = normalize(coords);
				float latitude = acos(normalizedCoords.y);
				float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
				float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
				return float2(0.5, 1.0) - sphereCoords;
			}
			v2f vert (appdata v)
			{
				v2f o;
				//float3 rotated = RotateAroundYInDegrees(v.vertex, _Rotation);
				float3 rotated = v.vertex;
				//o.vertex =  mul(UNITY_MATRIX_P, mul(unity_ObjectToWorld, float4(rotated, 1.0)));
				o.vertex = UnityObjectToClipPos(rotated);
				//o.vertex = UnityObjectToClipPos(rotated);
				o.texcoord = v.vertex.xyz;
				o.texcoord.xz = -o.texcoord.xz;
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half2 skyUV = ToRadialCoords(i.texcoord);
				//skyUV.y = 1 - skyUV.y;
				// sample the texture
				fixed4 col = tex2D(_MainTex, skyUV);
				
	 
				#if OPEN_SUN
				half p = (col.w + _SunBright) *_SunPower;
				col *= max(0,exp2(p));
				#endif


				#if DEVELOP_SKY_BOX
				_SunDirect.xz = -_SunDirect.xz;
				float d = dot(_SunDirect,i.texcoord);
				//return float4(1,0,0,1);
				if(d>_SunDirect.a)
				{
					col.rgb = col.rgb*0.5 + float3(d,0,0)*0.5;
				}
		 
				#endif
	 
 
				return col;
			}
			ENDCG
		}
	}
}
