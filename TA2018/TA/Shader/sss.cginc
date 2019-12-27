



half sss_scatter0;
half _SSSDif;
fixed4 _BackColor;
/*inline half3 calc_transmission_sss_base(half NdotLsat, half NdotL, half sss_warp0, half sss_scatter0, half cvSSS)
	{
		half NdotL2 = saturate((NdotL + sss_warp0) / (1.0 + sss_warp0));
		//half NdotL2 = lerp(sss_warp0, 1, NdotLsat);
		half NdotL3 = smoothstep(0.0f, sss_scatter0 + 0.001, NdotL2) * lerp(sss_scatter0 * 2.0f, sss_scatter0, NdotL2);
		half3 color0 =  lerp(_SSSDif,1, NdotLsat)  ;
		half3 color1 = (_BackColor.xyz * NdotL3) + NdotL2;
		return lerp(color0, color1, cvSSS + 0.001);
	}*/
//这个是网易的算法实现sss精简版.
inline half3 calc_transmission_sss(half NdotLsat, half NdotL, half BackNdotL, half sss_warp0, half sss_scatter0, half cvSSS)
{
	half NdotL2 = saturate((BackNdotL + sss_warp0) / (1.0 + sss_warp0));
	half NdotL3 = smoothstep(0.0f, sss_scatter0 + 0.001, NdotL2) * lerp(sss_scatter0 * 2.0f, sss_scatter0, NdotL2);
	half3 color0 = lerp(_SSSDif, 1, NdotLsat);
	half3 color1 = (_BackColor.xyz * NdotL3) + color0;
	return lerp(color0, color1, cvSSS + 0.001);
}
float _S3SPower;
sampler2D _BRDFTex;
inline half3 sss_from_lut(float nl, float3 worldNormal,float3 worldPos ,float3 lightColor)
{
	float deltaWorldNormal = length(fwidth(worldNormal));
	float deltaWorldPosition = length(fwidth(worldPos));
	float Curvature = saturate(deltaWorldNormal / deltaWorldPosition) *  0.005;
	float2 brdfUV;
	float NdotLBlur = nl;
	brdfUV.x = NdotLBlur * 0.5 + 0.5;
	brdfUV.y = Curvature * dot(lightColor.rgb, fixed3(0.22, 0.707, 0.071));
	half3 brdf = tex2D(_BRDFTex, brdfUV).rgb;
	return brdf;
}

