Shader "TA/Hidden/SunLensFlare"
 {
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_AlphaTex ("_Alpha", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Transparent+2000" }
		LOD 100

		Pass
		{
			Blend One One
			Cull Off
			ZTest Always
			ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 color : TEXCOORD1;
				//UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _AlphaTex;
			float4 _MainTex_ST;
			float4 _testoffset;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//.vertex.z = -10;

			


				//float2 pos = float2(unity_ObjectToWorld[0].a,-unity_ObjectToWorld[1].a);
				o.vertex = v.vertex;
				//o.vertex.xy *= unity_ObjectToWorld[0].xx;
				o.color = v.color;
				//o.vertex.x *= _ScreenParams.y/_ScreenParams.x;
				//o.vertex.xy += pos.xy;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//return _testoffset;
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 col2 = tex2D(_AlphaTex, i.uv); 
				col.rgb*=i.color.rgb  ;
				col.rgb *= col2.r;
				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}