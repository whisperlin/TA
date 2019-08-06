Shader "Hidden/CubemapToEquirectangular" {
	Properties{
		_MainTex("Cubemap (RGB)", CUBE) = "" {}
	}

		Subshader{
		Pass{
		ZTest Always Cull Off ZWrite Off
		Fog{ Mode off }

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma fragmentoption ARB_precision_hint_fastest
				//#pragma fragmentoption ARB_precision_hint_nicest
		#include "UnityCG.cginc"

		#define PI    3.141592653589793
		#define TWOPI 6.283185307179587

		struct v2f {
		float4 pos : POSITION;
		float2 uv : TEXCOORD0;
	};

	samplerCUBE _MainTex;

	v2f vert(appdata_img v)
	{
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.uv = v.texcoord.xy * float2(TWOPI, PI);
		return o;
	}
	float3 RotateAroundYInDegrees(float3 vertex, float degrees)
	{
		float alpha = degrees * UNITY_PI / 180.0;
		float sina, cosa;
		sincos(alpha, sina, cosa);
		float2x2 m = float2x2(cosa, -sina, sina, cosa);
		return float3(mul(m, vertex.xz), vertex.y).xzy;
	}
	fixed4 frag(v2f i) : COLOR
	{
		float theta = i.uv.y;
		float phi = i.uv.x;
		float3 unit = float3(0,0,0);

		unit.x = sin(phi) * sin(theta) * -1;
		unit.y = cos(theta) * -1;
		unit.z = cos(phi) * sin(theta) * -1;
		unit = RotateAroundYInDegrees(unit,-90);
		return texCUBE(_MainTex, unit);
	}
		ENDCG
	}
	}
		Fallback Off
}