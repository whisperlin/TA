using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SetLightDataCartoonForDevelop : MonoBehaviour
{

    [Header("角色虚拟光颜色")]
    public Color virtualDirectLightColor0 = Color.white;
    [Header("虚拟光强度")]
    [Range(0, 3)]
    public float virtualDirectLightColor0Intensity = 1.0f;
    [Header("角色虚拟光方向")]
    public Vector3 VirtualDirectLight0;

    [Header("阴影强度(占背面大小)")]
    [Range(-1, 1)]
    public float _ShadowPower;
    [Header("阴影颜色")]
    public Color _ShadowColor = Color.blue;
    Camera mCamera;
    // Use this for initialization
    void Start()
    {
        
        SetGlobalParams();
    }
    // Update is called once per frame
    void Update()
    {
        SetGlobalParams();
        if (null == mCamera)
            mCamera = GetComponent<Camera>();
        if(null != mCamera)
            mCamera.depthTextureMode = DepthTextureMode.Depth;

        Shader.SetGlobalColor("_ShadowColor", _ShadowColor);
        Shader.SetGlobalFloat("_ShadowPower", _ShadowPower);
    }
    private void SetGlobalParams()
    {
        var v = Matrix4x4.TRS(Vector3.zero, Quaternion.Euler(new Vector3(VirtualDirectLight0.x, VirtualDirectLight0.y, VirtualDirectLight0.z)), Vector3.one).MultiplyVector(Vector3.back);
        v.Normalize();
        Shader.SetGlobalVector("VirtualDirectLight0", v);
        Shader.SetGlobalVector("VirtualDirectLightColor0", new Vector4(virtualDirectLightColor0.r, virtualDirectLightColor0.g, virtualDirectLightColor0.b, virtualDirectLightColor0Intensity));

    }
}


 