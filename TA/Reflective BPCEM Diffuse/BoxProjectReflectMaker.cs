using System;
using System.Collections;
using System.Collections.Generic;
#if UNITY_EDITOR
using UnityEditor;
#endif

using UnityEngine;
[ExecuteInEditMode]
 
public class BoxProjectReflectMaker : MonoBehaviour {
    public Vector3 scale = new Vector3(10,10,10);

#if UNITY_EDITOR

    private RenderTexture target;
    public Cubemap cube;
    private Material mat;

    private GameObject plane;
    [Header("开发者模式")]
    public bool develop = true;
    Camera cam;

    private void OnDestroy()
    {
        GameObject.DestroyImmediate(cube,false);
        GameObject.DestroyImmediate(mat, false);
        GameObject.DestroyImmediate(target, false);
        GameObject.DestroyImmediate(plane, false);
        
    }

    [MenuItem("TA/环境球/创建Box Project CubeMap")]
    static void CreateReflectMaker()
    {
        GameObject g = new GameObject("BoxProjectReflectMaker");
        g.AddComponent<BoxProjectReflectMaker>();
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


 
    void OnDrawGizmos()
    {
        if (develop)
        {
            Gizmos.color = new Color(0, 0, 1, 0.2F);
            Gizmos.DrawCube(transform.position, scale);
        }
    }


#endif


    public void Save()
    {
#if UNITY_EDITOR
        SavePanoramic(cube);
#endif
    }
    // Use this for initialization
    void Start () {
        
         
    }
	
	// Update is called once per frame
	void Update () {
         
        if (null == cam)
        {
            GameObject  g = new GameObject();
            cam = g.AddComponent<Camera>();
            g.hideFlags = HideFlags.HideAndDontSave;
            cam.enabled = false;
            g.transform.parent = transform;
            g.transform.localPosition = Vector3.zero;
            g.transform.forward = Vector3.forward;
        }

        this.transform.forward = Vector3.forward;
#if UNITY_EDITOR

        if (develop)
        {
            // GameObject plane = GameObject.CreatePrimitive(PrimitiveType.Plane);
            if (null == target)
            {
                target = new RenderTexture(512, 256, 0);
                target.hideFlags = HideFlags.DontSave;
            }

            if (null == cube)
            {
                cube = new Cubemap(512, TextureFormat.RGBA32, false);
                cube.hideFlags = HideFlags.DontSave;
            }
            if (null == plane)
            {
                plane = GameObject.CreatePrimitive(PrimitiveType.Plane);
                //plane.hideFlags = HideFlags.HideAndDontSave;
                plane.transform.parent = transform;
                plane.transform.localPosition = Vector3.zero;
                plane.transform.localScale = Vector3.one;
                plane.transform.localRotation = Quaternion.identity;

            }
            if (null == mat)
            {
                mat = new Material(Shader.Find("TA/BoxProjectSkyReflection"));
                plane.GetComponent<MeshRenderer>().sharedMaterial = mat;


            }
            
            mat.SetTexture("_Cube", cube);

            mat.SetVector("cubemapCenter", new Vector4(transform.position.x, transform.position.y, transform.position.z, 1f));
            var v1 = transform.position - scale / 2;
            mat.SetVector("boxMin", new Vector4(v1.x, v1.y, v1.z, 1));
            var v2 = transform.position + scale / 2;
            mat.SetVector("boxMax", new Vector4(v2.x, v2.y, v2.z, 1));
            plane.transform.parent = null;
            plane.transform.localScale = scale / 10;
            plane.transform.forward = Vector3.forward;
            plane.transform.position = transform.position;
            plane.hideFlags = HideFlags.HideAndDontSave;
            plane.SetActive(false); 
            cam.RenderToCubemap(cube);
            plane.SetActive(true);
            plane.SetActive(true);
        }
        else
        {
            if(plane)
                plane.SetActive(false);
        }
        

#endif
    }



}
