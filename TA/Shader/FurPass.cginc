#include "UnityCG.cginc"
#include "height-fog.cginc"
#include "Lighting.cginc"
struct appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	float2 uv2 : TEXCOORD1;
#else
	float3 normal : NORMAL;
	float4 color : COLOR;
#endif
};

struct v2f
{
	float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	float2 uv2 : TEXCOORD1;

#endif
	float3 normalWorld : TEXCOORD4;
	float4 wpos:TEXCOORD2;
	UNITY_FOG_COORDS_EX(3)
	float4 vertex : SV_POSITION;
};

sampler2D _MainTex;

uniform float _FurLength;
uniform float _Cutoff;
//uniform float _CutoffEnd;
 

uniform fixed3 _Gravity;
uniform fixed _GravityStrength;

#ifdef BRIGHTNESS_ON
fixed3 _Brightness;
#endif

v2f vert (appdata v)
{
	v2f o;
	UNITY_INITIALIZE_OUTPUT(v2f, o);

	fixed3 direction = lerp(v.normal, _Gravity * _GravityStrength + v.normal * (1-_GravityStrength), FUR_MULTIPLIER);
	v.vertex.xyz += direction * _FurLength * FUR_MULTIPLIER * v.color.a;
	//o.vertex.xyz = 0;
	o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
	float4 wpos = mul(unity_ObjectToWorld, v.vertex); 
	o.wpos = wpos;
	o.uv = v.uv;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	o.uv2 = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
	o.normalWorld = UnityObjectToWorldNormal(v.normal);
#endif
	UNITY_TRANSFER_FOG_EX(o, o.vertex);
	return o;
}
			
fixed4 frag (v2f i) : SV_Target
{
	fixed4 c = tex2D(_MainTex, i.uv);

#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));
	c.rgb *= lm;
#else
	half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
	half nl = saturate(dot(i.normalWorld, lightDir));
	c.rgb = UNITY_LIGHTMODEL_AMBIENT * c.rgb + _LightColor0 * nl * c.rgb;
#endif

#ifdef BRIGHTNESS_ON
	c.rgb = c.rgb * _Brightness * 2;
#endif
	half3 viewDir = normalize(UnityWorldSpaceViewDir(i.wpos));
	c.a = step( lerp(1,_Cutoff,FUR_MULTIPLIER),c.a );

	#if DONT_CLIP

	#else
	clip(0.01-c.a);
	#endif
	

	
	APPLY_HEIGHT_FOG(c,i.wpos,i.normalWorld,i.fogCoord);
	UNITY_APPLY_FOG(i.fogCoord, c);



	return c;
}