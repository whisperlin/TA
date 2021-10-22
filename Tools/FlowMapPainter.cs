using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System;

public class FlowMapPainter : EditorWindow
{
    [MenuItem("TA/Flow Map Painter")]
    public static void OpenEmojiBuildEditor()
    {
        var win = GetWindow<FlowMapPainter>();
        win.wantsMouseMove = true;
        win.wantsMouseEnterLeaveWindow = true;
        win.init();
        win.Show();
    }
    Texture2D backBround;
    float size = 0.1f;
    float strong = 0.2f;
    float soft = 0f;
    bool isDragging = false;
    Vector2 lastPosition = Vector2.zero;
    public RenderTexture rt;
    public RenderTexture rt1;
    Material mat;
    Material mat2;
    public bool baseTexture;
    Mesh uvMesh;
 

    LchUVAreaPerviewTexture UVAreaPerviewTexture = new LchUVAreaPerviewTexture();

    private void OnDisable()
    {
 
        if (null == rt)
            GameObject.DestroyImmediate(rt,true);
        if (null == rt1)
            GameObject.DestroyImmediate(rt1, true);
        if (null == mat2)
            GameObject.DestroyImmediate(mat2, true);
        if (null == mat)
            GameObject.DestroyImmediate(mat, true);
        SceneView.beforeSceneGui -= UpdateWindow;
        UVAreaPerviewTexture.Release();

    }
    
    private void OnInspectorUpdate()
    {
        Repaint();
    }
    private void OnEnable()
    {
        SceneView.beforeSceneGui += UpdateWindow;
    }

    private void UpdateWindow(SceneView obj)
    {
        Repaint();
    }

    private void Update()
    {
        UVAreaPerviewTexture.Update();
        Repaint();
    }
    void init()
    {
        if (null == mat)
        {
            mat = new Material(Shader.Find("Hidden/FlowMapPerview"));
        }
        if (null == mat2)
        {
            mat2 = new Material(Shader.Find("Hidden/FlowMapFlowMapPaint"));
        }
        if (null == rt)
        {
            rt = new RenderTexture(512, 512, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
            Graphics.Blit(rt, rt, mat2, 0);
        }
        if (null == rt1)
        {
            rt1 = new RenderTexture(512, 512, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        }
    }

    int toolbarInt = 0;
    string[] toolbarStrings = { "2D", "3D" };

    void On2DPanel()
    {
        init();
        UVAreaPerviewTexture.Check();

        backBround = EditorGUILayout.ObjectField(backBround, typeof(Texture2D), false) as Texture2D;
        EditorGUI.BeginChangeCheck();
        uvMesh = EditorGUILayout.ObjectField(uvMesh, typeof(Mesh), false) as Mesh;

       
        if (EditorGUI.EndChangeCheck() && null != uvMesh)
        {
            UVAreaPerviewTexture.DrawUVs(uvMesh.uv, uvMesh.triangles);
            Shader.SetGlobalTexture("GlobalFlowMapUVS", UVAreaPerviewTexture.texture);
        }
        if (uvMesh == null)
        {
            Shader.DisableKeyword("_GLOBAL_FLOW_MAP");
        }
        else
        {
            Shader.EnableKeyword("_GLOBAL_FLOW_MAP");
        }

        //UVAreaPerviewTexture.texture = EditorGUILayout.ObjectField(UVAreaPerviewTexture.texture, typeof(Texture2D), false) as Texture2D;

        GUILayout.BeginHorizontal();
        size = EditorGUILayout.Slider("Size", size, 0.01f, 0.1f);
        strong = EditorGUILayout.Slider("Strong", strong, 0f, 1f);
        soft = EditorGUILayout.Slider("Soft", soft, 0f, 1f);


        GUILayout.EndHorizontal();
        Shader.SetGlobalVector("GlobalFlowMapPaintParams", new Vector4(size, strong, soft, 1));
        GUILayout.BeginHorizontal();
        baseTexture = EditorGUILayout.Toggle("BaseTex", baseTexture);

        GUILayout.EndHorizontal();
        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Clear"))
        {
            Graphics.Blit(rt, rt, mat2, 0);
        }
        if (GUILayout.Button("Save"))
        {
            string path = EditorUtility.SaveFilePanelInProject("", "flowmap", "png", "Save png");
            if (path.Length > 0)
            {
                Texture2D tex2d = new Texture2D(rt.width, rt.height, TextureFormat.ARGB32, false);
                var oldRt = RenderTexture.active;
                RenderTexture.active = rt;
                tex2d.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
                tex2d.Apply();
                RenderTexture.active = oldRt;
                var bytes = tex2d.EncodeToPNG();

                System.IO.File.WriteAllBytes(path, bytes);
                AssetDatabase.ImportAsset(path);
                GameObject.DestroyImmediate(tex2d, true);
            }
        }
        if (GUILayout.Button("Load"))
        {
            string[] type = { "Image files", "png,tga,dds,jpg", "All files", "*" };
            string path = EditorUtility.OpenFilePanelWithFilters("选择一个图片", "", type);
            if (path
