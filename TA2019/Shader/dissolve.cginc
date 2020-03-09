#if __DISS_SHADOW
			
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_fog
            #pragma only_renderers d3d11 gles3 
            #pragma target 3.0
            uniform float _DissolvePower;
            uniform sampler2D _Noise; uniform float4 _Noise_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float4 _Noise_var = tex2D(_Noise,TRANSFORM_TEX(i.uv0, _Noise));
				float t = _Noise_var.r - _DissolvePower - 0.0001;
				clip(t);
                SHADOW_CASTER_FRAGMENT(i)
            }

#else


            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma only_renderers d3d11 gles3 
            #pragma target 3.0
            uniform half4 _LightColor0;
            uniform half _DissolvePower;
            uniform sampler2D _Noise; uniform float4 _Noise_ST;
            uniform sampler2D _Albedo; uniform float4 _Albedo_ST;
            uniform half4 _BorderColor;

#if _ENABLE_NORMAL
            uniform sampler2D _NormaLMap; uniform float4 _NormaLMap_ST;
#endif
			uniform half _edge;
			uniform half _alphaEdge;
			uniform half _bright;
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
#if _ENABLE_NORMAL
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
#endif
                LIGHTING_COORDS(5,6)
                UNITY_FOG_COORDS(7)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
#if _ENABLE_NORMAL
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
#endif
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
               
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				
#if _ENABLE_NORMAL
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				float3 _NormaLMap_var = UnpackNormal(tex2D(_NormaLMap, TRANSFORM_TEX(i.uv0, _NormaLMap)));
                float3 normalLocal = _NormaLMap_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
#else
				float3 normalDirection = i.normalDir;
#endif
                float4 _Noise_var = tex2D(_Noise,TRANSFORM_TEX(i.uv0, _Noise));
                float t = _Noise_var.r -  _DissolvePower - 0.0001 ;

                #if _SOFT_EDGE 
                clip(t  +_alphaEdge );
                #else
                clip(t  );
                #endif


                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
/////// Diffuse:
                float NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                float3 indirectDiffuse = float3(0,0,0);
                indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb; // Ambient Light
                float4 _Albedo_var = tex2D(_Albedo,TRANSFORM_TEX(i.uv0, _Albedo));

                float t1 = smoothstep(0, _edge, t);
				float3 diffuseColor = lerp((_Albedo_var.rgb*_BorderColor.rgb*_bright), _Albedo_var.rgb, t1 );

                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse;
                fixed4 finalRGBA = fixed4(finalColor,1);

                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);

 #if _SOFT_EDGE 

 			 	float a1 = smoothstep(0, _alphaEdge, t+_alphaEdge);
 			 	finalRGBA.a =  a1;
#endif
                
               
                return finalRGBA;
            }

#endif