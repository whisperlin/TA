using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SetGlobalSH9 : MonoBehaviour {

    public SH9Data data;
    SH9Data curData;
    [Header("总色调")]
    public Color GlobalTotalColor = Color.white;


    [Header("高显亮度调整")]
    [Range(-1f, 1f)]
    public float GlobalHeightEffectPower = 0;


    [Header("高显自发光")]
    public Color GlobalIntensityColor = Color.black;



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

 

    [Space]
    [Space]
    [Space]
     
 
    [Header("高光剔除")]
    [Range(-0.1f, 0.6f)]
    public float _CullSepe = 0.0f;

 
    [Header("场景虚拟光颜色")]
    public Color virtualSceneDirectLightColor0 = Color.white;

    [Header("场景光方向(烘培后用于打高光背光等)")]
    public Vector3 VirtualSceneDirectLight0;
    [Header("场景光强度")]
    [Range(0, 3)]

    public float virtualSceneDirectLightColor0Intensity = 1.0f;


    //[Header("烘培贴图法线加强")]
    //[Range(0, 1)]
    //public float _BakedNormalPower = 0.4f;
    //[Header("烘培贴图亮度")]
    //[Range(0, 3)]
    //public float _BakedNormalBright = 1.5f;


    // Use this for initialization
    void Start () {
        curData = null;

        //Shader.SetGlobalVector("_HitData0", new Vector4(-10000f, -10000f, -10000f, 0.001f));
        setSH9Global();
    }
	// Update is called once per frame
	void Update () {
        setSH9Global();
    }
    string[] g_sphs = new string[] { "g_sph0", "g_sph1", "g_sph2", "g_sph3", "g_sph4", "g_sph5", "g_sph6", "g_sph7", "g_sph8" };
    string[] evn_sphs = new string[] { "evn_sph0", "evn_sph1", "evn_sph2", "evn_sph3", "evn_sph4", "evn_sph5", "evn_sph6", "evn_sph7", "evn_sph8" };
    private void setSH9Global()
    {
 
        Shader.SetGlobalColor("GlobalTotalColor", GlobalTotalColor);
        Shader.SetGlobalFloat("GlobalHeightEffectPower", GlobalHeightEffectPower);
 
        //VirtualDirectLight0
        if (data != null && curData != data )
        {
            curData = data;
            for (int i = 0; i < 9; ++i)
            {
 
                Shader.SetGlobalVector(g_sphs[i], data.coefficients[i]);
            }
        }
         
  

        var v = Matrix4x4.TRS(Vector3.zero, Quaternion.Euler(new Vector3(VirtualDirectLight0.x, VirtualDirectLight0.y, VirtualDirectLight0.z)), Vector3.one).MultiplyVector(Vector3.back);
        v.Normalize();
        //Vector3.forward
        Shader.SetGlobalVector("VirtualDirectLight0", v);
        Shader.SetGlobalVector("VirtualDirectLightColor0", new Vector4(virtualDirectLightColor0.r, virtualDirectLightColor0.g, virtualDirectLightColor0.b, virtualDirectLightColor0Intensity));


        //virtualSceneDirectLightColor0

        var v2 = Matrix4x4.TRS(Vector3.zero, Quaternion.Euler(new Vector3(VirtualSceneDirectLight0.x, VirtualSceneDirectLight0.y, VirtualSceneDirectLight0.z)), Vector3.one).MultiplyVector(Vector3.back);
        v2.Normalize();
        Shader.SetGlobalVector("VirtualDirectSceneLight0", v2);

        Shader.SetGlobalVector("VirtualScenDirectLightColor0", new Vector4(virtualSceneDirectLightColor0.r, virtualSceneDirectLightColor0.g, virtualSceneDirectLightColor0.b, virtualSceneDirectLightColor0Intensity));

        // VirtualSceneDirectLight0  ；VirtualSceneDirectLight0；
        Shader.SetGlobalFloat("_DifSC", _DifSC);
        Shader.SetGlobalColor("_BackColor", _BackColor);
        Shader.SetGlobalFloat("sss_scatter0", sss_scatter0);
        Shader.SetGlobalFloat("_CullSepe", _CullSepe);

        Shader.SetGlobalColor("GlobalIntensityColor", GlobalIntensityColor);

        //var v3 = Matrix4x4.TRS(Vector3.zero, Quaternion.Euler(new Vector3(0f,140f, 0f)), Vector3.one).MultiplyVector(Vector3.back);
        //v3.Normalize();
        //Debug.LogError(_BackColor);

        /*if (heightFog)
        {
            Shader.EnableKeyword("_HEIGHT_FOG_ON");
            //Shader.SetGlobalFloat("heightFogHeight", heightFogHeight);
            //Shader.SetGlobalFloat("heightFogHeight2", heightFogHeight2);
            //Shader.SetGlobalColor("farSceneColor", farSceneColor);
        }
        else
        {
            Shader.DisableKeyword("_HEIGHT_FOG_ON");
        }*/

        //Shader.SetGlobalFloat("_BakedNormalPower", _BakedNormalPower);
        //Shader.SetGlobalFloat("_BakedNormalBright", _BakedNormalBright);


        //public float _BakedNormalPower = 0.5f;
        //[Header("烘培后亮度")]
        //[Range(0, 1)]
        //public float _BakedNormalBright = 1.0f;


    }
}
