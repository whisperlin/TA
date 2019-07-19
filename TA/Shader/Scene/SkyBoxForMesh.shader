// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "TA/Scene/SkyBoxForMesh"
{
	Properties
	{
		[NoScaleOffset] _Tex ("Cubemap    ", Cube) = "grey" {}

		_Rotation ("Rotation", Range(0, 360)) = 0
		
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry-1"  }
		//"ForceNoShadowCasting"="True"
		LOD 100

		Pass
		{
			Cull Off
			ZWrite Off
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

			samplerCUBE _Tex;

			 
			half _Rotation;
			 

			float3 RotateAroundYInDegrees (float3 vertex, float degrees)
			{
				float alpha = degrees * UNITY_PI / 180.0;
				float sina, cosa;
				sincos(alpha, sina, cosa);
				float2x2 m = float2x2(cosa, -sina, sina, cosa);
				return float3(mul(m, vertex.xz), vertex.y).xzy;
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

 

				float3 rotated = RotateAroundYInDegrees(v.vertex, _Rotation) ;
				
				rotated += mul(unity_ObjectToWorld,float4(0,0,0,1));
 
				o.vertex =  mul(UNITY_MATRIX_VP, float4(rotated, 1.0));
				
				o.texcoord = v.vertex.xyz;
				o.texcoord.xz = -o.texcoord.xz;
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
 
				half4 tex = texCUBElod (_Tex, float4(i.texcoord,0));
 
				 
				 

				#if DEVELOP_SKY_BOX
				_SunDirect.xz = -_SunDirect.xz;
				float d = dot(_SunDirect,i.texcoord);
				//return float4(1,0,0,1);
				if(d>_SunDirect.a)
				{
					col.rgb = col.rgb*0.5 + float3(d,0,0)*0.5;
				}
		 
				#endif
	 
 
				return tex;
			}
			ENDCG
		}
	}
}
