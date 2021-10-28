Shader "Unlit/Volumetic3D URP From Shadow Map"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("_NoiseTex", 2D) = "white" {}
		[HDR]_Color("Color",Color) = (1,1,1,1)
	 
		_SamplingQuality("_SamplingQuality",Range(5,64)) = 5

		[Toggle(_MARK)] _MARK("S_BOOL", Int) = 0


 
		_Downner("_Downner",Range(0.5,1)) = 1
 
    }
    SubShader
    {
         Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
	 
			Blend One One
			ZWrite false

            HLSLPROGRAM
			#pragma multi_compile _ _MARK
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
		
            //
			
			
			#pragma multi_compile _ _SHADOWS_SOFT

            #pragma vertex vert
            #pragma fragment frag

             #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

			TEXTURE2D( _MainTex);
			SAMPLER(sampler_MainTex);
			TEXTURE2D( _NoiseTex);
			SAMPLER(sampler_NoiseTex);
			

			CBUFFER_START(UnityPerMaterial)
			int _SamplingQuality;
 
			half4 _Color;
			float4 _MainTex_ST;
			float4 _NoiseTex_ST;
 
			half _Downner;
			
 
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

				float invSQ =  1.0 / float(_SamplingQuality);
				float stepSize = dist  * invSQ;
				float3 ds0 = normalize(rayStop - rayStart) * stepSize;

				float3 ds =  mul((float3x3)UNITY_MATRIX_M,ds0);
				float z0 = 1-( i.localPos.z+0.5);
				float z1 = 1- (rayStop.z+0.5);
				float deltaZ = (z1- z0) * invSQ;
				float4 delta = float4(ds,deltaZ  ); 

				half4 worldPos  = half4(i.worldPos , z0); 
				float4 color = float4(0,0,0,0);

			 

				#if _MARK



				float2 uv0 = i.localPos.xy *  lerp(_Downner,1,z0) +0.5;
				float2 uv1 = rayStop.xy *  lerp(_Downner,1,z1) +0.5;
				ds0.xy = (uv1-uv0)*invSQ;
				#endif
			 
				float hd = 0;
				for (int j = _SamplingQuality; j >= 0; --j)
				{

					#if _MARK
	 
					
					half4 mark = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,  saturate( uv0) );
					mark.r  = saturate(mark.r*100);
					half4 mark1 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, uv0*_NoiseTex_ST.xy );
					half4 mark2 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, uv0*_NoiseTex_ST.xy+  _NoiseTex_ST.zw*_Time.y);
					mark1 = (mark1 + mark2 )  * 0.5  ;
					mark1 =  mark1.r*0.5+0.5;
					mark.r *= mark1.r;
					
					uv0+=ds0.xy;
					#endif
					 
					float4 shadowPos = TransformWorldToShadowCoord(worldPos.xyz);
                    			float intensity = MainLightRealtimeShadow(shadowPos);
					#if _MARK
					hd += intensity * worldPos.w * worldPos.w  * mark.r   ;
					#else
					hd += intensity * worldPos.w   ;
					#endif
					
					worldPos += delta;
				}
				hd  /= _SamplingQuality;
				color = _Color * dist*hd  ; 

				return color;
            }
            ENDHLSL
        }
    }
}
