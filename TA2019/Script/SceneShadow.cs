using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
#if UNITY_EDITOR
using UnityEditor;
#endif
[ExecuteInEditMode]
 
public class SceneShadow : MonoBehaviour
{
    [SerializeField]
    public Texture sceneColorMark;
   


   
    [SerializeField]
    public Matrix4x4 depthVPBias;
    [SerializeField]
    [HideInInspector]
    private LayerMask cullingMask;
#if UNITY_EDITOR
    [HideInInspector]
    [NonSerialized]
    public bool develop = false;
    [HideInInspector]
 

  
   

    private Camera depthCamera;

 
    private Shader shader;

 
    

  
    
    
    [HideInInspector]
    public float farClipPlane = 1000f;
    [HideInInspector]
    public float orthographicSize = 100f;

    
#endif
    // Start is called before the first frame update
    void Start()
    {
#if UNITY_EDITOR

#endif
    }
    private void OnEnable()
    {
        Shader.EnableKeyword("GRASS_SHADOW2");
        SetValues();
    }
    private void OnDisable()
    {
        Shader.DisableKeyword("GRASS_SHADOW2");
    }
    private void initRes()
    {
        if (null == shader)
            shader = Shader.Find("Editor/RenderShadowMap");
        if (null == depthCamera)
            depthCamera = gameObject.GetComponent<Camera>();
        if (null == depthCamera)
            depthCamera = gameObject.AddComponent<Camera>();

        if (!depthCamera.targetTexture)
        {
            depthCamera.targetTexture = new RenderTexture(2048, 2048, 24);
        }
        //depthCamera.SetReplacementShader(shader,"");
        depthCamera.ResetReplacementShader();
    }
 
    void SetValues()
    {
#if UNITY_EDITOR
        if (develop)
        {

            Shader.SetGlobalTexture("grass_kkSceneColor", depthCamera.targetTexture);

        }
        else
        {
 
            Shader.SetGlobalTexture("grass_kkSceneColor", sceneColorMark);
            
        }

#else
        Shader.SetGlobalTexture("grass_kkShadowMap", grassMark);
        Shader.SetGlobalTexture("grass_kkSceneColor", sceneColorMark);
#endif


#if UNITY_EDITOR
        if (develop)
        {
            Matrix4x4 biasMatrix = Matrix4x4.identity;
            biasMatrix[0, 0] = 0.5f;
            biasMatrix[1, 1] = 0.5f;
            biasMatrix[2, 2] = 0.5f;
            biasMatrix[0, 3] = 0.5f;
            biasMatrix[1, 3] = 0.5f;
            biasMatrix[2, 3] = 0.5f;
            Matrix4x4 depthProjectionMatrix = depthCamera.projectionMatrix;
            Matrix4x4 depthViewMatrix = depthCamera.worldToCameraMatrix;
            Matrix4x4 depthVP = depthProjectionMatrix * depthViewMatrix;
            depthVPBias = biasMatrix * depthVP;
            farClipPlane = depthCamera.farClipPlane;
            //depthCamera.SetReplacementShader(shader, "");
            Shader.EnableKeyword("GRASS_SHADOW2");
        }
#endif
        Shader.SetGlobalMatrix("grass_depthVPBias", depthVPBias);

    }
    // Update is called once per frame
    void Update()
    {
        transform.forward = Vector3.down;

#if UNITY_EDITOR
        if (develop)
        {

            initRes();
            depthCamera.enabled = true;
            depthCamera.hideFlags = HideFlags.None | HideFlags.DontSave;
            depthCamera.orthographic = true;
            depthCamera.backgroundColor = Color.white;
            depthCamera.clearFlags = CameraClearFlags.SolidColor;

        }

        SetValues();

#endif
    }
    /// <summary>
    /// 修改图片格式
    /// </summary>
    /// <param name="path">图片路径</param>
    /// <param name="platform"> Standalone, Web, iPhone, Android, WebGL, Windows Store Apps, PS4, XboxOne, Nintendo 3DS and tvOS</param>
    /// <param name="format">格式</param>

