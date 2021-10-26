



			fixed4 _Color;
			sampler2D _MainTex;
			half4 _MainTex_ST;
			sampler2D _Normal;


			half _Gloss;
			half4 _SpeColor;
 
			sampler2D _SpecMap;

			float4x4 _BackRightMatrix;
			half4 _BackRightColor;
			half _AlphaClip;

#if   ! _META_PASS

			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			
   

			 
			#include "shadows.cginc"
			#include "UnityImageBasedLighting.cginc" 

			struct appdata
			{
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				half2 uv1 : TEXCOORD1;
				half3 normal : NORMAL;
				half4 tangent : TANGENT;
			};

			struct v2f
			{
				half4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				#if _NORMAL_MAP
				half3 tspace0 : TEXCOORD2;
				half3 tspace1 : TEXCOORD3;
				half3 tspace2 : TEXCOORD4;

				#else
				half3 worldNormal : TEXCOORD2;
				#endif
				float3 posWorld : TEXCOORD5;

			

				//half4 ambientOrLightmapUV           : TEXCOORD2; // SH or Lightmap UV


				half4 ambientOrLightmapUV           : TEXCOORD6;
				SHADOW_COORDS(7)
 
			};

			//sampler2D unity_NHxRoughness;

			
			v2f vert(appdata v)
			{
				v2f o;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float4 posWorld =  mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
				o.pos = mul(UNITY_MATRIX_VP, posWorld);
				o.posWorld = posWorld.xyz;
				half3 normal = UnityObjectToWorldNormal(v.normal);
				#if _NORMAL_MAP
				
				half3 tangent = UnityObjectToWorldDir(v.tangent.xyz);
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 bitangent = cross(normal, tangent) * tangentSign;

				o.tspace0 = half3(tangent.x, bitangent.x, normal.x);
				o.tspace1 = half3(tangent.y, bitangent.y, normal.y);
				o.tspace2 = half3(tangent.z, bitangent.z, normal.z);

				#else
				o.worldNormal =  normal;
				#endif
 
				o.ambientOrLightmapUV = VertexGIForward(v.uv1, posWorld, normal);
		 
				TRANSFER_SHADOW(o);


				UNITY_TRANSFER_FOG(o, o.pos);
				return o;
			}

		 
			fixed4 frag(v2f i) : SV_Target
			{

 
				fixed4 albedo = tex2D(_MainTex, i.uv);
				#if  _ALPHA_CLIP
				clip( albedo.a-_AlphaClip);
				#endif
				fixed4 c = albedo * _Color;


				half3 n = UnpackNormal(tex2D(_Normal, i.uv));


				#if _NORMAL_MAP
				half3 normal;
				normal.x = dot(i.tspace0, n);
				normal.y = dot(i.tspace1, n);
				normal.z = dot(i.tspace2, n);

				normal = normalize(normal);

				#else
				half3 normal = normalize(i.worldNormal);
				#endif

				half3 viewDir = normalize(UnityWorldSpaceViewDir(i.posWorld));
				half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 lightColor = _LightColor0;

				

	 

				

	#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
 

				half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.ambientOrLightmapUV.xy);
				half3 ambient  = DecodeLightmap(bakedColorTex);
	#else
				half3 ambient = i.ambientOrLightmapUV.rgb;

		 

	#endif 
			
				
			
				
				half shadowMaskAttenuation = UnitySampleBakedOcclusion(i.ambientOrLightmapUV, 0);
				half realtimeShadowAttenuation = SHADOW_ATTENUATION(i);

				float zDist = dot(_WorldSpaceCameraPos - i.posWorld, UNITY_MATRIX_V[2].xyz);
				float fadeDist = UnityComputeShadowFadeDistance(i.posWorld, zDist);
		 

				half atten = UnityMixRealtimeAndBakedShadows(realtimeShadowAttenuation, shadowMaskAttenuation, UnityComputeShadowFade(fadeDist));
			
			 

				half nl = saturate(dot(normal, lightDir));
 
				

				#if GLOBAL_BACK_LIGHT
				float3 lightDir2 = mul( (float3x3)_BackRightMatrix,lightDir.rgb );
				lightDir2.y = 0;
				lightDir2 = normalize(lightDir2);
				half nl2 = saturate(dot(normal, lightDir2));
				
				//half3 diffuse = (ambient + ( lightColor * nl  + nl2*_BackRightColor.rgb )*atten  )* c.rgb;

				half3 diffuse = (ambient + lightColor * nl *atten +  nl2*_BackRightColor.rgb)* c.rgb;
				#else

				half3 diffuse = (ambient + lightColor * nl *atten)* c.rgb;
				#endif

				//float4x4 _BackRightMatrix
				//half4 _BackRightColor;

				//half3 reflDir = reflect(viewDir, normal);
				c.rgb = diffuse   ;
				#if _SPEC_ENABLE
				half nv = saturate(dot(normal, viewDir));
				fixed4 specMap = tex2D(_SpecMap, i.uv);
				half nDotH =  saturate ( dot(normal, normalize(viewDir + lightDir)) );
				half3 directSpe = pow( nDotH, 1+(_Gloss * specMap.r * 256))* _SpeColor*specMap.g;
				c.rgb += directSpe  ;
				#endif
			
				

 

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, c);
				return c;
			}





#else


	   #include "UnityCG.cginc"
       #include "UnityMetaPass.cginc"

        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uvMain : TEXCOORD0;
 
 
            UNITY_VERTEX_OUTPUT_STEREO
        };

        //float4 _MainTex_ST;
        //float4 _Illum_ST;

        v2f vertMeta (appdat
