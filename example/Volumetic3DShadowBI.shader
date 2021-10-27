Shader "Unlit/Volumetic3D Shadow Build in"
{
    Properties
    {
		 _MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("_NoiseTex", 2D) = "white" {}
		[HDR]_Color("Color",Color) = (1,1,1,1)
	 
		_SamplingQuality("_SamplingQuality",Range(5,64)) = 5

		[Toggle(_MARK)] _MARK("S_BOOL", Int) = 0
		 
    }
    SubShader
	{
 
		Tags { "RenderType"="Transparent"  "Queue" = "Transparent-500"}
		CGINCLUDE

		
		#define FORWARD_BASE_PASS
		

		#include "UnityCG.cginc"
		#include "AutoLight.cginc"  
		#include "UnityShadowLibrary.cginc"
 
		sampler2D _MainTex;
		sampler2D _NoiseTex;

		int _SamplingQuality;
		half4 _Color;
		float4 _MainTex_ST;
		float4 _NoiseTex_ST;

		 UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float, _Density)
            UNITY_INSTANCING_BUFFER_END(Props)
		struct v2f
		{
			float4 pos : SV_POSITION;
			float3 localPos : TEXCOORD0;
			float4 screenPos : TEXCOORD1;
			float3 worldPos : TEXCOORD2;

 
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		v2f vert(appdata_base v)
		{
			v2f o;

			UNITY_SETUP_INSTANCE_ID(v);
             UNITY_TRANSFER_INSTANCE_ID(v, o); // necessary only if you want to access instanced properties in the fragment Shader.

			float4 wpos =  mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
			o.pos =  mul(UNITY_MATRIX_VP, wpos);
			o.localPos = v.vertex.xyz;
			o.screenPos = ComputeScreenPos(o.pos);
			COMPUTE_EYEDEPTH(o.screenPos.z);
			 
			o.worldPos = wpos;
	 		 
			return o;
		}

		// usual ray/cube intersection algorithm
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
		 
 
		float4 frag(v2f i) : COLOR
		{
			UNITY_SETUP_INSTANCE_ID(i); // necessary only if any instanced properties are going to be accessed in the fragment Shader.
  
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
			float3 ds0 = normalize(rayStop - rayStart) * stepSize;
			float3 ds =  mul((float3x3)unity_ObjectToWorld,ds0);
			float z0 = 1-( i.localPos.z+0.5);
			float z1 = 1- (rayStop.z+0.5); 
			half4 worldPos  = half4(i.worldPos.xyz , z0); 
 
			 
			
			float deltaZ = (z1- z0)/ float(_SamplingQuality);
			float4 delta = float4(ds,deltaZ  ); 


		 
			float4 color = float4(0,0,0,0);

			#if _MARK
				float2 uv0 = i.localPos.xy+0.5;
				#endif
			 
				float hd = 0;
				for (int i = _SamplingQuality; i >= 0; --i)
				{

					#if _MARK
					
					half4 mark = tex2d(_MainTex, uv0   );
					mark.r  = saturate(mark.r*100);
					half4 mark1 = tex2d(_NoiseTex, sampler_NoiseTex, uv0*_NoiseTex_ST.xy );
					
					half4 mark2 = tex2d(_NoiseTex, sampler_NoiseTex, uv0*_NoiseTex_ST.xy+  _NoiseTex_ST.zw*_Time.y);
					mark1 = (mark1 + mark2 )  * 0.5  ;
					
					mark1 =  mark1.r*0.5+0.5;
					mark.r *= mark1.r;
					
					uv0+=ds0.xy;
	 
					#endif
				 

					 float intensity = UNITY_SHADOW_ATTENUATION(i, worldPos.xyz); 

    
					#if _MARK
					hd += intensity * worldPos.w  * mark.r* mark.r;
					#else
					hd += intensity * worldPos.w   ;
					#endif
					
					worldPos += delta;
				 
				}
				hd  /= _SamplingQuality;
				color = _Color * dist*hd  ; 
				

		

				return color;
		}
		ENDCG

		Pass
		{
			Tags { "LightMode"="ForwardBase"} //第一步//
			//Cull front
			Blend One One
			ZWrite false

			CGPROGRAM

			#pragma multi_compile_instancing

			#pragma multi_compile _ _MARK
			#pragma multi_compile  LIGHTPROBE_SH
			#pragma multi_compile  DIRECTIONAL
			#pragma multi_compile _  SHADOWS_SCREEN 
			#pragma multi_compile _  SHADOWS_SINGLE_CASCADE
			

			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			ENDCG

		}
	}
}
