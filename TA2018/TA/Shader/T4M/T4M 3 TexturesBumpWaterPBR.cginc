#include "UnityCG.cginc"
#include "../../Shader/FogCommon.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc" //第三步// 
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
	float4 tangent : TANGENT;
	//shadow mark
	UNITY_VERTEX_INPUT_INSTANCE_ID

};

struct v2f
{
	float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	float2 uv2 : TEXCOORD1;
#else
	UNITY_LIGHTING_COORDS(5, 6)
#endif

		float4 posWorld:TEXCOORD2;
	UBPA_FOG_COORDS(3)
		float3 normalDir : TEXCOORD4;
	float3 SH : TEXCOOR7;

	float3 tangentDir : TEXCOORD8;
	float3 bitangentDir : TEXCOORD9;
	float4 pos : SV_POSITION;
	//shadow mark
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

sampler2D _Control;
sampler2D _Splat0, _Splat1, _Splat2, _Splat3;
float4 _Splat0_ST, _Splat1_ST, _Splat2_ST, _Splat3_ST;
sampler2D _BumpSplat0, _BumpSplat1, _BumpSplat2, _BumpSplat3;

float4 _SpColor0, _SpColor1, _SpColor2, _SpecColor3;
uniform sampler2D _NormaLMap; uniform float4 _NormaLMap_ST;
#ifdef BRIGHTNESS_ON
fixed3 _Brightness;
#endif



half ArmBRDF(half roughness, half NdotH, half LdotH)
{
	half n4 = roughness * roughness*roughness*roughness;
	half c = NdotH * NdotH   *   (n4 - 1) + 1;
	half b = 4 * 3.14*       c*c  *     LdotH*LdotH     *(roughness + 0.5);
	return n4 / b;

}
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
	float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
	o.posWorld = posWorld;
	o.uv = v.uv;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	o.uv2 = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
	TRANSFER_VERTEX_TO_FRAGMENT(o);
#endif
	o.normalDir = UnityObjectToWorldNormal(v.normal);
	o.tangentDir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
	o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);

	o.SH = ShadeSH9(float4(o.normalDir, 1));
	UBPA_TRANSFER_FOG(o, v.vertex);
	return o;
}
float _Gloss0, _Gloss1, _Gloss2, _Gloss3, _GlossAB, _GlossCtrl;


uniform float4 _WaveSpeed;
uniform float _WaveScale;
uniform float _WaveNormalPower;
uniform float _GNormalPower;

float4 _TopColor;
float4	_ButtonColor;
float _Gloss;


float metallic_power;


