using UnityEngine;
using System.Collections;

#if UNITY_EDITOR
using UnityEditor;
#endif
public class VirtualPointLight : MonoBehaviour
{
    public float range  = 1;
    [ColorUsage(true, true)]
    public Color color = Color.white;

#if UNITY_EDITOR
   

 
    static Texture2D icon ;
    void OnDrawGizmos()
    {
        if (null == icon)
        {
            var obj = Resources.Load("VirtualPointLight Icon");
            icon = obj as Texture2D;
        }
        string path = AssetDatabase.GetAssetPath(icon);
        string root2 =  "Assets/Gizmos";
        string path2 = root2+path.Substring(path.LastIndexOf("/"));

        if (!System.IO.Directory.Exists(root2))
        {
            System.IO.Directory.CreateDirectory(root2);
        }
        if (!System.IO.File.Exists(path2))
        {
            System.IO.File.Copy(path, path2);;
        }
        Gizmos.DrawIcon(transform.position, "PointLight Gizmo", true);
        EditorGUIUtility.FindTexture("PointLight Gizmo");
    }
    void OnDrawGizmosSelected()
    {
        Gizmos.DrawWireSphere(this.transform.position, range);
    }

    [MenuItem("GameObject/Light/Virtual Point Light")]
    static void CreateMenu()
    {
        GameObject g = new GameObject("Virtual Point Light");
        g.AddComponent<VirtualPointLight>();
    }
#endif
}
