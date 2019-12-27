using System.Collections;
using System.Collections.Generic;
using UnityEngine;
 
public class RenderCubeMap : MonoBehaviour {

    Camera mCamera;
    public Cubemap cube;
    public MeshRenderer r;
	// Use this for initialization
	void Start () {
        mCamera = GetComponent<Camera>();
        cube = new Cubemap(128,TextureFormat.ARGB32,false);
        r = GetComponent<MeshRenderer>();
        

    }
	
	// Update is called once per frame
	void Update () {
        r.enabled = false;
        mCamera.RenderToCubemap(cube);
        r.enabled = true;
        r.sharedMaterial.SetTexture("_Cube", cube);
        


    }
}
