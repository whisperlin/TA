Shader "Hidden/CmdBuffNDCWorldPos"
{
    Properties
    {
 
 
    }
    SubShader
    {
 
        Cull Off ZWrite Off ZTest Always

        Pass
		{
			CGPROGRAM

			#pragma multi_compile _ IGORE_VP

			#pragma multi_compile _ ORTHOGRAPHIC 

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 screenPos : TEXCOORD0;
				float3 viewVec : TEXCOORD1;
			};
			
			v2f vert(appdata_base v)
			{
				v2f o;
//全屏后处理。
#if IGORE_VP
				
				o.vertex = v.vertex;
#else
//构建近截面网格
				float4 nearViewPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
				o.vertex = mul(UNITY_MATRIX_VP, nearViewPos);
#endif
				 
				
				// Compute texture coordinate
				o.screenPos = ComputeScreenPos(o.vertex);

				// NDC position
				float4 ndcPos = (o.screenPos / o.screenPos.w) * 2 - 1;

				// Camera parameter
				float far = _ProjectionParams.z;

				float3 clipVec = float3(ndcPos.x, ndcPos.y, 1.0) * far;
				o.viewVec = mul(unity_CameraInvProjection, clipVec.xyzz).xyz;
				

 		

				return o;
			}

			sampler2D _CameraDepthTexture;

			inline float GetOrthoDepthFromZBuffer(float rawDepth)
			{
#if defined(UNITY_REVERSED_Z)
#if UNITY_REVERSED_Z == 1
				rawDepth = 1.0f - rawDepth;
#endif
#endif

				return lerp(_ProjectionParams.y, _ProjectionParams.z, rawDepth);
			}

			half4 frag(v2f i) : SV_Target
			{

 
				
				// Sample the depth texture to get the linear 01 depth
				float depth = UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, i.screenPos));
			

#if ORTHOGRAPHIC
			depth = GetOrthoDepthFromZBuffer(depth);
			clip(0.9 - depth);
#else

			depth = Linear01Depth(depth);

			clip(0.9 - depth);
#endif
				

				
			

				

				// View space position
				float3 viewPos = i.viewVec * depth;

				// Pixel world position
				float3 worldPos = mul(UNITY_MATRIX_I_V, float4(viewPos, 1)).xyz;

				return float4(worldPos*0.1, 1.0);
			}
			ENDCG
		}
    }
}
