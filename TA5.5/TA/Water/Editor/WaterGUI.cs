using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[ExecuteInEditMode]
public class WaterGUI : ShaderGUI
{
    
 
 
    //static MeshRenderer mesh;



    readonly int WaterDepthTex = Shader.PropertyToID("WaterDepthTex");
    readonly int WorldToWaterCamera = Shader.PropertyToID("WorldToWaterCamera");

    readonly int waterRangeScale = Shader.PropertyToID("waterRangeScale");
    readonly int waterToolctrlPower = Shader.PropertyToID("waterToolctrlPower");
    
    static int width0 = 2;
    static int height0 = 2;

    public string[] options = new string[] { "128", "256", "512", "1024" };
    int GetSize(int index0)
    {
        int width = 256;
        if (index0 == 0)
            width = 128;
        if (index0 == 2)
            width = 512;
        if (index0 == 3)
            width = 1024;
        return width;
    }

    override public void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // render the shader properties using the default GUI


         
        Material targetMat = materialEditor.target as Material;

        GUIStyle titleStyle2 = new GUIStyle();
        titleStyle2.fontSize = 30;
        titleStyle2.normal.textColor = new Color(  256f, 0f, 0f, 1);
     

       //if (targetMat.GetTexture("_ColorControl") == null)
        //    GUILayout.Label("水还没生成过深度贴图", titleStyle2);

       

       
        bool IsDebuggingMode =  targetMat.IsKeywordEnabled("__CREATE_DEPTH_MAP");
        IsDebuggingMode = EditorGUILayout.Toggle("开启调试模式",IsDebuggingMode);
        if (IsDebuggingMode)
        {
            float f = Shader.GetGlobalInt(waterToolctrlPower);

            GUILayout.Label("贴图深度采样控制");
            if (f < 0.01f)
                f = 0.01f;
            f = EditorGUILayout.Slider(  f, 0.1f, 50f);
            Shader.SetGlobalFloat("waterToolctrlPower", f );
            GUILayout.Label("目标贴图大小");
            width0 = EditorGUILayout.Popup(width0, options);
            height0 = EditorGUILayout.Popup(height0, options);
            targetMat.EnableKeyword("__CREATE_DEPTH_MAP");

            

            
            Camera.main.depthTextureMode = DepthTextureMode.Depth;
            //mesh = (MeshRenderer)EditorGUILayout.ObjectField(mesh, typeof(MeshRenderer));
            if (GUILayout.Button("生成深度贴图"))
            {
                //if (null == mesh)
                if(false)
                {
                    EditorUtility.DisplayDialog("提示", "请选择要生成深度贴图的对象", "确定");
                }
                else
                {
                    int width = GetSize(width0);
                    int height = GetSize(height0);
                    RenderTexture rt = RenderTexture.GetTemporary(width, height);
                    Camera.main.targetTexture = rt;
                    var oldPos = Camera.main.transform.position;
                    var oldForward = Camera.main.transform.forward;
                    Camera.main.transform.position = SceneView.lastActiveSceneView.camera.transform.position;
                    Camera.main.transform.forward =  SceneView.lastActiveSceneView.camera.transform.forward;
                    targetMat.EnableKeyword("__CREATE_DEPTH_MAP2");
                    Camera.main.Render();
                    Camera.main.transform.position = oldPos;
                    Camera.main.transform.forward = oldForward;
                    Camera.main.targetTexture = null;

                    //Material m = new Material(Shader.Find("TA/SimpleBlurEffect"));
                    //Graphics.Blit(rt, rt, m);
                    //Graphics.Blit(rt, rt, m);
                    //GameObject.DestroyImmediate(m);
                    string path = EditorUtility.SaveFilePanelInProject("提示", "mark", "png",
                   "请输入保存文件名");
                    if (path.Length != 0)
                    {
                        //保存png
                        RenderTexture prev = RenderTexture.active;
                        RenderTexture.active = rt;
                        Texture2D png = new Texture2D(rt.width, rt.height, TextureFormat.ARGB32, false);
                        png.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
                        byte[] bytes = png.EncodeToPNG();
                        System.IO.File.WriteAllBytes(path, bytes);
                        Texture2D.DestroyImmediate(png);
                        png = null;
                        RenderTexture.active = prev;
                        AssetDatabase.ImportAsset(path);
                        Texture2D t = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
                        targetMat.SetTexture("_ColorControl", t);
                    }
                    targetMat.DisableKeyword("__CREATE_DEPTH_MAP2");
                    RenderTexture.ReleaseTemporary(rt);
                }
            }
        }
        else
        {
            base.OnGUI(materialEditor, properties);
            Camera.main.depthTextureMode = DepthTextureMode.None;
            targetMat.DisableKeyword("__CREATE_DEPTH_MAP");
   
        }
        

         
    }
   

     
}
