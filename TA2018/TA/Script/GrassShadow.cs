using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class GrassShadow : MonoBehaviour
{
    public Light mainLight;
    public LayerMask casterLayer = -1;
    [Range(0, 0.01f)]
    public float Bias = 0.005f;
    [Range(0, 1)]
    public float Strength = 1f;
    public Texture grassMark;
    private Matrix4x4 biasMatrix;



    [HideInInspector]
    [SerializeField]
    private Matrix4x4 depthViewMatrix;
    [HideInInspector]
    [SerializeField]
    private Matrix4x4 depthVPBias;
    [HideInInspector]
    [SerializeField]
    private float farClipPlane;
    // Start is called before the first frame update
    private void OnEnable()
    {

        Shader.EnableKeyword("GRASS_SHADOW");
        SetValues();
    }
    private void OnDisable()
    {
        Shader.DisableKeyword("GRASS_SHADOW");
    }

    void SetValues()
    {
        biasMatrix = Matrix4x4.identity;
        biasMatrix[0, 0] = 0.5f;
        biasMatrix[1, 1] = 0.5f;
        biasMatrix[2, 2] = 0.5f;
        biasMatrix[0, 3] = 0.5f;
        biasMatrix[1, 3] = 0.5f;
        biasMatrix[2, 3] = 0.5f;
#if UNITY_EDITOR
        if (develop)
        {
            if(null!= depthCamera)
            {
                Matrix4x4 depthProjectionMatrix = depthCamera.projectionMatrix;
                depthViewMatrix = depthCamera.worldToCameraMatrix;
                Matrix4x4 depthVP = depthProjectionMatrix * depthViewMatrix;
                depthVPBias = biasMatrix * depthVP;
                farClipPlane = depthCamera.farClipPlane;
            }
           
        }
#endif

#if UNITY_EDITOR
        if (develop)
            Shader.SetGlobalTexture("grass_kkShadowMap", depthCamera.targetTexture);
        else
            Shader.SetGlobalTexture("grass_kkShadowMap", grassMark);
#else
        Shader.SetGlobalTexture("grass_kkShadowMap", grassMark);
#endif

       
        Shader.SetGlobalMatrix("grass_depthVPBias", depthVPBias);
        Shader.SetGlobalMatrix("grass_depthV", depthViewMatrix);
        Shader.SetGlobalFloat("grass_bias", Bias);
        Shader.SetGlobalFloat("grass_strength", 1f - Strength);
        Shader.SetGlobalFloat("grass_farplaneScale", 1f / farClipPlane  );
        
        
    }

#if UNITY_EDITOR
    [HideInInspector]
    public bool develop = false;

    private Camera depthCamera;

    private RenderTexture rt;
    private Shader shader;

   
    public void BeginDevelop()
    {
        develop = true;
        CheckDevelop();
    }

    /// <summary>
    /// 修改图片格式
    /// </summary>
    /// <param name="path">图片路径</param>
    /// <param name="platform"> Standalone, Web, iPhone, Android, WebGL, Windows Store Apps, PS4, XboxOne, Nintendo 3DS and tvOS</param>
    /// <param name="format">格式</param>

    public  void ModifyTextureFormat(string path, string platform, TextureImporterFormat format, int compressionQuality = 100)
    {
        TextureImporter texImporter = TextureImporter.GetAtPath(path) as TextureImporter;

        if (null != texImporter)
        {

            var setting = texImporter.GetPlatformTextureSettings(platform);
            if (setting.format != format || setting.overridden != true)
            {
                setting.overridden = true;
                setting.format = format;
                setting.compressionQuality = compressionQuality;
                texImporter.SetPlatformTextureSettings(setting);
            }

        }
    }
    public void EndDevelop()
    {
      
        develop = false;
        string path = EditorUtility.SaveFilePanel("保存图片", "assets", "", "png");
        if (path.Length > 0)
        {
            var old = RenderTexture.active;
            RenderTexture.active = rt;
            Texture2D png = new Texture2D(rt.width, rt.height, TextureFormat.ARGB32, false);
            png.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
            byte[] dataBytes = png.EncodeToPNG();
            System.IO.File.WriteAllBytes(path, dataBytes);
 
            AssetDatabase.ImportAsset(path);
 
            ModifyTextureFormat(path, "Standalone",TextureImporterFormat.RGBA32);
            ModifyTextureFormat(path, "iPhone", TextureImporterFormat.ASTC_RGBA_4x4);
            ModifyTextureFormat(path, "Android", TextureImporterFormat.ASTC_RGBA_4x4);


            int index = path.IndexOf("/Assets/")+1;
            path = path.Substring(index);
            grassMark = AssetDatabase.LoadAssetAtPath<Texture>(path);

            RenderTexture.active = old;
        }
        CheckDevelop();


    }
    void CheckDevelop()
    {
        if (null != mainLight)
        {
            if (develop)
            {
                if (null == depthCamera)
                {
                    depthCamera = gameObject.GetComponent<Camera>();

      
                   
                }
                if (null == rt)
                {
                    rt = new RenderTexture(1024, 1024, 32);
                    depthCamera.targetTexture = rt;
                    if (null == shader)
                        shader = Shader.Find("Hidden/ShadowMap");
                    depthCamera.SetReplacementShader(shader, "RenderType");
                }
                   
                depthCamera.orthographic = true;
                depthCamera.nearClipPlane = 0f;
                depthCamera.enabled = develop;
                depthCamera.clearFlags = CameraClearFlags.Color;
               // depthCamera.backgroundColor = Color.white;
                //depthCamera
                Matrix4x4 depthProjectionMatrix = depthCamera.projectionMatrix;
                Matrix4x4 depthViewMatrix = depthCamera.worldToCameraMatrix;
                transform.forward = mainLight.transform.forward;
                depthCamera.hideFlags = HideFlags.None;
                depthCamera.cullingMask = casterLayer;
                depthCamera.enabled = true;
            }
            else
            {
                if (null != depthCamera)
                {
 
                    depthCamera.targetTexture = null;
                    GameObject.DestroyImmediate(rt, true);
                    depthCamera.hideFlags = HideFlags.HideInInspector;
                    depthCamera.enabled = false;
                }
            }
        }
    }
    // Update is called once per frame
    void Update()
    {

        Shader.EnableKeyword("GRASS_SHADOW");
        CheckDevelop();
        SetValues();
    }


#endif
    
}
#if UNITY_EDITOR
[CustomEditor(typeof(GrassShadow))]
public class GrassShadowEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
#if UNITY_EDITOR
        GrassShadow grassShadow = target as GrassShadow;
        if (grassShadow.develop)
        {
            if (GUILayout.Button("保存并退出"))
            {
                if (null != grassShadow)
                {
                    grassShadow.EndDevelop();
                     
                }
            }
        }
        else
        {
            if (GUILayout.Button("开发模式"))
            {
                grassShadow.BeginDevelop();

            }
           
        }
#endif

    }


}
#endif
 