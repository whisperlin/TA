using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;

public class CubeMapCreator : MonoBehaviour
{


    [MenuItem("TA/环境球/捕捉CubeMap")]
    static void CubeMapCreatorFun()
    {

        GameObject g = Selection.activeGameObject;
        if (g == null)
        {
            EditorUtility.DisplayDialog("提示", "你必须选择一个物体作为环境球的中心", "确定");
            return;
        }
        Cubemap ma = GetEnviromentAtPosition(g.transform.position);


        string path = EditorUtility.SaveFilePanelInProject("提示", "Cubemap", "cubemap",
                    "请输入保存文件名");
        if (path.Length != 0)
        {

            SaveAsset(path, ma);
        }
        else
        {
            GameObject.DestroyImmediate(ma);
        }

    }


    /*static Vector3 RotateAroundYInDegrees (Vector3 vertex, float degrees)
	{
		float alpha = degrees * Mathf.PI / 180.0;
		float sina, cosa;
		sina = Mathf.Sin (alpha);
		cosa = Mathf.Cos (alpha);
 
		Matrix2x2 m = Matrix2x2(cosa, -sina, sina, cosa);
		return float3(mul(m, vertex.xz), vertex.y).xzy;
	}*/
    [MenuItem("TA/环境球/捕捉Panoramic")]
    static void PanoramicCreatorFun()
    {

        GameObject g = Selection.activeGameObject;
        if (g == null)
        {
            EditorUtility.DisplayDialog("提示", "你必须选择一个物体作为环境球的中心", "确定");
            return;
        }
        Cubemap cubemap = GetEnviromentAtPosition(g.transform.position);

        
    }
    public static void SavePanoramic(Cubemap cubemap)
    {
        Material conversionMaterial = new Material(Shader.Find("Hidden/CubemapToEquirectangular"));
        RenderTexture renderTexture = RenderTexture.GetTemporary(4096, 2048, 24);
        Graphics.Blit(cubemap, renderTexture, conversionMaterial);

        RenderTexture rt2 = RenderTexture.GetTemporary(512, 256, 24);
        Graphics.Blit(renderTexture, rt2);

        var old = RenderTexture.active;
        RenderTexture.active = rt2;
        Texture2D equirectangularTexture = new Texture2D(512, 256, TextureFormat.ARGB32, false);
        equirectangularTexture.ReadPixels(new Rect(0, 0, rt2.width, rt2.height), 0, 0, false);
        equirectangularTexture.Apply();
        RenderTexture.active = old;
        RenderTexture.ReleaseTemporary(renderTexture);
        RenderTexture.ReleaseTemporary(rt2);

        string path = EditorUtility.SaveFilePanelInProject("提示", "Panoramic", "png",
                   "请输入保存文件名");
        if (path.Length != 0)
        {

            System.IO.File.WriteAllBytes(path, equirectangularTexture.EncodeToPNG());
            AssetDatabase.ImportAsset(path);
        }
        GameObject.DestroyImmediate(conversionMaterial);
        GameObject.DestroyImmediate(equirectangularTexture);
    }

    static void SaveAsset(string path, UnityEngine.Object obj)
    {
        UnityEngine.Object obj0 = AssetDatabase.LoadMainAssetAtPath(path);
        if (obj0 == null)
        {
            AssetDatabase.CreateAsset(obj, path);

        }
        else
        {

            EditorUtility.CopySerialized(obj, obj0);
            AssetDatabase.SaveAssets();
        }
    }

    static Cubemap GetEnviromentAtPosition(Vector3 position)
    {
        Cubemap cm = new Cubemap(512, TextureFormat.RGBA32, false);
        GameObject g = new GameObject();

        Camera cam = g.AddComponent<Camera>();
        cam.transform.position = position;
        cam.transform.rotation = Quaternion.identity;
        cam.RenderToCubemap(cm);
        GameObject.DestroyImmediate(g);

        return cm;
    }

    [MenuItem("TA/环境球/捕捉MapCap")]
    static void CreateMatcap()
    {

        GameObject g = Selection.activeGameObject;
        if (g == null)
        {
            EditorUtility.DisplayDialog("提示", "你必须选择一个物体作为环境球的中心", "确定");
            return;
        }
        Cubemap cubemap = GetEnviromentAtPosition(g.transform.position);

        Material conversionMaterial = new Material(Shader.Find("Hidden/CubemapToMatcap"));
     

        RenderTexture rt2 = RenderTexture.GetTemporary(512, 512, 24);
        Graphics.Blit(cubemap, rt2, conversionMaterial);

        var old = RenderTexture.active;
        RenderTexture.active = rt2;
        Texture2D equirectangularTexture = new Texture2D(512, 512, TextureFormat.ARGB32, false);
        equirectangularTexture.ReadPixels(new Rect(0, 0, rt2.width, rt2.height), 0, 0, false);
        equirectangularTexture.Apply();
        RenderTexture.active = old;
 
        RenderTexture.ReleaseTemporary(rt2);

        string path = EditorUtility.SaveFilePanelInProject("提示", "Matcap", "png",
                   "请输入保存文件名");
        if (path.Length != 0)
        {

            System.IO.File.WriteAllBytes(path, equirectangularTexture.EncodeToPNG());
            AssetDatabase.ImportAsset(path);
        }
        GameObject.DestroyImmediate(equirectangularTexture);
    }
}
