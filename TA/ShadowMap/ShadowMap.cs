using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
[RequireComponent(typeof(Light))]
[RequireComponent(typeof(Camera))]
public class ShadowMap : MonoBehaviour {
    public enum TEXTURESIZE
    {
        S1024 = 1024,
        S512 = 512,
    }
        

    public LayerMask casterLayer = -1;
    public Shader shader;
 
    public TEXTURESIZE TextureSize = TEXTURESIZE.S1024;
    [Range(0, 0.1f)]
    public float Bias;
    [Range(0, 1)]
    public float Strength;
    private Matrix4x4 biasMatrix;
    private Camera depthCamera;
   
    private RenderTexture depthTexture;
    private bool isActive = true;
    private bool _isActive = true;

    public bool hardShadow = false;
    bool oldHardShadow = false;

    public Transform target;
    public Vector3 offset = new Vector3(0, 1f, 0);
    // Use this for initialization
    void Start () {
        oldHardShadow = !hardShadow;

    }

    private void OnDisable()
    {
        if (null != depthTexture)
        {
            depthCamera.targetTexture = null;
            GameObject.DestroyImmediate(depthTexture, true);
            depthTexture = null;
        }
    }
    // Update is called once per frame
    void LateUpdate () {
        if (null == depthCamera)
            depthCamera = GetComponent<Camera>();
        depthCamera.enabled = false;
        if (null == shader)
            shader = Shader.Find("Hidden/ShadowMap");


        depthCamera.orthographic = true;

        depthCamera.clearFlags = CameraClearFlags.SolidColor;
        depthCamera.backgroundColor = Color.white;
        if(null == depthTexture)
        {
            int s = TextureSize == TEXTURESIZE.S1024 ? 1024 :512;
            depthTexture = new RenderTexture(s, s, 16, RenderTextureFormat.ARGB32);
            depthTexture.filterMode = FilterMode.Bilinear;
        }
        depthTexture.hideFlags = HideFlags.HideAndDontSave;
        depthCamera.targetTexture = depthTexture;
        depthCamera.SetReplacementShader(shader, "RenderType");
        depthCamera.enabled = false;
        biasMatrix = Matrix4x4.identity;
        biasMatrix[0, 0] = 0.5f;
        biasMatrix[1, 1] = 0.5f;
        biasMatrix[2, 2] = 0.5f;
        biasMatrix[0, 3] = 0.5f;
        biasMatrix[1, 3] = 0.5f;
        biasMatrix[2, 3] = 0.5f;


        depthCamera.cullingMask = casterLayer;

        if (null != target)
        {
            depthCamera.transform.position = target.transform.position + offset - transform.transform.forward*depthCamera.farClipPlane*0.5f;
        }
        depthCamera.Render();
 
        Matrix4x4 depthProjectionMatrix = depthCamera.projectionMatrix;
        Matrix4x4 depthViewMatrix = depthCamera.worldToCameraMatrix;
        Matrix4x4 depthVP = depthProjectionMatrix * depthViewMatrix;
        Matrix4x4 depthVPBias = biasMatrix * depthVP;
        Shader.SetGlobalMatrix("_depthVPBias", depthVPBias);
        Shader.SetGlobalMatrix("_depthV", depthViewMatrix);
        Shader.SetGlobalTexture("_kkShadowMap", depthCamera.targetTexture);
        Shader.SetGlobalFloat("_bias", Bias);
        Shader.SetGlobalFloat("_strength", 1f - Strength);
        Shader.SetGlobalFloat("_farplaneScale", 1f / depthCamera.farClipPlane);

        if (oldHardShadow != hardShadow)
        {
            if (hardShadow)
            {
                Shader.EnableKeyword("HARD_SHADOW");
                Shader.DisableKeyword("SOFT_SHADOW_4Samples");
 
            }
            else
            {
                Shader.DisableKeyword("HARD_SHADOW");
                Shader.EnableKeyword("SOFT_SHADOW_4Samples");
 
            }
            oldHardShadow = hardShadow;
        }
        


    }
}
