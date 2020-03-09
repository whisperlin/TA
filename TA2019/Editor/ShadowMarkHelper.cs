using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor.SceneManagement;

#if UNITY_EDITOR
using UnityEditor;
#endif
public class ShadowMarkHelper  
{
#if UNITY_EDITOR

    [MenuItem("TA/Shadow mark/清除合并shadow mark")]
    static void Clear()
    {
        ClearCmpToRender();
        ClearAsset();
    }

    [MenuItem("TA/Shadow mark/合并shadow mark")]
    static void printLightMapIndex()
    {
        TextureImporterFormat format = TextureImporterFormat.ASTC_4x4;
        string root = AssetDatabase.GetAssetPath( Lightmapping.lightingDataAsset);
        root = root.Substring(0, root.LastIndexOf('/'));
        string end1 = "_comp_shadowmask.png";
        string end2 = "_comp_light.exr";
        var s = UnityEngine.SceneManagement.SceneManager.GetActiveScene();
        string end3 = "_LightSM.tga";
        List<string> found_paths = new List<string>();

        int width = 512;
        int height = 512;
        string [] paths =System.IO.Directory.GetFiles(root);
        Dictionary<int, string> lightMapTemp = new Dictionary<int, string>();
        int maxIndex = -1;
        for (int i = 0; i < paths.Length; i++)
        {
            string path = paths[i];
            if (path.EndsWith(end1))
            {
                string heater = path.Substring(0, path.Length - end1.Length);
                int index = int.Parse( heater.Substring(heater.LastIndexOf('-')+1));
                maxIndex = Mathf.Max(index, maxIndex);
                string path2 = heater + end2;
                if (System.IO.File.Exists(path2))
                {

                    Texture2D t = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
                    Texture2D t2 = AssetDatabase.LoadAssetAtPath<Texture2D>(path2);
                    found_paths.Add(path);
                    found_paths.Add(path2);
                    width = t.width;
                    height = t.height;

                    RenderTexture rt = RenderTexture.GetTemporary(t.width, t.height, 0);
                    Material mat = new Material(Shader.Find("Hidden/HdrToHalfColor"));
                    mat.SetTexture("_MainTex", t2);
                    mat.SetTexture("_MainTex2", t);
                    Graphics.Blit(t2, rt, mat);

                    RenderTexture.active = rt;
                    Texture2D png = new Texture2D(rt.width, rt.height, TextureFormat.RGBA32, false);
                    png.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);

                    byte[] bytes = EncodeToTGAExtension.EncodeToTGA(png, 4);
                    string path3 = heater + end3;
                    System.IO.File.WriteAllBytes(path3, bytes);

                    AssetDatabase.ImportAsset(path3);

                    TextureFormatHelper.ModifyTextureFormat(path3, "iPhone", format);
                    TextureFormatHelper.ModifyTextureFormat(path3, "Android", format);
                    TextureImporter texImporter = TextureImporter.GetAtPath(path3) as TextureImporter;
                    texImporter.isReadable = true;
                    
                    GameObject.DestroyImmediate(png, true);

                    RenderTexture.ReleaseTemporary(rt);

                    GameObject.DestroyImmediate(t, false);
                    GameObject.DestroyImmediate(t2, false);;
                    lightMapTemp[index] = path3;
                }
            }
        }
        Texture2DArray texture2DArray = new Texture2DArray(width, height, maxIndex + 1,TextureFormat.ASTC_4x4, true);

       
        foreach (var kp in lightMapTemp)
        {
            AssetDatabase.ImportAsset(kp.Value);
            Texture2D t = AssetDatabase.LoadAssetAtPath<Texture2D>(kp.Value);
            Graphics.CopyTexture(t, 0, texture2DArray, kp.Key);
            texture2DArray.Apply();
            GameObject.DestroyImmediate(t,true);
            AssetDatabase.DeleteAsset(kp.Value);
            //System.IO.File.Delete(kp.Value) ;
        }
        texture2DArray.wrapMode = TextureWrapMode.Clamp;
        texture2DArray.filterMode = FilterMode.Bilinear;
        string arrayPath = root + "\\"+ s.name + "_LMSM.asset";
        AssetDatabase.CreateAsset(texture2DArray,arrayPath);
        AssetDatabase.ImportAsset(arrayPath);
        ShadowMarkTex2dAry  sma = GameObject.FindObjectOfType<ShadowMarkTex2dAry>();
        if (null == sma)
        {
            GameObject g = null;
            if (null != Camera.main)
            {
                g = Camera.main.gameObject;
            }
            else
            {
                g = new GameObject("Camera");
                g.AddComponent<Camera>();
            }
            sma = g.AddComponent<ShadowMarkTex2dAry>();
        }
        sma.shadowMark = AssetDatabase.LoadAssetAtPath<Texture2DArray>(arrayPath);

        AddCmpToRender();

        //Texture2D empty = new Texture2D(1, 1,TextureFormat.RGBA32,false);
        //empty.SetPixel(0, 0, Color.white);
        for (int i = 0; i < found_paths.Count; i++)
        {
            var str = found_paths[i];
            //System.IO.File.WriteAllBytes(str,empty.EncodeToPNG());
            //AssetDatabase.ImportAsset(str);
            AssetDatabase.DeleteAsset(str);
        }

        EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene());
        //GameObject.DestroyImmediate(empty, true);

    }
    static void ClearAsset()
    {
        string root = AssetDatabase.GetAssetPath(Lightmapping.lightingDataAsset);
        root = root.Substring(0, root.LastIndexOf('/'));
        var s = UnityEngine.SceneManagement.SceneManager.GetActiveScene();
        string arrayPath = root + "\\" + s.name + "_LMSM.asset";
        Debug.LogError(arrayPath);
        AssetDatabase.DeleteAsset(arrayPath);
    }
    static void AddCmpToRender()
    {
        MeshRenderer [] mrs = GameObject.FindObjectsOfType<MeshRenderer>();
        for (int i = 0; i < mrs.Length; i++)
        {
            var m = mrs[i];
            if (m.gameObject.isStatic && m.gameObject.GetComponent<SetLightmapData>() == null)
            {
                m.gameObject.AddComponent<SetLightmapData>();
            }
        }
        
    }

    static void ClearCmpToRender()
    {
        MeshRenderer[] mrs = GameObject.FindObjectsOfType<MeshRenderer>();
        for (int i = 0; i < mrs.Length; i++)
        {
            var m = mrs[i];
            SetLightmapData c = m.gameObject.GetComponent<SetLightmapData>();
            if ( c != null)
            {
                GameObject.DestroyImmediate(c, true);
            }
        }
        ShadowMarkTex2dAry ctrl = GameObject.FindObjectOfType<ShadowMarkTex2dAry>();
        if (null != ctrl)
            GameObject.DestroyImmediate(ctrl, true);
    }
#endif

}
