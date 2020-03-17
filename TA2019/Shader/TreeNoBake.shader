 

Shader "TA/Scene/Tree Not bake"
{
	Properties
	{
		_MainTex ("主贴图", 2D) = "white" {}
		_Color("颜色",Color) = (1,1,1,1)
		_AlphaCut("半透明剔除",Range(0,1))=0.2
		_Wind("风向",Vector) = (1,0.5,0,0)
		_Speed("速度",Range(0,5)) = 2
		_Ctrl("空间各向差异",Range(0,3.14)) = 0
		_NdotLPower("NLP",Range(0,1)) = 1
		[Toggle(_DOUBLE_NL)] _DOUBLE_NL("双面同亮度", Float) = 0
		



		[KeywordEnum(Off,On)] _fadePhy("是否开启碰撞交互", Float) = 0
	}

		SubShader
		{
			Tags{ "Queue" = "AlphaTest+40" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
			Cull  Off
			Pass
			{
				Tags{ "LightMode" = "ForwardBase" }


				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase

				#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

				//#pragma   multi_compile  _  FOG_LIGHT
				#pragma   multi_compile  _  GLOBAL_SH9
				#pragma multi_compile _FADEPHY_OFF _FADEPHY_ON
				#pragma multi_compile __ GLOBAL_SH9
			#pragma   multi_compile  _ _DOUBLE_NL
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "FogCommon.cginc"
				#include "grass.cginc"

				float _NdotLPower;
				float4 LightMapInf;
			fixed4 frag (v2f i) : SV_Target
			{
				 
				fixed4 c = tex2Dlod(_MainTex, float4(i.uv,0,0));
				c.rgb *= _Color.rgb;
				
				//fixed4 e = tex2D(_EmissionTex, i.uv);
				half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				//half nl = saturate(dot(i.normalWorld, lightDir)) + saturate(dot(i.normalWorld, -lightDir)) ;
#if _DOUBLE_NL
				half nl = abs(dot(i.normalWorld, lightDir));
#else
				//_NdotLPower
				half nl = saturate( dot(i.normalWorld, lightDir) - (1-_NdotLPower) ) / _NdotLPower; 
				//half nl = saturate( dot(i.normalWorld, lightDir) ); 
#endif
				clip(c.a - _AlphaCut);
				
	 
				c.rgb = (i.SH + _LightColor0 * nl /*+ _Emission*e.b*/) * c.rgb;
				
				//return i.color;
				clip(c.a - _AlphaCut);
				UBPA_APPLY_FOG(i, c);
				return c;
			}
			ENDCG
		}
	}
}