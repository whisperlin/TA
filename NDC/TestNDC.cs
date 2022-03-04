using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[RequireComponent(typeof(Camera))]
 
public class TestNDC : MonoBehaviour
{
    public MeshFilter mf;
 
    Camera cam;


    public Material mat;
    // Start is called before the first frame update
    void Start()
    {
        
    }
    Mesh mesh = null;
    private void OnEnable()
    {
        
    }
    private void OnDisable()
    {
        if (null != mesh)
        {
            GameObject.DestroyImmediate(mesh, true);
            mesh = null;
        }

    }
    
    // Update is called once per frame
    void LateUpdate()
    {
        if (null == cam)
            cam = GetComponent<Camera>();
        if (cam.orthographic)
        {
            mat.EnableKeyword("ORTHOGRAPHIC");
        }
        else
        {
            mat.DisableKeyword("ORTHOGRAPHIC");
        }

        mat.DisableKeyword("IGORE_VP");
        if (null != mat)
        {
            if (null == cam)
                cam = GetComponent<Camera>();
 
            mesh = MeshHelper.GetFullScreenWorld(cam, ref mesh);
            if (null != mf)
                mf.sharedMesh = mesh;
            Graphics.DrawMesh(mesh,transform.position,transform.rotation, mat, 0, cam);
        }
    }
        
}
