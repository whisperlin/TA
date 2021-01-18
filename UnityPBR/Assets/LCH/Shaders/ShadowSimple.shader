Shader "Unlit/ShadowSimple"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque"  }
		LOD 100

		Pass
		{
			Tags { "LightMode"="ForwardBase"} //第一步//
 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			//#pragma multi_compile_fog
			//#pragma multi_compile_fwdbase//第二步//

			#pragma multi_compile _ SHADOWS_SCREEN
			#define FORWARD_BASE_PASS
	 
			#include "UnityCG.cginc"
			 #include "AutoLight.cginc" //第三步// 
 
 

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;


			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				LIGHTING_COORDS(3, 4) //第四步// 
				UNITY_FOG_COORDS(2)
				float4 pos : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				TRANSFER_VERTEX_TO_FRAGMENT(o); //第5步// 
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
 
				float4 diffuseTerm = col * LIGHT_ATTENUATION(i); //第6步//
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col *diffuseTerm;
			}
			ENDCG
		}

		UsePass "Mobile/VertexLit/ShadowCaster"
	}
}
