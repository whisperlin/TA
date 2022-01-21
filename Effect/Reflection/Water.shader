 
Shader "Lch/Water  " {
	Properties{
 
		 _UseReflection("Use Reflection", Range(0,1)) = 0.5

		_ReflectionFresnel("反射菲涅尔", Range(0,3)) = 1
		_ReflectionIntensity("反射强度", Range(0, 1)) = 1
		_RefractionIntensity("Refraction Intensity", Range(0, 2)) = 0
		_NormalTexture("Normal Texture", 2D) = "bump" {}
		_NormalIntensity("Normal Intensity", Range(0, 1)) = 1
		_WaterColor("Water Color", Color) = (1,1,1,1)
		_WaterColor2("Water Color2", Color) = (1,1,1,1)
		_WaterDensity("Water Density", Range(0,5)) = 3

 
 
		_WavesScale("Waves Scale", Range(0.01, 1)) = 0.8
		_WavesSpeed("Waves Speed", Range(0, 1)) = 0
		_Specular("Specular", Range(0,100)) = 5
		_Gloss("Gloss", Range(1, 256)) = 128
		_Displacement("水波贴图_Displacement", 2D) = "white" {}
		_DisplacementIntensity("水波总强度 _DisplacementIntensity", Float) = 1
		_DisplacementScale("水波缩放_DisplacementScale", Range(0.01, 1)) = 0.5
		_DisplacementSpeed("水波速度_DisplacementSpeed", Range(0.01, 10)) = 0.5079523


 
 
 
 
 
 
 
 
 
 
 
 
		[HideInInspector]_Cutoff("Alpha cutoff", Range(0,1)) = 0.5
	}
		SubShader{
			Tags {
				"IgnoreProjector" = "True"
				"Queue" = "Transparent"
				"RenderType" = "Transparent"
			}
			GrabPass{ }
			Pass {
				Name "FORWARD"
				Tags {
					"LightMode" = "ForwardBase"
				}
				Blend SrcAlpha OneMinusSrcAlpha
				ZWrite Off

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#define UNITY_PASS_FORWARDBASE
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#pragma multi_compile_fwdbase
				#pragma multi_compile_fog
				#pragma target 3.0
				#pragma glsl
				uniform sampler2D _GrabTexture;
				uniform sampler2D _CameraDepthTexture;
				uniform float4 _TimeEditor;
 
				uniform float _WaterDensity;
				uniform float _FadeLevel;
				uniform float _ReflectionFresnel;
				uniform float _WavesScale;
				uniform float _WavesSpeed;
				uniform float _NormalIntensity;
				uniform float _Gloss;
				uniform float _Specular;
				uniform float4 _WaterColor;
				uniform float _ReflectionIntensity;
				uniform fixed _UseReflection;
				uniform float4 _ReflectionColor;
				uniform float _RefractionIntensity;
				uniform sampler2D _NormalTexture;
				uniform float4 _NormalTexture_ST;
				uniform sampler2D _Displacement;
				uniform float4 _Displacement_ST;
				uniform float _DisplacementIntensity;
				uniform float _DisplacementScale;
				uniform float _DisplacementSpeed;
 
				uniform float4 _FoamTexture_ST;
 
 
 
 
 
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
					float4 screenPos : TEXCOORD5;
					float4 projPos : TEXCOORD6;
					UNITY_FOG_COORDS(7)
				};

				float4x4 _LchReflectionMatrix;
				sampler2D _LchReflectionTex;
				VertexOutput vert(VertexInput v) {
					VertexOutput o = (VertexOutput)0;
					o.uv0 = v.texcoord0;
					o.normalDir = UnityObjectToWorldNormal(v.normal);
					o.tangentDir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
					o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);

					float3 objScale = mul((float3x3)unity_ObjectToWorld, half3(0.5773502691896182, 0.5773502691896182, 0.5773502691896182)); 

					_DisplacementSpeed = (_DisplacementSpeed*_Time.r);
					float2 uv_scaled = (objScale.rb*_DisplacementScale*o.uv0*0.1) + _DisplacementSpeed;
					float2 noise_uv0 = (uv_scaled + _DisplacementSpeed);
					float4 noise_color0 = tex2Dlod(_Displacement, float4(TRANSFORM_TEX(noise_uv0, _Displacement), 0.0, 0));
					float2 noise_uv1 = (((uv_scaled + float2(0.5, 0.5))* -0.75) + _DisplacementSpeed);
					float4 noise_color1 = tex2Dlod(_Displacement, float4(TRANSFORM_TEX(noise_uv1, _Displacement), 0.0, 0));
					float3 var_noise_color = lerp(noise_color0.rgb, noise_color1.rgb, 0.5);

					v.vertex.xyz += (var_noise_color   *float3(0, _DisplacementIntensity, 0));
					o.posWorld = mul(unity_ObjectToWorld, half4(v.vertex.xyz, 1));

					float3 lightColor = _LightColor0.rgb;
					o.pos = mul(UNITY_MATRIX_VP, o.posWorld);
					UNITY_TRANSFER_FOG(o, o.pos);
					o.projPos = ComputeScreenPos(o.pos);
					COMPUTE_EYEDEPTH(o.projPos.z);
					o.screenPos = o.pos;
					return o;
				}

		 
				float4 frag(VertexOutput i) : COLOR {
					float3 objScale = mul((float3x3)unity_ObjectToWorld, half3(0.5773502691896182, 0.5773502691896182, 0.5773502691896182));
					#if UNITY_UV_STARTS_AT_TOP
						float grabSign = -_ProjectionParams.x;
					#else
						float grabSign = _ProjectionParams.x;
					#endif
					i.normalDir = normalize(i.normalDir);
					i.screenPos = float4(i.screenPos.xy / i.screenPos.w, 0, 0);
					i.screenPos.y *= _ProjectionParams.x;
					float sceneZ = max(0,LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)))) - _ProjectionParams.g);//获取fragment深度值
					float partZ = max(0,i.projPos.z - _ProjectionParams.g);//深度与近裁面差值
	 
					float _speedScale = (_WavesSpeed*_Time.r*1.61803398875);
					float2 _speedScaleuv0 = (i.uv0* objScale.rb *_WavesScale);
					float2 nuv0 = (_speedScaleuv0 + _speedScale * float2(1,-1));
					float3 normal0 = UnpackNormal(tex2D(_NormalTexture,TRANSFORM_TEX(nuv0, _NormalTexture)));
					float2 _speedScaleuv1 = ((_speedScaleuv0 + float2(0.5,0.5))*0.8);
					float2 nuv1 = (_speedScaleuv1 + _speedScale * float2(-1,1));
					float3 normal1 = UnpackNormal(tex2D(_NormalTexture,TRANSFORM_TEX(nuv1, _NormalTexture)));
			 
					float _speedScale2 = (_speedScale*0.6);
		 
					float2 nuv2 = ((0.1*_speedScaleuv0) + _speedScale2 * float2(-1,1));
					float3 normal2 = UnpackNormal(tex2D(_NormalTexture,TRANSFORM_TEX(nuv2, _NormalTexture)));
					float2 nuv3 = ((0.1*_speedScaleuv1) + _speedScale2 * float2(1,-1));
					float3 normal3 = UnpackNormal(tex2D(_NormalTexture,TRANSFORM_TEX(nuv3, _NormalTexture)));
		 
					float3 normal4 = float3(float2(normal0.r + normal1.r, normal0.g + normal1.g) + (float2((normal2.r + normal3.r), (normal2.g + normal3.g))*0.5), 1.0);
					float3 normalLocal = lerp(float3(0,0,1), normal4,_NormalIntensity);

					 
					//float2 sceneUVs = float2(1,grabSign)*i.screenPos.xy*0.5+0.5 + (normalLocal.rg*_RefractionIntensity*0.1);
					float2 sceneUVs = (i.projPos.xy + (normalLocal.rg * _RefractionIntensity * 0.1)) / i.projPos.w;
					float fragDepth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, i.projPos)));;
					float grabDepth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, sceneUVs)));
					if (fragDepth >= grabDepth)
					{
						sceneUVs = i.projPos.xy / i.projPos.w;
					}
					float4 sceneColor = tex2D(_GrabTexture, sceneUVs);

					float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
					/////// Vectors:
					float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
 
					float3 normalDirection = normalize(mul(normalLocal, tangentTransform)); // Perturbed normals
					float3 viewReflectDirection = reflect(-viewDirection, normalDirection);
					float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
			 
					////// Lighting:
					float attenuation = 1;
					float node_8267 = 1.0;


					float4 pj = mul(_LchReflectionMatrix, i.posWorld);
					pj.xy /= pj.w;
					float2 refUV = pj.xy.xy*0.5 + 0.5;
					refUV = 1 - refUV;

			 
					float4 reflect = tex2D(_LchReflectionTex, refUV);
				 
	 
					float3 clampLight = (clamp(_LightColor0.rgb, 0.01, 1));

					float3 lightColor = (clampLight*attenuation);
			 
					half lDotV = dot(lightDirection, viewReflectDirection);
					half nDotV = dot(normalDirection, viewDirection);

					float3 speColor = (_Specular*pow(max(0, lDotV ), exp((_Gloss*9.0 + 1.0)))*lightColor);
					 
					float deltalZ = saturate(sceneZ - partZ);
					float t = 1.0 - saturate((deltalZ) / (_WaterDensity));
 
					half3 refCol = lerp(1, reflect.rgb, _UseReflection) * pow(1.0 - max(0, nDotV), _ReflectionFresnel) *_ReflectionIntensity;
 
					float3 finalColor =

						saturate(

							1.0 -
							(1.0 - sceneColor.rgb*(t*0.75 + 0.25))

							*
							(1.0 - refCol)

						);
 
					finalColor = saturate(finalColor) * clampLight;
					finalColor += speColor;
					fixed4 finalRGBA = fixed4(finalColor.rgb,1);
					UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
					return finalRGBA;
				}
				ENDCG
			}
		}
			FallBack "Diffuse"
		CustomEditor "ShaderForgeMaterialInspector"
}
