


#define M4T_UV(index)\
half2 uv#index =  TRANSFORM_TEX(i.uv, _Splat##index);

 

#define T4M_UVCMD(uv,index)\
uv.x = frac(uv.x);\
uv.x = _PixInU + uv.x*deltaLen + deltaLen0 * index;


#define T4M_UV_CMD(index)\
half2 uv##index = TRANSFORM_TEX(i.uv, _Splat##index);\
uv##index.x = frac(uv##index.x);\
uv##index.x = _PixInU + uv##index.x*deltaLen + deltaLen0 * index;\

#define T4M_NORMAL_TEXTURE_CMD(index)\
float3 _NormaLMap_var##index = UnpackNormal(tex2D(_BumpSplat,uv##index ));\
float3 normalDirection##index = normalize(mul(_NormaLMap_var##index.rgb, tangentTransform));


#define T4M_NORMAL_TEXTURE(index)\
float3 _NormaLMap_var##index = UnpackNormal(tex2D(_BumpSplat##index, TRANSFORM_TEX(i.uv, _Splat##index)));\
float3 normalDirection##index = normalize(mul(_NormaLMap_var##index.rgb, tangentTransform));




#define T4M_TEXTURE(index)\
half4 splat##index = tex2D(_Splat##index, TRANSFORM_TEX(i.uv, _Splat##index));


#define T4M_TEXTURE_CMD(index)\
half4 splat##index = tex2D(_Splat, uv##index);

#define T4M_WATER_NORMAL(index)\
half4 temp = i.posWorld.xzxz * _WaveScale + _WaveSpeed * _WaveScale * _Time.y;\
temp.xy *= float2(.4, .45);\
half3 bump1 = UnpackNormal(tex2D(_BumpSplat##index, temp.xy)).rgb;\
half3 bump2 = UnpackNormal(tex2D(_BumpSplat##index, temp.zw)).rgb;\
half3 bump = (bump1 + bump2) * 0.5;\
float3 normalDirection##index =  mul(bump.rgb, tangentTransform) ;\
half3 waterNormal = normalize(lerp(i.normalDir, normalDirection##index, _WaveNormalPower));


#define T4M_WATER_NORMAL_CMB(index)\
half4 temp = i.posWorld.xzxz * _WaveScale + _WaveSpeed * _WaveScale * _Time.y;\
temp.xy *= float2(.4, .45);\
temp.x = frac(temp.x);\
temp.x = _PixInU + temp.x*deltaLen + deltaLen0 * index;\
temp.z = frac(temp.z);\
temp.z = _PixInU + temp.z*deltaLen + deltaLen0 * index;\
half3 bump1 = UnpackNormal(tex2D(_BumpSplat, temp.xy)).rgb;\
half3 bump2 = UnpackNormal(tex2D(_BumpSplat, temp.zw)).rgb;\
half3 bump = (bump1 + bump2) * 0.5;\
float3 normalDirection##index = normalize(mul(bump.rgb, tangentTransform));\
half3 waterNormal = normalize(lerp(i.normalDir, normalDirection##index, _WaveNormalPower));


#define T4M_WATER_COLOR(index,chan)\
half3 viewReflectDirection = reflect(-viewDir, waterNormal);\
half2 skyUV = half2(ToRadialCoords(viewReflectDirection));\
half4 splat##index = tex2D(_Splat##index, skyUV);\
half3 waterColor = lerp(_TopColor, _ButtonColor, splat_control2.##chan)* lerp(half3(1, 1, 1), splat##index.rgb, metallic_power);


#define T4M_WATER_COLOR_CMD6(index,chan)\
half3 viewReflectDirection = reflect(-viewDir, waterNormal);\
half2 skyUV = half2(ToRadialCoords(viewReflectDirection));\
skyUV.x = frac(skyUV.x);\
skyUV.x = _PixInU + skyUV.x*deltaLen + deltaLen0 * index;\
half4 splat##index = tex2D(_Splat, skyUV);\
half3 waterColor = lerp(_TopColor, _ButtonColor, splat_control2.##chan)* lerp(half3(1, 1, 1), splat##index.rgb, metallic_power);
 