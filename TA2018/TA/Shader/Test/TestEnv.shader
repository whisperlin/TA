Shader "TA/Helper/TestEnv"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[Toggle(MyToggle2)] _MyToggle2("测试env", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#pragma shader_feature MyToggle2
			#include "UnityCG.cginc"
			#include "SHGlobal.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float3 normalWorld : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

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
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normalWorld = UnityObjectToWorldNormal(v.normal);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
			#if MyToggle2
	 
				fixed4 col = float4(g_sh(half4(i.normalWorld, 1)),1);
			#else
				half2 skyUV = ToRadialCoords(i.normalWorld);
				fixed4 col = tex2D(_MainTex, skyUV);
			#endif

				
				 
				return col;
			}
			ENDCG
		}
	}
}
