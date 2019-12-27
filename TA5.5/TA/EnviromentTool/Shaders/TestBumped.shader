// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "TA/Helper/TestBumped" 
{
		Properties{
			// normal map texture on the material,
			// default to dummy "flat surface" normalmap
			_BumpMap("Normal Map", 2D) = "bump" {}

			[Toggle(S_BOOL)] _S_BOOL("S_BOOL", Int) = 0
		}
		SubShader
		{
		Pass
		{
			CGPROGRAM

			#pragma shader_feature S_BOOL
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f {
				float3 worldPos : TEXCOORD0;
				// these three vectors will hold a 3x3 rotation matrix
				// that transforms from tangent to world space
				half3 tspace0 : TEXCOORD1; // tangent.x, bitangent.x, normal.x
				half3 tspace1 : TEXCOORD2; // tangent.y, bitangent.y, normal.y
				half3 tspace2 : TEXCOORD3; // tangent.z, bitangent.z, normal.z
										   // texture coordinate for the normal map
				float2 uv : TEXCOORD4;
				float4 pos : SV_POSITION;
			};

			// vertex shader now also needs a per-vertex tangent vector.
			// in Unity tangents are 4D vectors, with the .w component used to
			// indicate direction of the bitangent vector.
			// we also need the texture coordinate.
			v2f vert(float4 vertex : POSITION, float3 normal : NORMAL, float4 tangent : TANGENT, float2 uv : TEXCOORD0)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(vertex);
				o.worldPos = mul(unity_ObjectToWorld, vertex).xyz;
				half3 wNormal = UnityObjectToWorldNormal(normal);
				half3 wTangent = UnityObjectToWorldDir(tangent.xyz);
				// compute bitangent from cross product of normal and tangent
				half tangentSign = tangent.w * unity_WorldTransformParams.w;
				half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
				// output the tangent space matrix
				o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
				o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
				o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
				o.uv = uv;
				return o;
			}

			// normal map texture from shader properties
			sampler2D _BumpMap;

			inline half3 UnpackNormalGA(half4 packednormal)
			{
				half3 normal  ;
				normal.xy = packednormal.wy * 2 - 1;
				normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
				return normal;
			}

			 
			inline fixed3 UnpackNormalUnity(fixed4 packednormal)
			{
				fixed3 normal;
				normal.xy = packednormal.wy * 2 - 1;
				normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
				return normal;
			}

			fixed4 frag(v2f i) : SV_Target
			{

#if S_BOOL
				// sample the normal map, and decode from the Unity encoding
				half3 tnormal = UnpackNormal(tex2D(_BumpMap, i.uv));
#else
				// sample the normal map, and decode from the Unity encoding
				half3 tnormal = UnpackNormalGA(tex2D(_BumpMap, i.uv));

#endif
				
				// transform normal from tangent to world space
				half3 worldNormal;
				worldNormal.x = dot(i.tspace0, tnormal);
				worldNormal.y = dot(i.tspace1, tnormal);
				worldNormal.z = dot(i.tspace2, tnormal);


				fixed4 c = 0;
				// normal is a 3D vector with xyz components; in -1..1
				// range. To display it as color, bring the range into 0..1
				// and put into red, green, blue components
				c.rgb = worldNormal*0.5 + 0.5;
				return c;

			 
			}
			ENDCG
	}
}
}