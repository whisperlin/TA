Shader "TA/Toon/WaterSimple"
{
    Properties
    {
		_DepthGradientShallow("浅水色", Color) = (0.325, 0.807, 0.971, 0.725)
		_DepthGradientDeep("深水色", Color) = (0.086, 0.407, 1, 0.749)
		_DepthMaxDistance("深度最大距离", Range(0,3)) = 1
		_SurfaceNoise("噪点图", 2D) = "white" {}
		_WaveSpeed("海浪波纹",Vector) = (0.0,0.0,-0.1,0.1)
		_SurfaceNoiseCutoff("Surface Noise Cutoff", Range(0, 1)) = 0.777
		_FoamDistance("海浪距离", Range(0,100)) = 10
    }
    SubShader
    {
        Pass
        {
			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"


			float4 _DepthGradientShallow;
			float4 _DepthGradientDeep;
			float _DepthMaxDistance;
			sampler2D _CameraDepthTexture;
			sampler2D _SurfaceNoise;
			float4 _SurfaceNoise_ST;
			float _SurfaceNoiseCutoff;
			float _FoamDistance;
			float4 _WaveSpeed;
            struct appdata
            {
                float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float4 noiseUV : TEXCOORD0;
				float4 screenPosition : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
				o.noiseUV.xy = TRANSFORM_TEX(v.uv+_WaveSpeed.xy*_Time.yy, _SurfaceNoise);
				o.noiseUV.zw = TRANSFORM_TEX(v.uv+_WaveSpeed.zw*_Time.yy, _SurfaceNoise);
				o.screenPosition = ComputeScreenPos(o.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				float existingDepth01 = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPosition)).r;
				float existingDepthLinear = LinearEyeDepth(existingDepth01);

				float depthDifference = existingDepthLinear - i.screenPosition.w;

				float waterDepthDifference01 = saturate(depthDifference / _DepthMaxDistance);
				float4 waterColor = lerp(_DepthGradientShallow, _DepthGradientDeep, waterDepthDifference01);


				float surfaceNoiseSample = tex2D(_SurfaceNoise, i.noiseUV.xy).r*tex2D(_SurfaceNoise, i.noiseUV.zw).r;

				float foamDepthDifference01 = saturate(depthDifference * _FoamDistance);
				//return float4(foamDepthDifference01.rrr,1);
				float surfaceNoiseCutoff = foamDepthDifference01 * _SurfaceNoiseCutoff;

				//float surfaceNoise = surfaceNoiseSample > surfaceNoiseCutoff ? 1 : 0;
				float surfaceNoise = step(surfaceNoiseCutoff,surfaceNoiseSample);  
				//float surfaceNoise = surfaceNoiseSample > _SurfaceNoiseCutoff ? 1 : 0;
				return waterColor + surfaceNoise;
	 
				 
            }
            ENDCG
        }
    }
}