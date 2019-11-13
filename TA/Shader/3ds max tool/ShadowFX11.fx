/*********************************************************************NVMH3****
$Revision$

Copyright NVIDIA Corporation 2007
TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THIS SOFTWARE IS PROVIDED
*AS IS* AND NVIDIA AND ITS SUPPLIERS DISCLAIM ALL WARRANTIES, EITHER EXPRESS
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL NVIDIA OR ITS SUPPLIERS
BE LIABLE FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS PROFITS,
BUSINESS INTERRUPTION, LOSS OF BUSINESS INFORMATION, OR ANY OTHER PECUNIARY
LOSS) ARISING OUT OF THE USE OF OR INABILITY TO USE THIS SOFTWARE, EVEN IF
NVIDIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.


To learn more about shading, shaders, and to bounce ideas off other shader
    authors and users, visit the NVIDIA Shader Library Forums at:

    http://developer.nvidia.com/forums/

******************************************************************************/
string ParamID = "0x003";

float Script : STANDARDSGLOBAL <
    string UIWidget = "none";
    string ScriptClass = "object";
    string ScriptOrder = "standard";
    string ScriptOutput = "color";
    string Script = "Technique=Main;";
> = 0.8;

//// UN-TWEAKABLES - AUTOMATICALLY-TRACKED TRANSFORMS ////////////////

float4x4 WorldITXf : WorldInverseTranspose < string UIWidget="None"; >;
float4x4 WvpXf : WorldViewProjection < string UIWidget="None"; >;
float4x4 WorldXf : World < string UIWidget="None"; >;
float4x4 ViewIXf : ViewInverse < string UIWidget="None"; >;

#ifdef _MAX_
int texcoord1 : Texcoord
<
	int Texcoord = 1;
	int MapChannel = 0;
	string UIWidget = "None";
>;

int texcoord2 : Texcoord
<
	int Texcoord = 2;
	int MapChannel = -2;
	string UIWidget = "None";
>;

int texcoord3 : Texcoord
<
	int Texcoord = 3;
	int MapChannel = -1;
	string UIWidget = "None";
>;
#endif

//// TWEAKABLE PARAMETERS ////////////////////

/// Point Lamp 0 ////////////
float3 Lamp0Pos : POSITION <
    string Object = "PointLight0";
    string UIName =  "Light Position";
    string Space = "World";
	int refID = 0;
> = {-0.5f,2.0f,1.25f};
#ifdef _MAX_
float3 Lamp0Color : LIGHTCOLOR
<
	int LightRef = 0;
	string UIWidget = "None";
> = float3(1.0f, 1.0f, 1.0f);
#else
float3 Lamp0Color : Specular <
    string UIName =  "Lamp 0";
    string Object = "Pointlight0";
    string UIWidget = "Color";
> = {1.0f,1.0f,1.0f};
#endif


float _ShadowFeather<
	string UIName = "Shadow Facter";
	string UIWidget = "slider";
	float UIMin = 0.0f;
	float UIMax = 1.0f;	
>  = 0.51f;
float4 _LightSpecColor  <
	string UIName = "_LightSpecColor";
	string UIWidget = "Color";
> = float4(1,1,1,1);    // diffuse
float4 _LightAreaMultColor  <
	string UIName = "_LightAreaMultColor";
	string UIWidget = "Color";
> = float4(0.70616f,0.67565f,0.816f,1.0f);    // diffuse
float4 _SecondShadowMultColor  <
	string UIName = "_SecondShadowMultColor";
	string UIWidget = "Color";
> = float4(0.62292f,0.53019f,0.645f,1.0f);    // diffuse
 
 
		

float4 k_d  <
	string UIName = "ShadowColor";
	string UIWidget = "Color";
> = float4( 0.47f, 0.47f, 0.47f, 1.0f );    // diffuse
 
//////// COLOR & TEXTURE /////////////////////
 
 
Texture2D <float4> _MainTex : DiffuseMap< 
	string UIName = "MainTex";
	string ResourceType = "2D";
	int Texcoord = 0;
	int MapChannel = 1;
>;

Texture2D <float4> _LightMapTex < 
	string UIName = "_LightMapTex";
	string ResourceType = "2D";
	int Texcoord = 0;
	int MapChannel = 2;
>;
float _SpecMulti<
	string UIName = "Spec Multi";
	string UIWidget = "slider";
	float UIMin = 0.0f;
	float UIMax = 1.0f;	
>  = 1.0f;
 
float _Shininess<
	string UIName = "Shininess";
	string UIWidget = "slider";
	float UIMin = 0.0f;
	float UIMax = 100.0f;	
>  = 10.0f;
 

SamplerState g_LinearWrapSampler
{
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Wrap;
    AddressV = Wrap;
};

 
/* data from application vertex buffer */
struct appdata {
	float4 Position		: POSITION;
	float3 Normal		: NORMAL;
	float3 Tangent		: TANGENT;
	float3 Binormal		: BINORMAL;
	float2 UV0		: TEXCOORD0;	
	float3 Colour		: TEXCOORD1;
	float3 Alpha		: TEXCOORD2;
	float3 Illum		: TEXCOORD3;
	float3 UV1		: TEXCOORD4;
	float3 UV2		: TEXCOORD5;
	float3 UV3		: TEXCOORD6;
	float3 UV4		: TEXCOORD7;
};

