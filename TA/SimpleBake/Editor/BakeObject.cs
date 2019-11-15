using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class BakeObjectWindow : EditorWindow
{

    bool groupEnabled;
 
    bool bakeLightMap = false;
 

    static Mesh plane;
    static MeshRenderer planeRender;

    //[MenuItem("TA/生成面")]
    void CreatePlane() {

        if (null == plane)
        {
            plane = new Mesh();
            plane.vertices = new Vector3[] { new Vector3(-10, 0, -10), new Vector3(10, 0, -10), new Vector3(-10, 0, 10), new Vector3(10, 0, 10) };
            plane.uv = new Vector2[] { new Vector2(0, 0), new Vector2(1, 0), new Vector2(0, 1), new Vector2(1, 1) };
            plane.uv2 = plane.uv;
            plane.triangles = new int[] { 0, 2, 1, 1, 2, 3 };
            plane.RecalculateNormals();
            plane.hideFlags = HideFlags.DontSave;
        }
        if (null == planeRender)
        {
            GameObject g = new GameObject();
            g.name = "BakeObj";
            g.AddComponent<MeshFilter>().sharedMesh = plane;
            planeRender = g.AddComponent<MeshRenderer>();
            g.hideFlags = HideFlags.DontSave;
        }
        //UnityEditor.SceneView.GetAllSceneCameras();


    }
    // Add menu named "My Window" to the Window menu
    [MenuItem("TA/简单烘焙")]
    static void Init()
    {
        // Get existing open window or if none, make a new one:
        BakeObjectWindow window = (BakeObjectWindow)EditorWindow.GetWindow(typeof(BakeObjectWindow));
        window.Show();
    }

   

    public string[] options = new string[] { "128", "256", "512","1024" };
    public int index0 = 1;
    public int index1 = 1;
    Camera cam = null;
    MeshRenderer _meshRender   = null;
    RenderTexture rt;
    Vector3 oldPos;
    bool isUVWarp = false;
    Camera bakeCam = null;
    private Material uvMat;
    bool fromFirstTexture = true;
    bool usingSceneViewDirect = true;
    void OnGUI()
    {
        //isUVWarp = EditorGUILayout.Toggle("是否平展uv", isUVWarp);
        isUVWarp = false;
        if (isUVWarp)
        {
            if (null == uvMat)
                GUILayout.Label("请选择一个烘焙的物体", EditorStyles.boldLabel);
            uvMat = (Material)EditorGUILayout.ObjectField(uvMat, typeof(Material));
        }
        else
        {
            if (null == _meshRender)
                GUILayout.Label("请选择一个烘焙的物体", EditorStyles.boldLabel);
            _meshRender = (MeshRenderer)EditorGUILayout.ObjectField(_meshRender, typeof(MeshRenderer));
        }


        usingSceneViewDirect = EditorGUILayout.Toggle("相机使用视口SceneWindow位置", usingSceneViewDirect);

        if (!usingSceneViewDirect)
        {
            
            GUILayout.Label("请选择主相机，不选则选择视图窗口相机.", EditorStyles.boldLabel);
            cam = (Camera)EditorGUILayout.ObjectField(cam, typeof(Camera));

        }


        fromFirstTexture = EditorGUILayout.Toggle("大小和第一张贴图相同",fromFirstTexture);
        if (!fromFirstTexture)
        {
            index0 = EditorGUILayout.Popup(index0, options);
            index1 = EditorGUILayout.Popup(index1, options);
        }


        EditorGUILayout.ObjectField(rt, typeof(RenderTexture));


        //bakeLightMap = EditorGUILayout.Toggle("烘焙光照图", bakeLightMap);
        if (GUILayout.Button("烘焙"))
        {
            BakeObj();
        }

        
    }
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
    float GetSign(float f)
    {
        if (f >= 0)
            return 1;
        return -1;
    }
    void BakeObj()
    {
        if (isUVWarp)
        {
            if (null == uvMat)
            {
                return;
            }
            else
            {
                CreatePlane();
                _meshRender = planeRender;
                planeRender.sharedMaterial = uvMat;
            }
        }
        else
        {
            if (null == _meshRender)
            {
                EditorUtility.DisplayDialog("提示", "请选择一个MeshRender对象", "确定");
                return;
            }
                
        }

        //简单的检查.
        if (!_meshRender.sharedMaterial.HasProperty("S_BAKE"))
        {
            EditorUtility.DisplayDialog("提示", "当前物体的材质使用的shader暂时不支持烘焙", "确定");
            return;
        }
        

        

        

        if (null == cam)
            cam = Camera.main;
        if (null == cam)
            return;

        int width = GetSize(index0);
        int height = GetSize(index1);

        if (null != rt)
            GameObject.DestroyImmediate(rt);


        if (fromFirstTexture)
        {
            if (uvMat)
            {
                width = uvMat.mainTexture.width;
                height = uvMat.mainTexture.height;
            }
            else
            {
                width = _meshRender.sharedMaterial.mainTexture.width;
                height = _meshRender.sharedMaterial.mainTexture.height;
            }
        }
        rt = new RenderTexture(width, height, 24);
        if (usingSceneViewDirect)
        {
            if (SceneView.lastActiveSceneView != null  )
            {
                bakeCam = CopyCamera(SceneView.lastActiveSceneView.camera, bakeCam);
                bakeCam.transform.position = SceneView.lastActiveSceneView.camera.transform.position;
                bakeCam.transform.rotation = SceneView.lastActiveSceneView.camera.transform.rotation;
            }
        }
        else
        {
            bakeCam = CopyCamera(cam, bakeCam);
        }
         

        float oldCull = _meshRender.sharedMaterial.GetFloat("_Cull");
        _meshRender.sharedMaterial.SetFloat("_Cull", 0f);
        _meshRender.sharedMaterial.EnableKeyword("S_BAKE");
        bakeCam.gameObject.hideFlags = HideFlags.DontSave;


        Vector2 _MainTexOffset = _meshRender.sharedMaterial.mainTextureOffset;
        Vector2 _MainTexScale = _meshRender.sharedMaterial.mainTextureScale;

        _MainTexOffset = new Vector2(GetSign(_MainTexOffset.x), GetSign(_MainTexOffset.y));
        _MainTexScale = new Vector2(GetSign(_MainTexScale.x), GetSign(_MainTexScale.y));
        _meshRender.sharedMaterial.mainTextureOffset = _MainTexOffset;
        _meshRender.sharedMaterial.mainTextureScale = _MainTexScale;
 
        Renderer [] rs = GameObject.FindObjectsOfType<Renderer>();
        bool[] rst = new bool[rs.Length];
        for (int i = 0; i < rs.Length; i++)
        {
            rst[i] = rs[i].enabled;
            rs[i].enabled = false;
        }

        oldPos = _meshRender.transform.position;
        bakeCam.targetTexture = rt;
        bakeCam.enabled = true;
        _meshRender.enabled = true;
        bakeCam.farClipPlane = 1000;
        
       
        
        if (!usingSceneViewDirect)
        {
            _meshRender.transform.position = bakeCam.transform.position + bakeCam.transform.forward * 500;
        }
        bakeCam.Render();
        //确保相机包含物体.

        bakeCam.enabled = false;
         
        for (int i = 0; i < rs.Length; i++)
        {
            rs[i].enabled = rst[i];
        }
        //br.callback = OnFinish ;
        
        _meshRender.sharedMaterial.SetFloat("_Cull", oldCull);
        _meshRender.sharedMaterial.DisableKeyword("S_BAKE");
        _meshRender.transform.position = oldPos;
        bakeCam.enabled = false;


        string path = EditorUtility.SaveFilePanelInProject("提示", "TextureName", "tga",
                   "请输入保存文件名");
        if (path.Length != 0)
        {
            //保存png
            RenderTexture prev = RenderTexture.active;
            RenderTexture.active = rt;
            Texture2D png = new Texture2D(rt.width, rt.height, TextureFormat.ARGB32, false);
            png.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
            byte[] bytes = EncodeToTGAExtension.EncodeToTGA(png, 3);
            System.IO.File.WriteAllBytes(path, bytes);
            Texture2D.DestroyImmediate(png);
            png = null;
            RenderTexture.active = prev;
            AssetDatabase.ImportAsset(path);
            Texture2D t = AssetDatabase.LoadAssetAtPath<Texture2D>(path);

            Material mat = new Material(Shader.Find("Mobile/Diffuse"));
            mat.mainTexture = t;
            mat.mainTextureScale = _MainTexScale;
            mat.mainTextureOffset = _MainTexOffset;
          
            path = path.Replace(".tga", ".mat");
            AssetDatabase.CreateAsset(mat, path);

        }
        GameObject.DestroyImmediate(bakeCam.gameObject);
    }
    
    
    Camera CopyCamera(Camera c ,Camera p)
    {
        if (p == null)
        {
            GameObject g = new GameObject("CopyCam");
            p = g.AddComponent<Camera>();
            p.CopyFrom(c);

        }
        p.transform.forward = c.transform.forward;
        p.transform.position = c.transform.position;

        return p;
    }
    void Clear()
    {
        if (null != plane)
            GameObject.DestroyImmediate(plane);
        if (null != rt)
            GameObject.DestroyImmediate(rt);
        if (null != bakeCam)
        {
            GameObject.DestroyImmediate(bakeCam.gameObject);
        }
            
    }
    void OnDisable()
    {
        Clear();
    }

}
