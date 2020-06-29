

//#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
//#pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON


#if LIGHTMAP_ON
#define LIGHTING_COORDS_OPE(idx0,idx1)  
#else
#define LIGHTING_COORDS_OPE(idx0,idx1)  LIGHTING_COORDS(idx1, idx2)
#endif

#define AMBIENT_OR_LIGHTMAP_UV(id0,id1,idx2)\
LIGHTING_COORDS_OPE(idx0,idx1)\
float4 ambientOrLightmapUV : TEXCOORD##idx2;


//LIGHTMAP_UVS(0,1,2);
#ifdef DYNAMICLIGHTMAP_ON

#define LIGHTMAP_UVS_D( idx2)\
	float2 uv2 : TEXCOORD##idx2;
#else
#define LIGHTMAP_UVS_D( idx2)  

#endif

#ifdef LIGHTMAP_ON
	#define LIGHTMAP_UVS(idx0,idx1,idx2)\
	float2 uv0 : TEXCOORD##idx0;\
	float2 uv1 : TEXCOORD##idx1;\
	LIGHTMAP_UVS_D(idx2)
#else
	#define LIGHTMAP_UVS(idx0,idx1,idx2)\
	float2 uv0 : TEXCOORD##idx0;\
	LIGHTMAP_UVS_D(idx2)

#endif






 





#ifdef LIGHTMAP_ON
	#define	   AMBIENT_OR_LIGHTMAP_UV_SETUP_CM(o,v,posWorld,normalWorld) \
	o.ambientOrLightmapUV.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;\
	o.ambientOrLightmapUV.zw = 0;
#else
	#ifdef VERTEXLIGHT_ON
		#define	   AMBIENT_OR_LIGHTMAP_UV_SETUP_CM(o,v,posWorld,normalWorld) \
					o.ambientOrLightmapUV.rgb = Shade4PointLights(	\
					unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,	\
					unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,	\
					unity_4LightAtten0, posWorld, normalWorld);	\
					o.ambientOrLightmapUV.rgb = ShadeSHPerVertex(normalWorld, 0);	
	#else
		#define	   AMBIENT_OR_LIGHTMAP_UV_SETUP_CM(o,v,posWorld,normalWorld) \
		o.ambientOrLightmapUV.rgb = ShadeSHPerVertex(normalWorld, 0);	
	#endif
#endif

#ifdef DYNAMICLIGHTMAP_ON
	#define	   AMBIENT_OR_LIGHTMAP_UV_SETUP_DM(o,v,posWorld,normalWorld) \
	o.ambientOrLightmapUV.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#else
	#define	   AMBIENT_OR_LIGHTMAP_UV_SETUP_DM(o,v,posWorld,normalWorld)    \

#endif

#define	   AMBIENT_OR_LIGHTMAP_UV_SETUP(o,v,posWorld,normalWorld)  AMBIENT_OR_LIGHTMAP_UV_SETUP_CM(o,v,posWorld,normalWorld)  AMBIENT_OR_LIGHTMAP_UV_SETUP_DM(o,v,posWorld,normalWorld) 
	


UnityGI GetBakeGI(float4  ambientOrLightmapUV,  float3 normalDirection ,float3 posWorld, float3 viewDirection,float3 viewReflectDirection,float gloss)
{
	UnityLight light;
#ifdef LIGHTMAP_ON
	light.color = half3(0.f, 0.f, 0.f);
	light.ndotl = 0.0f;
	light.dir = half3(0.f, 0.f, 0.f);
#else
	light.color = _LightColor0.rgb;
	light.dir = normalize(_WorldSpaceLightPos0.xyz);
	light.ndotl = LambertTerm(normalDirection, light.dir);
#endif
 

	UnityGIInput d = (UnityGIInput)0;
	d.light = light;
	d.worldPos = posWorld.xyz;
	d.worldViewDir = viewDirection;

	//d.atten = attenuation;
#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
	d.ambient = 0;
	d.lightmapUV = ambientOrLightmapUV;
#else
	d.ambient = ambientOrLightmapUV;
#endif
#if UNITY_SPECCUBE_BLENDING || UNITY_SPECCUBE_BOX_PROJECTION
	d.boxMin[0] = unity_SpecCube0_BoxMin;
	d.boxMin[1] = unity_SpecCube1_BoxMin;
#endif
#if UNITY_SPECCUBE_BOX_PROJECTION
	d.boxMax[0] = unity_SpecCube0_BoxMax;
	d.boxMax[1] = unity_SpecCube1_BoxMax;
	d.probePosition[0] = unity_SpecCube0_ProbePosition;
	d.probePosition[1] = unity_SpecCube1_ProbePosition;
#endif
	d.probeHDR[0] = unity_SpecCube0_HDR;
	d.probeHDR[1] = unity_SpecCube1_HDR;
	Unity_GlossyEnvironmentData ugls_en_data;
	ugls_en_data.roughness = 1.0 - gloss;
	ugls_en_data.reflUVW = viewReflectDirection;
	return UnityGlobalIllumination(d, 1, normalDirection, ugls_en_data);
	 
}


/*
	Pass {
            Name "Meta"
            Tags {
                "LightMode"="Meta"
            }
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_META 1
            #define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #include "UnityMetaPass.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
            #pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
            #pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog
           
            #pragma target 3.0
            uniform float4 _Color;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float _Metallic;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float2 texcoord2 : TEXCOORD2;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float4 posWorld : TEXCOORD3;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.uv2 = v.texcoord2;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST );
                return o;
            }
            float4 frag(VertexOutput i) : SV_Target {
 
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT( UnityMetaInput, o );
                o.Emission = 0; 
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float3 diffColor = (_MainTex_var.rgb*_Color.rgb);
                float specularMonochrome;
                float3 specColor;
                diffColor = DiffuseAndSpecularFromMetallic( diffColor, _Metallic, specColor, specularMonochrome );
   
                o.Albedo = diffColor  ;
                
                return UnityMetaFragment( o );
            }
            ENDCG
        }
*/

