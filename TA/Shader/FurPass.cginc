#include "UnityCG.cginc"
#include "height-fog.cginc"
#include "Lighting.cginc"
#include "SHGlobal.cginc"

#include "virtuallight.cginc"
#if _VIRTUAL_LIGHT_SHADOW2
#include "shadowmap.cginc"
#endif
struct appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	float2 uv2 : TEXCOORD1;
#else
	
	float4 color : COLOR;
#endif
	float3 normal : NORMAL;
};

struct v2f
{
	float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	float2 uv2 : TEXCOORD1;

#endif
	
	float4 wpos:TEXCOORD2;
	UNITY_FOG_COORDS_EX(3)
	float3 normalWorld : TEXCOORD4;
	fixed3 ambient: TEXCOORD5;

	#if _VIRTUAL_LIGHT_SHADOW2
		float4 shadowCoord : TEXCOORD6;
	#endif

	float4 vertex : SV_POSITION;
};

sampler2D _MainTex;

uniform float _FurLength;
uniform float _Cutoff;
//uniform float _CutoffEnd;
 

uniform fixed4 _Gravity;
uniform fixed4 _Extend;
uniform fixed _GravityStrength;
uniform half _AmbientPower;


 

#ifdef BRIGHTNESS_ON
fixed3 _Brightness;
#endif

v2f vert (appdata v)
{
	v2f o;
	UNITY_INITIALIZE_OUTPUT(v2f, o);

	fixed3 _g = (_Gravity +v.normal*_Extend)* _GravityStrength + v.normal * (1-_GravityStrength);
	fixed3 direction = lerp(v.normal,_g , FUR_MULTIPLIER);
	v.vertex.xyz += direction * _FurLength * FUR_MULTIPLIER * v.color.a;

 
	
	//o.vertex.xyz = 0;
	o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
	float4 wpos = mul(unity_ObjectToWorld, v.vertex); 
	o.wpos = wpos;
	o.uv = v.uv;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	o.uv2 = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
	
#endif
	o.normalWorld = UnityObjectToWorldNormal(v.normal);
#if GLOBAL_SH9
	o.ambient = g_sh(half4(o.normalWorld, 1))  ;
#else
	o.ambient = UNITY_LIGHTMODEL_AMBIENT   ;
#endif

	UNITY_TRANSFER_FOG_EX(o, o.vertex, o.wpos,o.normalWorld);


#if _VIRTUAL_LIGHT_SHADOW2
		o.shadowCoord = mul(_depthVPBias, mul(unity_ObjectToWorld, v.vertex));
		o.shadowCoord.z = -(mul(_depthV, mul(unity_ObjectToWorld, v.vertex)).z * _farplaneScale);
#endif
	return o;
}
			
fixed4 frag (v2f i) : SV_Target
{
	fixed4 c = tex2D(_MainTex, i.uv);

#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));
	c.rgb *= lm;
#else

	#if _VIRTUAL_LIGHT_ON
			half3 lightDir = normalize(VirtualDirectLight0.xyz);
			 

	#else
			half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

	#endif
	
	#if _VIRTUAL_LIGHT_ON
		fixed3 lightColor = VirtualDirectLightColor0.rgb*VirtualDirectLightColor0.a;
	#else
			fixed3 lightColor = _LightColor0;
	#endif
	
	#if _VIRTUAL_LIGHT_SHADOW2
	half attenuation = PCF4Samples(i.shadowCoord);
	lightColor.rgb *= attenuation;
	#endif

	half nl = saturate(dot(i.normalWorld, lightDir));
	c.rgb = UNITY_LIGHTMODEL_AMBIENT * c.rgb + lightColor * nl * c.rgb;
#endif

#ifdef BRIGHTNESS_ON
	c.rgb = c.rgb * _Brightness * 2;
#endif
	c.rgb += c.rgb * i.ambient * _AmbientPower;
	half3 viewDir = normalize(UnityWorldSpaceViewDir(i.wpos));
	c.a = step( lerp(1,_Cutoff,FUR_MULTIPLIER),c.a );

	
	#if DONT_CLIP

	#else
	clip(0.01-c.a);
	#endif
	

	
	APPLY_HEIGHT_FOG(c,i.wpos,i.normalWorld,i.fogCoord);
	UNITY_APPLY_FOG_MOBILE(i.fogCoord, c);



	return c;
}