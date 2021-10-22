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
            if (path.Length > 0)
            {
                path = path.Replace('\\', '/');
                int _id = path.IndexOf("/Assets/");
                if (_id >= 0)
                {
                    path = path.Substring(_id + 1);
                    Texture2D tx = AssetDatabase.LoadAssetAtPath<Texture2D>(path) as Texture2D;
                    Graphics.Blit(tx, rt);
                }



            }

        }
        GUILayout.EndHorizontal();

        Texture2D preview = Texture2D.whiteTexture;
        if (backBround)
        {
            preview = backBround;
        }
        Rect rect0 = EditorGUILayout.GetControlRect(false, 2);
        mat.SetTexture("_TargetTex", rt);
        float width = Mathf.Min(this.position.width - 5, this.position.height - 7 - rect0.x);
        Rect rect = EditorGUILayout.GetControlRect(false, width);
        float w = Mathf.Min(rect.width, rect.height);
        rect.width = rect.height = w;
        EditorGUI.DrawPreviewTexture(rect, preview, mat);

        float m1 = (baseTexture ? 1f : 0f);
        Shader.SetGlobalVector("GlobalFlowMapPaintParams2", new Vector4(m1, 1f, 1f, 1f));
        this.wantsMouseMove = true;
        if (Event.current.type == EventType.MouseMove)
        {

            Vector2 pos = new Vector2(Event.current.mousePosition.x - rect.x, Event.current.mousePosition.y - rect.y);
            if (pos.x >= 0 && pos.y > 0 && pos.x < width && pos.y >= 0 && pos.y <= width)
            {
                Vector2 paintPos = pos / width;
                Vector2 paintDir = (lastPosition - pos).normalized;

                Shader.SetGlobalVector("GlobalFlowMapPaintPos", new Vector4(paintPos.x, paintPos.y, paintDir.x, paintDir.y));


                lastPosition = pos;


            }

        }
        if (Event.current.type == EventType.MouseDown)
        {
            Vector2 pos = new Vector2(Event.current.mousePosition.x - rect.x, Event.current.mousePosition.y - rect.y);
            if (pos.x >= 0 && pos.y > 0 && pos.x < width && pos.y >= 0 && pos.y <= width)
            {
                Vector2 paintPos = pos / width;
                Vector2 paintDir = (lastPosition - pos).normalized;
                Shader.SetGlobalVector("GlobalFlowMapPaintPos", new Vector4(paintPos.x, paintPos.y, paintDir.x, paintDir.y));

                isDragging = true;
                lastPosition = pos;
            }

        }
        if (Event.current.type == EventType.MouseUp)
        {
            isDragging = false;
        }
        if (Event.current.type == EventType.MouseDrag)
        {
            if (isDragging)
            {
                Vector2 pos = new Vector2(Event.current.mousePosition.x - rect.x, Event.current.mousePosition.y - rect.y);
                if (pos.x >= 0 && pos.y > 0 && pos.x < width && pos.y >= 0 && pos.y <= width)
                {

                    Vector2 paintPos = pos / width;
                    Vector2 paintDir = (lastPosition - pos).normalized;
                    Vector4 v = new Vector4(paintPos.x, paintPos.y, paintDir.x * 0.5f + 0.5f, paintDir.y * 0.5f + 0.5f);


                    Shader.SetGlobalVector("GlobalFlowMapPaintPos", v);

                    Graphics.Blit(rt, rt1, mat2, 1);
                    var r = rt1;
                    rt1 = rt;
                    rt = r;

                    lastPosition = pos;



                }
            }
        }
    }
    void On3DPanel()
    {
    }
    private void OnGUI()
    {
        toolbarInt = GUILayout.Toolbar(toolbarInt, toolbarStrings);

        switch (toolbarInt)
        {
            case 0:
                {
                    On2DPanel();
                }
                break;
            case 1:
                {
                    On3DPanel();
                }
                break;
        }
    }
}

