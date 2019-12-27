Shader "TA/Water(Depth)"
{
	Properties
	{
		_Color("深水色", Color) = (0.23828125, 0.53515625, 0.7297, 0.5)//61,137,189
		_TopColor("浅水色", Color) = (0.402343, 0.77343, 0.77343, 0.3)//103.198.198
		_EdgeColor("水边色", Color) = (1, 1, 1, 1)
		_DepthFactor("深浅变换调节", Range(0,1)) = 0.5
		
		

		_GSpeed ("海面速度", vector) = (1,1,0,0)
		_GFrequency("波浪大小",Range(0,100)) = 10
		_GHeight("波浪高度",Range(0,1)) = 0.5

		_SpecularTex("扰动纹理", 2D) = "white" {}
		_SpecularTexR_ST ("_SpecularTexR_ST", vector) = (20,20,1,1)
		_SpecularTexG_ST ("_SpecularTexG_ST", vector) = (20,20,0.5,-0.3)
		_SpecularTexB_ST ("_SpecularTexB_ST", vector) = (20,20,-0.7,-0.4)
		_SpecularPower("假高光强度",Range(0,100)) = 10
		_SpecularColor("高光色", Color) = (1,1,1,1)


		_WareTex ("波浪", 2D) = "white" {}
		_WareTex_ST ("_SpecularTexG_ST", vector) = (0.1,3.0,0,0.2)
		 
		[KeywordEnum(off, on )] _SIMPLE_WAVE("简单浪", Float) = 0

		[KeywordEnum(on, off )] _ANIMATION("顶点起伏开关", Float) = 0
	}

	SubShader
	{
        Tags
		{ 
			"Queue" = "Transparent"
		}

		 

		Pass
		{
            Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#define ENABLE_FOG_EX  1
            #include "UnityCG.cginc"
			#if ENABLE_FOG_EX
			#include "../Shader/height-fog.cginc"
			#endif
			#pragma vertex vert
			#pragma fragment frag

			#define _UNITY_DEPTH_ON 1
			//#pragma multi_compile _UNITY_DEPTH_OFF _UNITY_DEPTH_ON

			#pragma multi_compile _SIMPLE_WAVE_OFF _SIMPLE_WAVE_ON

			#pragma multi_compile _ANIMATION_ON _ANIMATION_OFF 
			
			
			
			// Properties
			float4 _Color;
			float4 _EdgeColor;
			float4 _TopColor;
			float  _DepthFactor;
 
	 
 #if _UNITY_DEPTH_ON
			sampler2D _CameraDepthTexture;
#else
			sampler2D _CustomDepth;
#endif
 
			

			sampler2D _WareTex;
 

			half4 _WareTex_ST;
			//half _WareTexSpeed;
 


			uniform half _GFrequency;
			uniform half4 _GSpeed;
			uniform half _GHeight;
			//float _EdgeWidth;
 
			sampler2D _SpecularTex;
			uniform float _SpecularExp;
			uniform float _SpecularPower;
			uniform half4 _SpecularColor;
			uniform half4 _SpecularTexR_ST;
			uniform half4 _SpecularTexG_ST;
			uniform half4 _SpecularTexB_ST;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texCoord : TEXCOORD1;
				float3 normal : NORMAL;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texCoord : TEXCOORD0;

				float4 screenPos : TEXCOORD1;
				#if _UNITY_DEPTH_ON
				
				#else
				float4 screenPos2 : TEXCOORD2;
				#endif

				float wareOffset : TEXCOORD3;
				float4 wpos: TEXCOORD4;
				#if ENABLE_FOG_EX
				UNITY_FOG_COORDS_EX(5)
				#else
				UNITY_FOG_COORDS(5)
				#endif
				
				float3 normalWorld : TEXCOORD6;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput o;

				float3 normalWorld = UnityObjectToWorldNormal(input.normal);

				float4 posWorld = mul(unity_ObjectToWorld, input.vertex);
				
				#if _ANIMATION_ON 
				float2 _p = _GFrequency * posWorld.xz + _Time.yy * _GSpeed.xy;	
				posWorld.y += sin(_p.x+_p.y)*_GHeight;
				#endif
				o.pos = mul(UNITY_MATRIX_VP, posWorld   );
				o.wpos = posWorld;
				o.wareOffset = (posWorld.x+posWorld.y)*_WareTex_ST.x +_Time.y*_WareTex_ST.w;
				o.screenPos = ComputeScreenPos(o.pos);

				#if _UNITY_DEPTH_ON
				
				#else
				o.screenPos2.xyz = o.pos.xyw;
				o.screenPos2.y *= _ProjectionParams.x;
				#endif


				#if ENABLE_FOG_EX
					UNITY_TRANSFER_FOG_EX(o, o.vertex, o.wpos, normalWorld);
				#else
					UNITY_TRANSFER_FOG(o, o.pos);
				#endif
				o.texCoord = input.texCoord;

				return o;
			}
			float unpackFloatFromVec4i(in float4 value) {
				  const float4 bitSh = float4(1.0/(256.0*256.0*256.0), 1.0/(256.0*256.0), 1.0/256.0, 1.0);
				  return(dot(value, bitSh));
				}
			float4 frag(vertexOutput input) : COLOR
			{


				half2 uv0 =    input.texCoord * _SpecularTexR_ST.xy  +   _Time.x *    _SpecularTexR_ST.zw;
				half colr = tex2D(_SpecularTex,uv0).r;

				half2 uv1 =    input.texCoord  * _SpecularTexG_ST.xy  +   _Time.x *    _SpecularTexG_ST.zw;
				half colg = tex2D(_SpecularTex,uv1).g;

				half2 uv2 =    input.texCoord  * _SpecularTexB_ST.xy  +   _Time.x *    _SpecularTexB_ST.zw;
				half colb = tex2D(_SpecularTex,uv2).b;
				half sp =  colr * colg * colb ;


 

				
				#if _UNITY_DEPTH_ON
				float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, input.screenPos);
	 
				#else
				float2 screenUV = (input.screenPos2.xy / input.screenPos2.z) * 0.5f + 0.5f;
				float4 cd = tex2D(_CustomDepth, screenUV);
		 
				//float4 depthSample = unpackFloatFromVec4i(cd);
				float4 depthSample = DecodeFloatRG(cd);
				//float4 depthSample = cd.r;
				#endif



				
				
				float depth = LinearEyeDepth(depthSample).r;
				float delta = depth - input.screenPos.w;
	 
				float w = delta*_WareTex_ST.y;
				#if _SIMPLE_WAVE_ON
				

				float t0 =   step(w,0.3);
				#else
				float t2 = w * step(w,1);
				float t0 = tex2Dlod(_WareTex,float4(input.wareOffset,t2,0,1)).r;
				#endif
				
			 
				
				float foamLine = 1 - saturate(_DepthFactor * delta);
			 
 
			    float4 waterColor = lerp (lerp(_Color , _TopColor,foamLine) ,_EdgeColor ,t0 );

				fixed4 col = lerp(waterColor,_SpecularColor*_SpecularPower,sp  );
				#if ENABLE_FOG_EX

				APPLY_HEIGHT_FOG(col,input.wpos,input.normalWorld,i.fogCoord);
				UNITY_APPLY_FOG_MOBILE(input.fogCoord, col);
				#else
				UNITY_APPLY_FOG(input.fogCoord, col);
				#endif
				
                return col;
			}

			ENDCG
		}
	}
}