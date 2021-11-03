Shader "Unlit/WaterRenderShader"
{
    Properties
    {
        _Color ("Color", color) = (1,1,1,1)
		_MainTex("MainTex", 2D) = "white" {}
		//_SkyboxTex("SkyboxTex", Cube) = "_Skybox" {}
		_WaveScale("WaveScale", Range(0,1)) = 0.47

		[Toggle(HEIGHT_MAP)] HEIGHT_MAP("算顶点", Int) = 0

		[Toggle(NORMAL_OFFSET)] NORMAL_OFFSET("算法线", Int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM

			 #pragma multi_compile  _ HEIGHT_MAP  

			  #pragma multi_compile  _ NORMAL_OFFSET
			//#define NORMAL_OFFSET 1
			//#define HEIGHT_MAP 1
			 
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "WaveUtils.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				

				#if NORMAL_OFFSET
					float3 worldPos : TEXCOORD2;
				#else
					float3 worldSpaceReflect : TEXCOORD1;
				#endif
            };

            sampler2D _MainTex;
			sampler2D _WaveResult;
			float4 _WaveResult_ST;
			float4 _Color;
			float _WaveScale;
 
            v2f vert (appdata v)
            {
                v2f o;

				float4 localPos = v.vertex;
				float4 waveTransmit = tex2Dlod(_WaveResult, float4(v.uv, 0, 0));

				#if HEIGHT_MAP
				float waveHeight = DecodeHeightRG(waveTransmit);

				localPos.y += waveHeight * _WaveScale;

				#endif

				float3 worldPos = mul(unity_ObjectToWorld, localPos);

				#if NORMAL_OFFSET
					o.worldPos = worldPos;
				#else
					float3 worldSpaceNormal = mul(unity_ObjectToWorld, v.normal);
					float3 worldSpaceViewDir = UnityWorldSpaceViewDir(worldPos);
					o.worldSpaceReflect = reflect(-worldSpaceViewDir, worldSpaceNormal);
				#endif

				o.vertex = mul(UNITY_MATRIX_VP, float4(worldPos, 1));
				o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

				#if NORMAL_OFFSET
					float waveHeight0 = DecodeHeightRG(   tex2Dlod(_WaveResult, float4(i.uv, 0, 0))   )  ;
					float waveHeight1 = DecodeHeightRG(   tex2Dlod(_WaveResult, float4(i.uv + half2( _WaveResult_ST.x,                             0)  , 0, 0))   )  ;
					float waveHeight2 = DecodeHeightRG(   tex2Dlod(_WaveResult, float4(i.uv + half2(                             0, _WaveResult_ST.y) , 0, 0))    )  ;
					float3 worldSpaceNormal =  normalize( half3(  waveHeight1 - waveHeight0 ,4  ,waveHeight2 - waveHeight0) );

					worldSpaceNormal =mul((float3x3)unity_ObjectToWorld,  worldSpaceNormal);
					//float3 worldSpaceNormal = mul( (float3x3)unity_ObjectToWorld,    normalize( half3(  waveHeight1 - waveHeight0   ,waveHeight2 - waveHeight0 , 4) ));
					//float3 worldSpaceNormal =mul((float3x3)unity_ObjectToWorld,  half3(0,1,0));
					// worldSpaceNormal = normalize ( worldSpaceNormal);
					float3 worldSpaceViewDir = UnityWorldSpaceViewDir(i.worldPos);
					float3 worldSpaceReflect = reflect(-worldSpaceViewDir, worldSpaceNormal);

					half4 skyboxCol = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldSpaceReflect);
	 
					return skyboxCol;
				 
				 #else
					float4 waveTransmit = tex2Dlod(_WaveResult, float4(i.uv, 0, 0));
					float waveHeight = DecodeHeightRG(waveTransmit) * _WaveScale;
					float3 reflect = normalize(i.worldSpaceReflect);
					half4 skyboxCol = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflect);
					skyboxCol = half4( DecodeHDR (skyboxCol, unity_SpecCube0_HDR),1 );
					skyboxCol = lerp(skyboxCol, _Color, waveHeight);
				
				#endif
                return skyboxCol;
            }
            ENDCG
        }
    }
}
