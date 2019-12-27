using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
[RequireComponent(typeof(MeshRenderer))]
public class SetBoxProjectReflectData : MonoBehaviour {
    public Cubemap cube;
    public BoxProjectReflectMaker maker;
    public MeshRenderer mr;
	// Use this for initialization
	void Start () {
        mr = GetComponent < MeshRenderer > ();
        mr.sharedMaterial.SetTexture("_Cube", cube);
    }
	
	// Update is called once per frame
	void Update () {
        mr.sharedMaterial.SetVector("cubemapCenter", new Vector4(maker.transform.position.x, maker.transform.position.y, maker.transform.position.z,1f));
        var v1 = maker.transform.position - maker.scale / 2;
        mr.sharedMaterial.SetVector("boxMin",new Vector4(v1.x, v1.y, v1.z,1) );
        var v2 = maker.transform.position + maker.scale / 2;
        mr.sharedMaterial.SetVector("boxMax", new Vector4(v2.x, v2.y, v2.z, 1) );
         
        //mr.set
    }
}
