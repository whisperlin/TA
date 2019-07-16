using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SetGlobalSH9 : MonoBehaviour {

    public SH9Data data;
    SH9Data curData;

   

    [Header("角色虚拟光颜色")]
    public Color virtualDirectLightColor0 = Color.white;
    [Header("虚拟光强度")]
    [Range(0, 3)]
    public float virtualDirectLightColor0Intensity = 1.0f;

    [Header("角色虚拟光方向")]
    public Vector3 VirtualDirectLight0;

    [Header("场景漫反射差")]
    [Range(0f,1f)]
    public float _DifSC = 0.0f;

    [Header("场景背光")]
    public Color _BackColor = Color.black;

    [Header("场景背光强度")]
    [Range(0f,1f)]
    public float sss_scatter0 = 0.0f;

    [Header("高光剔除")]
    [Range(-0.1f, 0.6f)]
    public float _CullSepe = 0.0f;

    [Header("高度雾")]
    public bool heightFog = true;

    [Header("高度雾地平线")]
    public float heightFogHeight = 0;

    [Header("高度雾顶部")]
    public float heightFogHeight2 = 10;
    [Range(0.1f,1f)]
    [Header("高度过渡")]
    public float fog_height_power = 0.4f;
    [Header("远景变色")]
    public bool enable_env = true;
    [Header("反射环境色")]
    public SH9Data farEvn;
    [Range(0f,0.9f)]
    [Header("反射环境色向下偏移")]
    public float globalEnvOffset = 0.5f;
    SH9Data curFarEnv;
    [Header("远景色")]
    public Color farSceneColor = new Color(1,1,1,1);
    [Range(0.001f, 0.02f)]
    [Header("远景过渡")]
    public float density = 0.01f;

    [Range(0.001f, 0.02f)]
    [Header("高度过渡")]
    public float densityH = 0.01f;

    //[Range(0.001f, 0.02f)]
    //[Header("雾色过渡")]
    //public float color_density = 0.01f;

    

    // Use this for initialization
    void Start () {
        curData = null;
        curFarEnv = null;
        setSH9Global();
    }
	// Update is called once per frame
	void Update () {
        setSH9Global();
    }
    private void setSH9Global()
    {
        //VirtualDirectLight0
        if (data != null && curData != data )
        {
            curData = data;
            for (int i = 0; i < 9; ++i)
            {
                string param = "g_sph" + i.ToString();
                Shader.SetGlobalVector(param, data.coefficients[i]);
            }
        }
        if (farEvn != null && curFarEnv != farEvn)
        {
            curFarEnv = farEvn;
            for (int i = 0; i < 9; ++i)
            {
                string param = "evn_sph" + i.ToString();
                Shader.SetGlobalVector(param, farEvn.coefficients[i]);
            }
        }
        float _density = density / Mathf.Sqrt(Mathf.Log(2));
        float _densityH = densityH / Mathf.Sqrt(Mathf.Log(2));

        //float _color_density = color_density /  Mathf.Sqrt(Mathf.Log(2));
        Shader.SetGlobalFloat("env_density", _density);
        Shader.SetGlobalFloat("height_density", _densityH);
        //Shader.SetGlobalFloat("color_density", color_density);

        Shader.SetGlobalFloat("globalEnvOffset", globalEnvOffset);
       
        if (enable_env)
        {
            Shader.EnableKeyword("ENABLE_DISTANCE_ENV");
        }
        else
        {
            Shader.DisableKeyword("ENABLE_DISTANCE_ENV");
        }
        if (farEvn)
        {
            Shader.EnableKeyword("GLOBAL_ENV_SH9");
        }
        else
        {
            Shader.DisableKeyword("GLOBAL_ENV_SH9");
        }
        Shader.SetGlobalFloat("fog_height_power", fog_height_power);
        var v = Matrix4x4.TRS(Vector3.zero, Quaternion.Euler(new Vector3(VirtualDirectLight0.x, VirtualDirectLight0.y, VirtualDirectLight0.z)), Vector3.one).MultiplyVector(Vector3.back);
        v.Normalize();
        //Vector3.forward
        Shader.SetGlobalVector("VirtualDirectLight0", v);
        Shader.SetGlobalFloat("_DifSC", _DifSC);
        Shader.SetGlobalColor("_BackColor", _BackColor);
        Shader.SetGlobalFloat("sss_scatter0", sss_scatter0);
        Shader.SetGlobalFloat("_CullSepe", _CullSepe);
        Shader.SetGlobalVector("VirtualDirectLightColor0",new Vector4(virtualDirectLightColor0.r, virtualDirectLightColor0.g, virtualDirectLightColor0.b, virtualDirectLightColor0Intensity));

        if (heightFog)
        {
            Shader.EnableKeyword("_HEIGHT_FOG_ON");
            Shader.SetGlobalFloat("heightFogHeight", heightFogHeight);
            Shader.SetGlobalFloat("heightFogHeight2", heightFogHeight2);
            Shader.SetGlobalColor("farSceneColor", farSceneColor);
        }
        else
        {
            Shader.DisableKeyword("_HEIGHT_FOG_ON");
        }
        




}
}