    public void ModifyTextureFormat(string path, string platform, TextureImporterFormat format, int compressionQuality = 100)
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
    internal void EndDevelop()
    {
        if (null != depthCamera&& null != depthCamera.targetTexture)
        {
            string path = EditorUtility.SaveFilePanel("保存图片", "assets", "", "png");
            if (path.Length > 0)
            {
                var old = RenderTexture.active;
                RenderTexture.active = depthCamera.targetTexture;
                Texture2D png = new Texture2D(depthCamera.targetTexture.width, depthCamera.targetTexture.height, TextureFormat.RGB24, false);
                png.ReadPixels(new Rect(0, 0, depthCamera.targetTexture.width, depthCamera.targetTexture.height), 0, 0);
                byte[] dataBytes = png.EncodeToPNG();
                System.IO.File.WriteAllBytes(path, dataBytes);

                int index = path.IndexOf("/Assets/") + 1;
                path = path.Substring(index);

                AssetDatabase.ImportAsset(path);

                ModifyTextureFormat(path, "Standalone", TextureImporterFormat.RGBA32);
                ModifyTextureFormat(path, "iPhone", TextureImporterFormat.ASTC_4x4);
                ModifyTextureFormat(path, "Android", TextureImporterFormat.ASTC_4x4);

                sceneColorMark = AssetDatabase.LoadAssetAtPath<Texture>(path);


                RenderTexture.active = old;
            }

            if (develop)
            {
                Matrix4x4 biasMatrix = Matrix4x4.identity;
                biasMatrix[0, 0] = 0.5f;
                biasMatrix[1, 1] = 0.5f;
                biasMatrix[2, 2] = 0.5f;
                biasMatrix[0, 3] = 0.5f;
                biasMatrix[1, 3] = 0.5f;
                biasMatrix[2, 3] = 0.5f;
                Matrix4x4 depthProjectionMatrix = depthCamera.projectionMatrix;
                Matrix4x4 depthViewMatrix = depthCamera.worldToCameraMatrix;
                Matrix4x4 depthVP = depthProjectionMatrix * depthViewMatrix;
                depthVPBias = biasMatrix * depthVP;
                farClipPlane = depthCamera.farClipPlane;
            }

            farClipPlane = depthCamera.farClipPlane;
            orthographicSize = depthCamera.orthographicSize;
            cullingMask = depthCamera.cullingMask ;
            depthCamera.targetTexture = null;
            depthCamera.enabled = false;
            depthCamera.hideFlags = HideFlags.HideInInspector | HideFlags.DontSave;


        }
       

       
        develop = false;
    }

    internal void BeginDevelop()
    {
        initRes();
        depthCamera.orthographicSize = orthographicSize;
        depthCamera.farClipPlane = farClipPlane;
        depthCamera.enabled = true;
        depthCamera.cullingMask = cullingMask;
        develop = true;
    }
}


#if UNITY_EDITOR
[CustomEditor(typeof(SceneShadow))]
public class SceneShadowEditor : Editor
{

    public string[] options = new string[] { "采集颜色图", "采集阴影图"  };
    
    public override void OnInspectorGUI()
    {
        SceneShadow grassShadow = target as SceneShadow;
 
        base.OnInspectorGUI();
#if UNITY_EDITOR






        if (grassShadow.develop)
        {
            
            if (GUILayout.Button("保存并退出"))
            {
 
                //grassShadow.shadowModel = EditorGUILayout.ToggleLeft("采集颜色", grassShadow.shadowModel);
                if (null != grassShadow)
                {
                    grassShadow.EndDevelop();
                }
            }
            if (GUILayout.Button("不保存退出"))
            {
                grassShadow.develop = false;
            }
        }
        else
        {
            if (GUILayout.Button("开发模式"))
            {
                grassShadow.BeginDevelop();

            }

        }
 ;
#endif

    }
}


#endif
