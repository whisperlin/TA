Shader "Unlit/Volumetic3D URP"
{
    Properties
    {
        _3DTex ("Texture", 3D) = "" {}
		_Density("_Density",Range(0,1)) =1
		_SamplingQuality("_SamplingQuality",Range(5,64)) = 5
    }
    SubShader
    {
         Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
			Cull front
			Blend One One
			ZWrite false

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

			TEXTURE3D( _3DTex);
			SAMPLER(sampler_3DTex);

			CBUFFER_START(UnityPerMaterial)
			int _SamplingQuality;
			float _Density;
			CBUFFER_END
            struct Attributes
            {
 
                float4 positionOS   : POSITION;
            };

            struct Varyings
            {
 
                float4 positionHCS  : SV_POSITION;

				float3 localPos : TEXCOORD0;
				float4 screenPos : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
            };

 
            Varyings vert(Attributes i)
            {
                Varyings o;
				o.localPos = i.positionOS.xyz;
				float3 worldPos = TransformObjectToWorld(i.positionOS.xyz);
				float3 viewPos = TransformWorldToView(worldPos.xyz);
				float3 hcsPos = TransformWorldToHClip(worldPos.xyz);

				o.positionHCS = TransformObjectToHClip(i.positionOS.xyz);
				o.screenPos = ComputeScreenPos(o.positionHCS);
				o.screenPos.z = -viewPos.z;
				o.worldPos = worldPos;
                return o;
            }

			struct Ray
			{
				float3 origin;
				float3 direction;
			};
			bool IntersectBox(Ray ray, out float entryPoint, out float exitPoint)
			{
				float3 invR = 1.0 / ray.direction;
				float3 tbot = invR * (float3(-0.5, -0.5, -0.5) - ray.origin);
				float3 ttop = invR * (float3(0.5, 0.5, 0.5) - ray.origin);
				float3 tmin = min(ttop, tbot);
				float3 tmax = max(ttop, tbot);
				float2 t = max(tmin.xx, tmin.yz);
				entryPoint = max(t.x, t.y);
				t = min(tmax.xx, tmax.yz);
				exitPoint = min(t.x, t.y);
				return entryPoint <= exitPoint;
			}

  
            half4 frag(Varyings i) : SV_Target
            {

                 float3 localCameraPosition = UNITY_MATRIX_IT_MV[3].xyz;
				 Ray ray;
				 ray.origin = localCameraPosition;
				 ray.direction = normalize(i.localPos - localCameraPosition);

				 float entryPoint, exitPoint;
				 IntersectBox(ray, entryPoint, exitPoint);
				 if (entryPoint < 0.0) entryPoint = 0.0;

				 float3 rayStart = ray.origin + ray.direction * entryPoint;
				 float3 rayStop = ray.origin + ray.direction * exitPoint;

				float3 start = rayStop;
				float dist = distance(rayStop, rayStart);
				float stepSize = dist / float(_SamplingQuality);
				float3 ds = normalize(rayStop - rayStart) * stepSize;
				
				float4 color = float4(0,0,0,0);
				for (int i = _SamplingQuality; i >= 0; --i)
				{
					float3 pos = start.xyz;
					pos.xyz = pos.xyz + 0.5f;
					float4 mask = SAMPLE_TEXTURE3D(_3DTex,sampler_3DTex, pos);
					color.xyz += mask.xyz * mask.w;
					start -= ds;
				}
				color *= _Density / (uint)_SamplingQuality;

		

				return color;

            }
            ENDHLSL
        }
    }
}
