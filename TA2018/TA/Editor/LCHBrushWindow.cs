using UnityEditor;
using UnityEngine;

public partial class LCHBrushWindow : EditorWindow
{
    [MenuItem("TA/工具/对象画刷")]
    public static void ShowWindow()
    {
        var window = GetWindow<LCHBrushWindow>();
        window.title = "对象画刷";
        window.Show();
    }

    void OnFocus()
    {
#if UNITY_2019_1_OR_NEWER
        SceneView.duringSceneGui -= OnSceneGUI;
        SceneView.duringSceneGui += OnSceneGUI;
#else
        SceneView.onSceneGUIDelegate -= OnSceneGUI;
        SceneView.onSceneGUIDelegate += OnSceneGUI;
#endif
        Repaint();
    }
    private void OnLostFocus()
    {
        //this.Focus();
    }

    void OnDestroy()
    {

#if UNITY_2019_1_OR_NEWER
        SceneView.duringSceneGui -= OnSceneGUI;
#else
        SceneView.onSceneGUIDelegate -= OnSceneGUI;
#endif
        
        /*if (capSphere != null)
        {
            DestroyImmediate(capSphere.gameObject);
        }*/
    }

    
    private void OnSceneGUI(SceneView sceneView)
    {
        if (!editorEnable)
            return;
        if (null == ist)
            return;
        //Selection.objects = new Object[0];
        // 当前屏幕坐标，左上角是（0，0）右下角（camera.pixelWidth，camera.pixelHeight）
        Vector2 mousePosition = Event.current.mousePosition;

        // Retina 屏幕需要拉伸值
        float mult = 1;
#if UNITY_5_4_OR_NEWER
        mult = EditorGUIUtility.pixelsPerPoint;
#endif





        Vector3 point = Vector3.zero;

        int id = GUIUtility.GetControlID(FocusType.Passive);
        Ray ray = HandleUtility.GUIPointToWorldRay(mousePosition);
        RaycastHit hit;
        
        bool hitGround = Physics.Raycast(ray, out hit,1000f,groundMark);
        SphereCapPos(hit.point, brushSize, hitGround);
        if (Event.current.rawType == EventType.MouseDown)
        {
            if (Event.current.button == 0)
            {
                if (Event.current.control)
                {
                    DeleteObject(  hit.point );
                }
                else
                {
                    AddObject(ray, hit.point, hit.distance, hit.normal);
                    
                }
                Event.current.Use();
            }

        }
        Selection.objects = new Object[0];
        


        // 刷新界面，才能让球一直跟随
        sceneView.Repaint();
        HandleUtility.Repaint();
    }

    private static Transform capSphere;

    private void SphereCapPos(Vector3 point,float scale,bool hit)
    {
        if (capSphere == null)
        {
            GameObject go = GameObject.Find("[SphereCapPos]");
            if (go == null)
            {
                go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                go.name = "[SphereCapPos]";

                Collider collider = go.GetComponent<Collider>();
                DestroyImmediate(collider);

                Material mat = new Material(Shader.Find("Editor/Color"));
                mat.SetColor("_Color", new Color(0f,0f,1f,0.3f));
                mat.hideFlags = HideFlags.HideAndDontSave;

                Renderer renderer = go.GetComponent<Renderer>();
                renderer.sharedMaterial = mat;
                go.hideFlags = HideFlags.HideAndDontSave;
            }

            go.hideFlags = HideFlags.HideAndDontSave;
            capSphere = go.transform;
            capSphere.rotation = Quaternion.identity;
           
        }
        capSphere.gameObject.SetActive(hit);
        capSphere.localScale = Vector3.one * scale;
        capSphere.position = point;
    }
}
