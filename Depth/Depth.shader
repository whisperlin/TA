//https://roystan.net/articles/toon-water.html
//
Shader "TA/Depth"
{
    Properties
    {
		_DepthGradientShallow("Depth Gradient Shallow", Color) = (0.325, 0.807, 0.971, 0.725)
		_DepthGradientDeep("Depth Gradient Deep", Color) = (0.086, 0.407, 1, 0.749)
		_DepthMaxDistance("深度最大距离", Float) = 1
		_DepthCtrl("深度调节",Range(0,2))=1
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
			float _DepthCtrl;
			sampler2D _CameraDepthTexture;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;

				float4 screenPosition : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);

				o.screenPosition = ComputeScreenPos(o.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				//float existingDepth01 = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPosition)).r;
				//float existingDepthLinear = LinearEyeDepth(existingDepth01);
				//return depthDifference;

				float4 ase_screenPos = float4( i.screenPosition.xyz , i.screenPosition.w + 0.00000000001 );
				float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(ase_screenPos))));
				float distanceDepth = abs( ( screenDepth - LinearEyeDepth( ase_screenPosNorm.z ) ) / (  lerp( 1.0 , ( 1.0 / _ProjectionParams.z ) , unity_OrthoParams.w) ) );

				return distanceDepth*_DepthCtrl;

				//float depthDifference = existingDepthLinear - i.screenPosition.w;

				
				 
            }
            ENDCG
        }
    }
}