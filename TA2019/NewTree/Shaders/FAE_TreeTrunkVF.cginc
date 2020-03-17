 

				

				#include "UnityCG.cginc"
				#include "AutoLight.cginc" //第三步// 
				#include "Lighting.cginc"

				#include "../../Shader/FogCommon.cginc"

				#include "../../Shader/SceneWeather.inc" 
				#include "../../Shader/snow.cginc"
				#if UNITY_PASS_META
				#include "UnityMetaPass.cginc"
				#endif

				struct appdata
				{
					float4 vertex : POSITION;
					float3 normal :NORMAL;
					float4 tangent: TANGENT;
					float4 color: COLOR;
					float2 uv : TEXCOORD0;
					float2 uv2 : TEXCOORD1;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float2 uv2: TEXCOORD1;
					float4 vertexToFrag: TEXCOORD2;
					float4 color : TEXCOORD3;
					float3 worldPos : TEXCOORD4;


					half3 tspace0 : TEXCOORD5; // tangent.x, bitangent.x, normal.x
					half3 tspace1 : TEXCOORD6; // tangent.y, bitangent.y, normal.y
					half3 tspace2 : TEXCOORD7; // tangent.z, bitangent.z, normal.z

					half3 SH : TEXCOORD8;
					UBPA_FOG_COORDS(10)
#if UNITY_SHADOW
					LIGHTING_COORDS(11, 12) //第四步// 
#endif
					float4 pos : SV_POSITION;
				};

				uniform float _WindSpeed;
				uniform float _TrunkWindSpeed;
				uniform float4 _WindDirection;
				uniform float _TrunkWindSwinging;
				uniform half _TrunkWindWeight;
				uniform float _UseSpeedTreeWind;
				uniform sampler2D _BumpMap;
				uniform float4 _BumpMap_ST;
				uniform float _GradientBrightness;
				uniform sampler2D _MainTex;
				uniform float4 _MainTex_ST;
				uniform float _Smoothness;
				uniform float _AmbientOcclusion;

				inline half fixHalf(half f)
				{
					return floor(f * 10000)*0.0001;
				}
				float3 unityBRDF(float3 specularColor,float roughness,float NdotL, float NdotV, float NdotH, float VdotH, float LdotH)
				{
					float visTerm = SmithJointGGXVisibilityTerm(NdotL, NdotV, roughness);
					float normTerm = GGXTerm(NdotH, roughness);
					float specularPBL = (visTerm*normTerm) * UNITY_PI;
	#ifdef UNITY_COLORSPACE_GAMMA
					specularPBL = sqrt(max(1e-4h, specularPBL));
	#endif
					specularPBL = max(0, specularPBL * NdotL);
	#if defined(_SPECULARHIGHLIGHTS_OFF)
					specularPBL = 0.0;
	#endif
					specularPBL *= any(specularColor) ? 1.0 : 0.0;
					float3 directSpecular = specularPBL * FresnelTerm(specularColor, LdotH);
					return directSpecular;
				}
				void vertexDataFunc(inout appdata v)
				{

					float3 ase_objectScale = float3(length(unity_ObjectToWorld[0].xyz), length(unity_ObjectToWorld[1].xyz), length(unity_ObjectToWorld[2].xyz));
					float3 windDirV3 = (float3(_WindDirection.x, 0.0, _WindDirection.z));
					windDirV3 = mul(unity_WorldToObject, windDirV3);
					float3 _Vector1 = float3(1, 1, 1);
					float3 break94 = (float3(0, 0, 0) + (sin(((((_WindSpeed * 0.05) * _Time.w) * (_TrunkWindSpeed / ase_objectScale)) * windDirV3)) - (float3(-1, -1, -1) + _TrunkWindSwinging)) * (_Vector1 - float3(0, 0, 0)) / (_Vector1 - (float3(-1, -1, -1) + _TrunkWindSwinging)));
					float3 appendResult93 = (float3(break94.x, 0.0, break94.z));
					float3 temp_output_41_0 = (appendResult93 * _TrunkWindWeight * lerp(v.color.a, (v.uv.xy.y * 0.01), _UseSpeedTreeWind));
					float3 Wind111 = temp_output_41_0;
					v.vertex.xyz += Wind111;
				}


				v2f vert(appdata v)
				{
					v2f o;
					vertexDataFunc(v);

					float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
					o.worldPos = worldPos;
					o.pos = mul(UNITY_MATRIX_VP, float4(worldPos, 1.0));
					o.color = v.color;
					o.uv2 = v.uv2;
					o.uv = v.uv;

					half3 wNormal = UnityObjectToWorldNormal(v.normal);
					half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
					// compute bitangent from cross product of normal and tangent
					half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
					half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
					// output the tangent space matrix
					o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
					o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
					o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
					o.SH = ShadeSH9(float4(wNormal, 1));

					UBPA_TRANSFER_FOG(o, v.vertex);
					 
#if UNITY_SHADOW
					TRANSFER_VERTEX_TO_FRAGMENT(o); //第5步// 
#endif
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					float2 uv_BumpMap = i.uv * _BumpMap_ST.xy + _BumpMap_ST.zw;
					half3 tnormal = UnpackNormal(tex2D(_BumpMap, uv_BumpMap));
					// transform normal from tangent to world space
					half3 worldNormal;
					worldNormal.x = dot(i.tspace0, tnormal);
					worldNormal.y = dot(i.tspace1, tnormal);
					worldNormal.z = dot(i.tspace2, tnormal);
					worldNormal = normalize(worldNormal);
					float2 uv_MainTex = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
					float4 tex2DMain = tex2D(_MainTex, uv_MainTex);
					float4 diffuse = lerp((_GradientBrightness * tex2DMain), tex2DMain, lerp((1.0 - (i.color.a * 10.0)), i.uv2.y, _UseSpeedTreeWind));

					

#if _ISWEATHER_ON

#if SNOW_ENABLE 
					fixed nt;
					CmpSnowNormalAndPower(i.uv, float3(i.tspace0.x, i.tspace0.y, i.tspace0.z), nt, worldNormal);
#endif
#endif
#if _ISWEATHER_ON
#if RAIN_ENABLE 

					calc_weather_info(i.worldPos.xyz, worldNormal, tnormal, diffuse, worldNormal, diffuse.rgb);
#endif
#endif
					half Roughness109 = (tex2DMain.a * _Smoothness);
					half Smoothness = Roughness109;
					float lerpResult120 = lerp(1.0, i.color.r, _AmbientOcclusion);
					float AmbientOcclusion = lerpResult120;

					#if UNITY_PASS_META
					UnityMetaInput o;

					o.Emission = 0;
					o.Albedo = diffuse  ; // No gloss connected. Assume it's 0.5

					return UnityMetaFragment(o);

					#endif


	#if ADD_PASS
					float3 lightDir = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.worldPos.xyz, _WorldSpaceLightPos0.w));
	#else
					float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
	#endif

					half NdotL = saturate(dot(worldNormal, lightDir));
					float4 c = diffuse;

