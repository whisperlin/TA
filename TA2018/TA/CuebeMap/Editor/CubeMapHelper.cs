using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class CubeMapHelper  {

	[MenuItem("TA/工具/保存cubemap")]
	static void BuildCubeMap () {

        if (Selection.activeGameObject == null)
            return;
        Camera cam =  Selection.activeGameObject.AddComponent<Camera>();

        Renderer r = Selection.activeGameObject.GetComponent<Renderer>();
        if (null != r)
            r.enabled = false;
        Cubemap cuebmap = new Cubemap(512, TextureFormat.RGB24, false);
        cam.RenderToCubemap(cuebmap);



        if (null != r)
            r.enabled = true;

        string path = EditorUtility.SaveFilePanelInProject("save", "default", "cubemap", "保存文件");
        if (path.Length > 0)
        {
            AssetDatabase.CreateAsset(cuebmap, path);
            AssetDatabase.ImportAsset(path);
            if (null != r)
            {
                path = path.Replace('.', '_')+".mat";
                Material mat = new Material(Shader.Find("TA/Tools/CubeMapBox"));
                mat.SetTexture("_CubeMap", cuebmap);
                r.sharedMaterial = mat;
                AssetDatabase.CreateAsset(mat, path);
                AssetDatabase.ImportAsset(path);
            }
        }
        
        GameObject.DestroyImmediate(cam);
    }
	
	 
}
