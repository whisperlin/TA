fixed _SnowPower;
fixed _SnowNormalPower;
fixed4 _SnowColor;
fixed _SnowEdge;
sampler2D _SnowNoise;
half _SnowNoiseScale;
half _SnowGloss;
half _SnowLocalPower;
half _SnowMeltPower;
half HARD_SNOW;
half MELT_SNOW;

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
[MaterialToggle] HARD_SNOW("硬边雪", Float) = 0
[MaterialToggle] MELT_SNOW("消融雪", Float) = 0
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
#if SNOW_ENABLE 
	half snoize = 0;
	half snl = 0;
	if (MELT_SNOW > 0)
	{
		half snoize = tex2D(_SnowNoise, uv*_SnowNoiseScale).r;
		snl = snoize * _SnowMeltPower;
		t = smoothstep(_SnowPower, _SnowPower + _SnowEdge, snl);
		if (HARD_SNOW > 0)
		{
			t = step(snoize, t);
		}
	}
	else
	{
		snl = dot(normalDirection, half3(0, 1, 0));
		snl = (1.0 - _SnowLocalPower)*snl + _SnowLocalPower;
		t = smoothstep(_SnowPower, _SnowPower + _SnowEdge, snl);
		if (HARD_SNOW > 0)
		{
			half snoize = tex2D(_SnowNoise, uv*_SnowNoiseScale).r;
			t = step(snoize, t);
		}
	}
	normalDirection = lerp(VertexNormal.xyz, normalDirection, _SnowNormalPower);

#endif
}



void CmpSnowNormalAndPowerSurFace(in half2 uv, in float3 VertexNormal, out fixed t, inout float3 normalDirection, float3 tUp)//切线空间上方向
{
#if SNOW_ENABLE 
	half snoize = 0;
	half snl = 0;
	if (MELT_SNOW > 0)
	{
		half snoize = tex2D(_SnowNoise, uv*_SnowNoiseScale).r;
		snl = snoize * _SnowMeltPower;
		t = smoothstep(_SnowPower, _SnowPower + _SnowEdge, snl);
		if (HARD_SNOW > 0)
		{
			t = step(snoize, t);
		}
	}
	else
	{
		snl = dot(normalDirection, tUp);
		snl = (1.0 - _SnowLocalPower)*snl + _SnowLocalPower;
		t = smoothstep(_SnowPower, _SnowPower + _SnowEdge, snl);
		if (HARD_SNOW > 0)
		{
			half snoize = tex2D(_SnowNoise, uv*_SnowNoiseScale).r;
			t = step(snoize, t);
		}
	}
	normalDirection = lerp(half3(0, 0, 1), normalDirection, _SnowNormalPower);

#endif
}
 