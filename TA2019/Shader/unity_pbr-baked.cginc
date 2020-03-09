//_BakedingDifPower("烘培间接光照强度", Range(0, 1)) = 0.8
//_BakedingMatePower("烘培金属间接光照强度", Range(0, 1)) = 0.5

uniform float4 _Color;
uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
uniform float _MetallicPower;
uniform float _GlossPower;
uniform sampler2D _Metallic; uniform float4 _Metallic_ST;
//uniform float _BakedingDifPower;
//uniform float _BakedingMatePower;


struct VertexInput {
	float4 vertex : POSITION;
	float2 texcoord0 : TEXCOORD0;
	float2 texcoord1 : TEXCOORD1;
	float2 texcoord2 : TEXCOORD2;
};
struct VertexOutput {
	float4 pos : SV_POSITION;
	float2 uv0 : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
	float2 uv2 : TEXCOORD2;
	float4 posWorld : TEXCOORD3;
};
VertexOutput vert(VertexInput v) {
	VertexOutput o = (VertexOutput)0;
	o.uv0 = v.texcoord0;
	o.uv1 = v.texcoord1;
	o.uv2 = v.texcoord2;
	o.posWorld = mul(unity_ObjectToWorld, v.vertex);
	o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST);
	return o;
}
float4 frag(VertexOutput i) : SV_Target{
	float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
	UnityMetaInput o;
	UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);

	float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
	float3 diffColor = (_MainTex_var.rgb*_Color.rgb);
	float4 _Metallic_var = tex2D(_Metallic,TRANSFORM_TEX(i.uv0, _Metallic));
	o.Emission = (diffColor*_Metallic_var.r)/*_BakedingMatePower*/;

	float specularMonochrome;
	float3 specColor;
	diffColor = DiffuseAndSpecularFromMetallic(diffColor, (_Metallic_var.r*_MetallicPower), specColor, specularMonochrome);
	o.Albedo = diffColor /** _BakedingDifPower*/;

	return UnityMetaFragment(o);
}
