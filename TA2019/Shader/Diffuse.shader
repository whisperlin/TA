// Upgrade NOTE: replaced 'UNITY_INSTANCE_ID' with 'UNITY_VERTEX_INPUT_INSTANCE_ID'

// Upgrade NOTE: replaced 'UNITY_INSTANCE_ID' with 'UNITY_VERTEX_INPUT_INSTANCE_ID'

// Upgrade NOTE: upgraded instancing buffer 'MyProperties' to new syntax.

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TA/Diffuse"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

	SubShader
	{
		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

			//#pragma   multi_compile  _  FOG_LIGHT
			#pragma   multi_compile  _  LIGHT_MAP_CTRL
 
			


			#pragma   multi_compile  _  COMBINE_SHADOWMARK

			#include "UnityCG.cginc"
			#include "FogCommon.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc" //µÚÈý²½// 
			#include "bake.cginc"

			#pragma multi_compile_instancing
 
			#include "shadowmarkex.cginc"

			
 

			struct appdata
			{
				float4 vertex : POSITION;
				LIGHTMAP_UVS(0,1,2)
				
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv0 : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				float2 uv1 : TEXCOORD1;
#else
				LIGHTING_COORDS(5,6)
#endif
				
				float4 wpos:TEXCOORD2;
				UBPA_FOG_COORDS(3)
				float3 normalWorld : TEXCOORD4;
				float3 sh : TEXCOORD10;
				float4 pos : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
half4 LightMapInf;
			sampler2D _MainTex;
 
#ifdef BRIGHTNESS_ON
			fixed3 _Brightness;
#endif

			#define UNITY_SAMPLE_TEX2D(tex,coord) tex.Sample (sampler##tex,coord)

			#include "UnityGlobalIllumination.cginc"
			fixed UnitySampleBakedOcclusion2(float2 lightmapUV, float3 worldPos )
			{

				half bakedAtten = UnitySampleBakedOcclusion(lightmapUV.xy, worldPos);
				//return bakedAtten;
				float zDist = dot(_WorldSpaceCameraPos - worldPos, UNITY_MATRIX_V[2].xyz);
				float fadeDist = UnityComputeShadowFadeDistance(worldPos, zDist);
				float shadowFade = UnityComputeShadowFade(fadeDist);
			 
				return bakedAtten;
 
			}
			v2f vert (appdata v)
			{


				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);


#if COMBINE_SHADOWMARK
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
#endif
				o.pos = UnityObjectToClipPos(v.vertex);
				float4 wpos = mul(unity_ObjectToWorld, v.vertex); 
				o.wpos = wpos;
				o.uv0 = v.uv0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				o.uv1 = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
				TRANSFER_VERTEX_TO_FRAGMENT(o);
#endif
				o.normalWorld = UnityObjectToWorldNormal(v.normal);
				
				o.sh = ShadeSH9(half4(o.normalWorld, 1));
				UBPA_TRANSFER_FOG(o, v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv0);

 
#if COMBINE_SHADOWMARK
			UNITY_SETUP_INSTANCE_ID(i);
#endif

 
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
 
	
			GETLIGHTMAP(i.uv1);
	 
			lightmap.rgb *= LightMapInf.rgb *(1 + LightMapInf.a);//
				

 
	#if    SHADOWS_SHADOWMASK 
			
		half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
		half nl = saturate(dot(i.normalWorld, lightDir));

		_LightColor0.rgb *= attenuation;
		
		c.rgb =   _LightColor0 * nl * c.rgb + lightmap * c.rgb;

 
	#else
		c.rgb *= lightmap;
			 
	#endif
#else
				
				half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				half nl = saturate(dot(i.normalWorld, lightDir));
				c.rgb = (i.sh  + _LightColor0 * nl  * LIGHT_ATTENUATION(i)  )* c.rgb;
		 
#endif

#ifdef BRIGHTNESS_ON
				c.rgb = c.rgb * _Brightness * 2;
#endif


				
 
 
				UBPA_APPLY_FOG(i, c);
				return c;
			}
			ENDCG
		}


		Pass{
			Name "FORWARD_DELTA"
			Tags {
				"LightMode" = "ForwardAdd"
			}
			Blend One One


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define UNITY_PASS_FORWARDADD
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile_fog
			#pragma only_renderers d3d9 d3d11 glcore gles 
			#pragma target 3.0
			uniform float4 _LightColor0;
 
			uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
			uniform sampler2D _Bump; uniform float4 _Bump_ST;
			uniform float _Gloss;
			uniform float _Specular;
			uniform float4 _Emission;
			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 texcoord0 : TEXCOORD0;
			};
			struct VertexOutput {
				float4 pos : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalDir : TEXCOORD2;
				float3 tangentDir : TEXCOORD3;
				float3 bitangentDir : TEXCOORD4;
				LIGHTING_COORDS(5,6)
				UNITY_FOG_COORDS(7)
			};
			VertexOutput vert(VertexInput v) {
				VertexOutput o = (VertexOutput)0;
				o.uv0 = v.texcoord0;
				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.tangentDir = UnityObjectToWorldDir(v.tangent.xyz);
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				o.bitangentDir = cross(o.normalDir, o.tangentDir) * tangentSign;
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				float3 lightColor = _LightColor0.rgb;
				o.pos = UnityObjectToClipPos(v.vertex);
				UNITY_TRANSFER_FOG(o,o.pos);
				TRANSFER_VERTEX_TO_FRAGMENT(o)
				return o;
			}
			float4 frag(VertexOutput i) : COLOR {
				i.normalDir = normalize(i.normalDir);
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3 _Bump_var = UnpackNormal(tex2D(_Bump,TRANSFORM_TEX(i.uv0, _Bump)));
				float3 normalLocal = _Bump_var.rgb;
				float3 normalDirection = normalize(mul(normalLocal, tangentTransform)); // Perturbed normals
				float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
				float3 lightColor = _LightColor0.rgb;
				float3 halfDirection = normalize(viewDirection + lightDirection);
				////// Lighting:
				float attenuation = LIGHT_ATTENUATION(i);
				float3 attenColor = attenuation * _LightColor0.xyz;
				///////// Gloss:
				float gloss = _Gloss;
				float specPow = exp2(gloss * 10.0 + 1.0);
				////// Specular:
				float NdotL = saturate(dot(normalDirection, lightDirection));
				float3 specularColor = float3(_Specular,_Specular,_Specular);
				float3 directSpecular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),specPow)*specularColor;
				float3 specular = directSpecular;
				/////// Diffuse:
				NdotL = max(0.0,dot(normalDirection, lightDirection));
				float3 directDiffuse = max(0.0, NdotL) * attenColor;
				float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
				float3 diffuseColor = (_MainTex_var.rgb );
				float3 diffuse = directDiffuse * diffuseColor;
				/// Final Color:
				float3 finalColor = diffuse ;
				fixed4 finalRGBA = fixed4(finalColor * 1,0);
				UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
				return finalRGBA;
				}
				ENDCG
		}
	}

	FallBack "Mobile/Diffuse"
}