/* data passed from vertex shader to pixel shader */
struct vertexOutput {
    float4 HPosition	: SV_Position;
    float4 UV0		: TEXCOORD0;
    // The following values are passed in "World" coordinates since
    //   it tends to be the most flexible and easy for handling
    //   reflections, sky lighting, and other "global" effects.
    float3 LightVec	: TEXCOORD1;
    float3 WorldNormal	: TEXCOORD2;
    float3 WorldTangent	: TEXCOORD3;
    float3 WorldBinormal : TEXCOORD4;
    float3 WorldView	: TEXCOORD5;
	float4 UV1		: TEXCOORD6;
	float4 UV2		: TEXCOORD7;
	float4 wPos		: TEXCOORD8;
};
 
///////// VERTEX SHADING /////////////////////

/*********** Generic Vertex Shader ******/

vertexOutput std_VS(appdata IN) {
    vertexOutput OUT = (vertexOutput)0;
    OUT.WorldNormal = mul(IN.Normal,WorldITXf).xyz;
    OUT.WorldTangent = mul(IN.Tangent,WorldITXf).xyz;
    OUT.WorldBinormal = mul(IN.Binormal,WorldITXf).xyz;
    float4 Po = float4(IN.Position.xyz,1);
    float3 Pw = mul(Po,WorldXf).xyz;
    OUT.LightVec = (Lamp0Pos - Pw);
    OUT.WorldView = normalize(ViewIXf[3].xyz - Pw);
    OUT.HPosition = mul(Po,WvpXf);
	OUT.wPos = mul(IN.Position, WorldXf);
	
// UV bindings
// Encode the color data
 	float4 colour;
   	colour.rgb = IN.Colour * IN.Illum;
   	colour.a = IN.Alpha.x;
   	OUT.UV0.z = colour.r;
   	OUT.UV0.a = colour.g;
  	OUT.UV1.z = colour.b;
   	OUT.UV1.a = colour.a;

// Pass through the UVs
	OUT.UV0.xy = IN.UV0.xy;
   	OUT.UV1.xy = IN.UV1.xy;
   	OUT.UV2.xyz = IN.UV2.xyz;
// 	OUT.UV3 = OUT.UV3;
// 	OUT.UV4 = OUT.UV4;
    return OUT;
}

///////// PIXEL SHADING //////////////////////

// Utility function for phong shading

 
float4 std_PS(vertexOutput IN) : SV_Target {

 
    float3 diffContrib;
    float3 specContrib;
    float3 Ln = normalize(IN.LightVec);
    float3 Vn = normalize(IN.WorldView);
    float3 Nn = normalize(IN.WorldNormal);
    float3 Tn = normalize(IN.WorldTangent);
    float3 Bn = normalize(IN.WorldBinormal);
	float4 vertColour = float4(IN.UV0.z,IN.UV0.w,IN.UV1.z,IN.UV1.w);	
	// Ln = normalize(float3(-0.12705,-0.6301,0.76605));
	Nn = normalize(Nn);
	float hlambert = dot(Nn, normalize(Ln)) * 0.4975 + 0.5;
	
	float4 r = _MainTex.Sample(g_LinearWrapSampler, IN.UV0.xy);
	float4 tex_Light_Color = _LightMapTex.Sample(g_LinearWrapSampler, IN.UV0.xy);
	//return tex_Light_Color;
	//fixed4  tex_Light_Color = _LightMapTex.Sample(g_LinearWrapSampler, IN.UV0.xy);
	//float4 r = tex2D(_MainTex, IN.UV0) 
	float4  diffuse = float4(1.0, 1.0, 1.0, 1);
	hlambert = (hlambert + tex_Light_Color.g)*0.5;
	
	float  _diffusemask =   tex_Light_Color.a;
	if (_diffusemask > 0.1)
	{
		if(hlambert>_ShadowFeather)
		{
			diffuse.xyz = r;
		}
		else
		{
			diffuse.xyz = r.xyz*_LightAreaMultColor.xyz;
		}
		 
	}
	else
	{
		if (hlambert > _ShadowFeather)
		{
			diffuse.xyz = r.xyz;
		}
		else
		{
			diffuse.xyz = r.xyz*_SecondShadowMultColor.xyz;
		}
	}
	 
	float3 halfView = normalize(Ln + Vn);
	half shinepow = pow(max(dot(Nn, halfView), 0.0), _Shininess);

	float3 specColor;
	if (shinepow >= (1.0 - tex_Light_Color.b)) {
		specColor = _LightSpecColor * _SpecMulti * tex_Light_Color.r;
	}
	else {
		specColor = float3(0.0, 0.0, 0.0);
	};
	
	diffuse.rgb = diffuse.rgb + diffuse.rgb*specColor;
	//diffuse.rgb = diffuse.rgb * _Color.rgb;

 
	return  diffuse;
	 
	
	 
}

///// TECHNIQUES /////////////////////////////

technique11 Main_11 <
	string Script = "Pass=p0;";
> {
	pass p0 <
	string Script = "Draw=geometry;";
    > 
    {
        SetVertexShader(CompileShader(vs_5_0,std_VS()));
        SetGeometryShader( NULL );
		SetPixelShader(CompileShader(ps_5_0,std_PS()));
    }
}

technique10 Main_10 <
	string Script = "Pass=p0;";
> {
	pass p0 <
	string Script = "Draw=geometry;";
    > 
    {
        SetVertexShader(CompileShader(vs_4_0,std_VS()));
        SetGeometryShader( NULL );
		SetPixelShader(CompileShader(ps_4_0,std_PS()));
    }
}

/////////////////////////////////////// eof //
