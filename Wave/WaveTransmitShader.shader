Shader "Unlit/WaveTransmitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM

			
			#pragma multi_compile  _ HIT
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "WaveUtils.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
			//sampler2D _PrevWaveMarkTex;
			float4 _WaveTransmitParams;
			float _WaveAtten;
			#if HIT
			float4 _WaveMarkParams;
			#endif
			static const float2 WAVE_DIR[4] = { float2(1, 0), float2(0, 1), float2(-1, 0), float2(0, -1) };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
                return o;
            }
			
            fixed4 frag (v2f i) : SV_Target
            {
				/*波传递公式
				 (4 - 8 * c^2 * t^2 / d^2) / (u * t + 2) + (u * t - 2) / (u * t + 2) * z(x,y,z, t - dt) + (2 * c^2 * t^2 / d ^2) / (u * t + 2)
				 * (z(x + dx,y,t) + z(x - dx, y, t) + z(x,y + dy, t) + z(x, y - dy, t);*/

				float dx = _WaveTransmitParams.w;

				float avgWaveHeight = 0;
				for (int s = 0; s < 4; s++)
				{
					avgWaveHeight += DecodeHeightRG(tex2D(_MainTex, i.uv + WAVE_DIR[s] * dx).xy);
				}

				//(2 * c^2 * t^2 / d ^2) / (u * t + 2)*(z(x + dx, y, t) + z(x - dx, y, t) + z(x, y + dy, t) + z(x, y - dy, t);
				float agWave = _WaveTransmitParams.z * avgWaveHeight;
				
				float4 val = tex2D(_MainTex, i.uv);
				// (4 - 8 * c^2 * t^2 / d^2) / (u * t + 2)
				float curWave = _WaveTransmitParams.x *  DecodeHeightRG(val.xy);
				// (u * t - 2) / (u * t + 2) * z(x,y,z, t - dt) 上一次波浪值 t - dt
				float prevWave = _WaveTransmitParams.y * DecodeHeightRG(val.ba);

				#if HIT
					float dx0 = i.uv.x - _WaveMarkParams.x;
					float dy0 = i.uv.y - _WaveMarkParams.y;
					float disSqr = dx0 * dx0 + dy0 * dy0;
					int hasCol = step(0, _WaveMarkParams.z - disSqr);
	 
					if (hasCol == 1) {
						prevWave = -_WaveMarkParams.w;
					}
				#endif
				//波衰减
				float waveValue = (curWave + prevWave + agWave) * _WaveAtten;
				float4 c =  EncodeHeightRG(waveValue);
				c.ba = val.rg;
                return c;
            }
            ENDCG
        }
    }
}