inline float2 ToRadialCoords(float3 coords)
{
	float3 normalizedCoords = normalize(coords);
	float latitude = acos(normalizedCoords.y);
	float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
	float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
	return float2(0.5, 1.0) - sphereCoords;
}
fixed4 frag(v2f i) : SV_Target
{
	//shadow mark
	#if COMBINE_SHADOWMARK
			UNITY_SETUP_INSTANCE_ID(i);
	#endif

	half3 viewDir = normalize(UnityWorldSpaceViewDir(i.posWorld));
	float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
	float3 _NormaLMap_var0 = UnpackNormal(tex2D(_BumpSplat0, TRANSFORM_TEX(i.uv, _Splat0)));
	float3 _NormaLMap_var1 = UnpackNormal(tex2D(_BumpSplat1, TRANSFORM_TEX(i.uv, _Splat1)));
	float3 _NormaLMap_var2 = UnpackNormal(tex2D(_BumpSplat2, TRANSFORM_TEX(i.uv, _Splat2)));

	float3 normalDirection0 = normalize(mul(_NormaLMap_var0.rgb, tangentTransform));
	//return float4((normalDirection0 + 1)*0.5, 1);
	float3 normalDirection1 = normalize(mul(_NormaLMap_var1.rgb, tangentTransform));
	float3 normalDirection2 = normalize(mul(_NormaLMap_var2.rgb, tangentTransform));

	half4 temp = i.posWorld.xzxz * _WaveScale + _WaveSpeed * _WaveScale * _Time.y;
	temp.xy *= float2(.4, .45);

	half3 bump1 = UnpackNormal(tex2D(_BumpSplat3,  temp.xy)).rgb;
	half3 bump2 = UnpackNormal(tex2D(_BumpSplat3,  temp.zw)).rgb;
	half3 bump = (bump1 + bump2) * 0.5;

	float3 normalDirection3 = normalize(mul(bump.rgb, tangentTransform));
	//float3 normalDirection3 = normalize(mul(normalLocal3, tangentTransform));

	half3 waterNormal = normalize(lerp(i.normalDir, normalDirection3, _WaveNormalPower));

	half4 splat_control = tex2D(_Control, i.uv);//+ waterNormal *splat_control.a
	half3 col;


	half3 nor = normalDirection0 * splat_control.r + normalDirection1 * splat_control.g + normalDirection2 * splat_control.b;

	nor = nor + waterNormal * splat_control.a;


	float3 normalDirection = normalize(nor);

	half4 splat0 = tex2D(_Splat0, TRANSFORM_TEX(i.uv, _Splat0));
	half4 splat1 = tex2D(_Splat1, TRANSFORM_TEX(i.uv, _Splat1));
	half4 splat2 = tex2D(_Splat2, TRANSFORM_TEX(i.uv, _Splat2));

	//half4 splat3 = tex2D(_Splat3, TRANSFORM_TEX(i.uv, _Splat3));

	col = splat_control.r * splat0.rgb;

	col += splat_control.g * splat1.rgb;

	col += splat_control.b * splat2.rgb;

	#if _ISMETALLIC_OFF
	half3 waterColor = lerp(_TopColor, _ButtonColor, splat_control.a);

	#else
	half3 viewReflectDirection = reflect(-viewDir, waterNormal);
	half2 skyUV = half2(ToRadialCoords(viewReflectDirection));
	half4 splat3 = tex2D(_Splat3, skyUV);
	half3 waterColor = lerp(_TopColor, _ButtonColor, splat_control.a)* lerp(half3(1,1,1),splat3.rgb,metallic_power);
	#endif


	col += splat_control.a * waterColor;// splat2.rgb;

	//splat3
//shadow mark
#if ADD_PASS
		float3 lightDir = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz, _WorldSpaceLightPos0.w));
#else
		float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
#endif

		half4 c = half4(col.rgb,1);
		fixed3 lm = 1;
		half nl = saturate(dot(normalDirection, lightDir));
		//shadow mark
		#if ADD_PASS

				c.rgb = (_LightColor0 * nl * LIGHT_ATTENUATION(i)) * c.rgb;
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
				UNITY_LIGHT_ATTENUATION(attenuation, i, i.posWorld.xyz);
				//float attenuation = LIGHT_ATTENUATION(i);
				c.rgb = (i.SH + _LightColor0 * nl * attenuation) * c.rgb;
				#endif


				float _Gloss = splat0.a*_Gloss0 * splat_control.r + splat1.a*_Gloss1 * splat_control.g + splat2.a*_Gloss2 * splat_control.b + _Gloss3 * splat_control.a;



				float4 _SpColor = _SpColor0 * splat_control.r + _SpColor1 * splat_control.g + _SpColor2 * splat_control.b + _SpecColor3 * splat_control.a;
				half perceptualRoughness = 1.0 - _Gloss;
				half roughness = perceptualRoughness * perceptualRoughness;

				float3 halfDirection = normalize(viewDir + lightDir);
				float LdotH = saturate(dot(lightDir, halfDirection));
				float NdotH = saturate(dot(normalDirection, halfDirection));
				float specular = saturate(ArmBRDF(roughness, NdotH, LdotH));
				specular = saturate(specular);

				//return float4(attenuation, attenuation, attenuation, 1);
				c.rgb += _SpColor.rgb*specular*attenuation;
				#ifdef BRIGHTNESS_ON
				c.rgb = c.rgb * _Brightness * 2;
				#endif

				UBPA_APPLY_FOG(i, c);
				return c;
}