#if UNITY_SHADOW
					float attenuation = LIGHT_ATTENUATION(i);
#else
					float attenuation = 1;
#endif



#if _ISWEATHER_ON
#if RAIN_ENABLE  
					_Smoothness = saturate(_Smoothness* get_smoothnessRate());
#endif
#if(SNOW_ENABLE)
					_Smoothness = lerp(_Smoothness, _SnowGloss, nt);
#endif
#endif

					half perceptualRoughness = 1.0 - _Smoothness;
					half roughness = perceptualRoughness * perceptualRoughness;
					float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

					//return  float4(perceptualRoughness, perceptualRoughness, perceptualRoughness, 1);
					float3 halfDirection = normalize(viewDir + lightDir);
					float LdotH = saturate(dot(lightDir, halfDirection));
					float NdotH = saturate(dot(worldNormal, halfDirection));

					float NdotV = abs(dot(worldNormal, viewDir));
					float VdotH = saturate(dot(viewDir, halfDirection));
					float3 specularColor = unity_ColorSpaceDielectricSpec.rgb;
					float3 specular =  unityBRDF(specularColor, roughness, NdotL, NdotV, NdotH, VdotH, LdotH);

					c.rgb = (i.SH + _LightColor0 * NdotL * attenuation + specular) * c.rgb;
					c.rgb *= AmbientOcclusion;
					UBPA_APPLY_FOG(i, c);
					return c;
				}
				