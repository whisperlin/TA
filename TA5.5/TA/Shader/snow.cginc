fixed _SnowPower;
fixed _SnowNormalPower;
fixed4 _SnowColor;
fixed _SnowEdge;
sampler2D _SnowNoise;
half _SnowNoiseScale;
half _SnowGloss;
half _SnowLocalPower;
half _SnowMeltPower;


/*
[Toggle]_snow_options("----------雪选项-----------",int) = 0
_SnowNormalPower("  雪法线强度", Range(0.3, 1)) = 1
//_SnowColor("雪颜色", Color) = (0.784, 0.843, 1, 1)
_SnowEdge("  雪边缘过渡", Range(0.01, 0.3)) = 0.2
//_SnowNoise("雪噪点", 2D) = "white" {}
_SnowNoiseScale("  雪噪点缩放", Range(0.1, 20)) = 1.28
//_SnowGloss("雪高光", Range(0, 1)) = 1
//_SnowMeltPower("  雪_消融影响调节", Range(1, 2)) =  1
_SnowLocalPower("  雪_法线影响调节", Range(-5, 0.3)) = 0
[Toggle(HARD_SNOW)] HARD_SNOW("  硬边雪", Float) = 0
[Toggle(MELT_SNOW)] MELT_SNOW("  消融雪", Float) = 0
//[KeywordEnum(ON, OFF)] _IsWeather("是否接收天气", Float) = 0
*/
/*
#if _ISWEATHER_ON

	#if SNOW_ENABLE 
		fixed nt;
		CmpSnowNormalAndPower(i.uv0, i.normalDir.xyz, nt, normalDirection);
	#endif
	#endif
*/
/*
#if _ISWEATHER_ON
	#if SNOW_ENABLE
		diffuseColor.rgb = lerp(diffuseColor.rgb, _SnowColor.rgb, nt *_SnowColor.a);
	#endif
#endif
*/

/*
#if _ISWEATHER_ON
	#if RAIN_ENABLE
		gloss = saturate(gloss* get_smoothnessRate());
	#endif
	#if(SNOW_ENABLE)
		gloss = lerp(gloss, _SnowGloss, nt);
	#endif
#endif
*/
void CmpSnowNormalAndPower(in half2 uv,in float3 VertexNormal,out fixed t, inout float3 normalDirection)
{
#if   defined(HARD_SNOW) || defined(MELT_SNOW) 

	half snoize = tex2D(_SnowNoise, uv*_SnowNoiseScale).r;

#endif
#if MELT_SNOW
	half snl = snoize * _SnowMeltPower;

#else
	half snl = dot(normalDirection, half3(0, 1, 0));
	snl = (1.0 - _SnowLocalPower)*snl + _SnowLocalPower;
#endif

	t = smoothstep(_SnowPower, _SnowPower + _SnowEdge, snl);


#if HARD_SNOW
	t = step(snoize, t);
#endif

 
	normalDirection = lerp(VertexNormal.xyz, normalDirection, _SnowNormalPower);
}