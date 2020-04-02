//
#include "UnityCG.cginc"
#include "../FogCommon.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"  
#include "../shadowmarkex.cginc"
struct appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	float2 uv2 : TEXCOORD1;
#else

#endif

	float3 normal : NORMAL;
	//shadow mark
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
	float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	float2 uv2 : TEXCOORD1;
#else
	LIGHTING_COORDS(5, 6)
#endif

		float4 wpos:TEXCOORD2;
	UBPA_FOG_COORDS(3)
		float3 normalWorld : TEXCOORD4;

	float4 pos : SV_POSITION;

	//shadow mark
	UNITY_VERTEX_INPUT_INSTANCE_ID
		float3 posWorld : TEXCOOR8;
	float3 SH : TEXCOOR7;
};

sampler2D _Control, _Control2;
sampler2D _Splat0, _Splat1, _Splat2, _Splat3, _Splat4, _Splat5;
float4 _Splat0_ST, _Splat1_ST, _Splat2_ST, _Splat3_ST, _Splat4_ST, _Splat5_ST, _Control_ST, _Control2_ST;
float4 _Tiling3, _Tiling4, _Tiling5;
#ifdef BRIGHTNESS_ON
fixed3 _Brightness;
#endif

v2f vert(appdata v)
{
	v2f o;
	UNITY_INITIALIZE_OUTPUT(v2f, o);

	//shadow mark
#if COMBINE_SHADOWMARK
	UNITY_SETUP_INSTANCE_ID(v);
	UNITY_TRANSFER_INSTANCE_ID(v, o);
#endif
	o.pos = UnityObjectToClipPos(v.vertex);
	float4 wpos = mul(unity_ObjectToWorld, v.vertex);
	o.wpos = wpos;
	o.uv = v.uv;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	o.uv2 = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
	TRANSFER_VERTEX_TO_FRAGMENT(o);
#endif
	o.normalWorld = UnityObjectToWorldNormal(v.normal);

	//shadow mark
	float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
	o.posWorld = posWorld;
	o.SH = ShadeSH9(float4(o.normalWorld, 1));

	UBPA_TRANSFER_FOG(o, v.vertex);
	return o;
}

fixed4 frag(v2f i) : SV_Target
{
	//shadow mark
#if COMBINE_SHADOWMARK
		UNITY_SETUP_INSTANCE_ID(i);
#endif
	half2 uvctrl = TRANSFORM_TEX(i.uv, _Control);
	half4 splat_control = tex2D(_Control, uvctrl).rgba;
	half3 splat_control2 = tex2D(_Control2, TRANSFORM_TEX(i.uv, _Control2));
	half3 col;
	half3 col2;
	half3 splat0 = tex2D(_Splat0, TRANSFORM_TEX(i.uv, _Splat0)).rgb;
	half3 splat1 = tex2D(_Splat1, TRANSFORM_TEX(i.uv, _Splat1)).rgb;
	half3 splat2 = tex2D(_Splat2, TRANSFORM_TEX(i.uv, _Splat2)).rgb;
	half3 splat3 = tex2D(_Splat3, uvctrl*_Tiling3.xy).rgb;
	half3 splat4 = tex2D(_Splat4, uvctrl*_Tiling4.xy).rgb;
	half3 splat5 = tex2D(_Splat5, uvctrl*_Tiling5.xy).rgb;

	col = splat_control.r * splat0.rgb;

	col += splat_control.g * splat1.rgb;

	col += splat_control.b * splat2.rgb;

	col += splat_control.a * splat3.rgb;

	col += splat_control2.r * splat4.rgb;

	col += splat_control2.g * splat5.rgb;



	//shadow mark
#if ADD_PASS
	float3 lightDir = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz, _WorldSpaceLightPos0.w));
#else
	float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
#endif
	half4 c = half4(col.rgb, 1);
	fixed3 lm = 1;
	//shadow mark
	half nl = saturate(dot(i.normalWorld, lightDir));
#if ADD_PASS

	c.rgb = (_LightColor0 * nl) * c.rgb;

	return c;
#endif

	//shadow mark
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)

	GETLIGHTMAP(i.uv2);
	lightmap.rgb *= LightMapInf.rgb *(1 + LightMapInf.a);//
	#if    SHADOWS_SHADOWMASK 
		c.rgb = (/*i.SH +*/ _LightColor0 * nl * attenuation + lightmap.rgb) * c.rgb;

	#else
		c.rgb *= lightmap;

	#endif

 
#else

	float attenuation = LIGHT_ATTENUATION(i);

	c.rgb = (i.SH + _LightColor0 * nl * attenuation) * c.rgb;

#endif

#ifdef BRIGHTNESS_ON
	c.rgb = c.rgb * _Brightness * 2;
#endif




	UBPA_APPLY_FOG(i, c);
	return c;
}