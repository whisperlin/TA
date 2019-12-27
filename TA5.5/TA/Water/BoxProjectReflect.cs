using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
[ExecuteInEditMode]
public class BoxProjectReflect : MonoBehaviour {

    public BoxProjectReflectMaker maker;
    public MeshRenderer mr;
    // Use this for initialization
    void Start() {

    }
    private void OnDestroy()
    {
        if (null == mr)
            mr = GetComponent<MeshRenderer>();
        var mat = mr.sharedMaterial;
        mat.DisableKeyword("BOX_PROJECT_SKY_BOX");
    }
    // Update is called once per frame
    void Update () {
        if (null == mr)
            mr = GetComponent<MeshRenderer>();

        
        var mat = mr.sharedMaterial;
        if (null == maker)
        {
            mat.DisableKeyword("BOX_PROJECT_SKY_BOX");
        }
        else
        {
            mat.EnableKeyword("BOX_PROJECT_SKY_BOX");
            mat.SetVector("cubemapCenter", new Vector4(maker.transform.position.x, maker.transform.position.y, maker.transform.position.z, 1f));
            var v1 = maker.transform.position - maker.scale / 2;
            mat.SetVector("boxMin", new Vector4(v1.x, v1.y, v1.z, 1));
            var v2 = maker.transform.position + maker.scale / 2;
            mat.SetVector("boxMax", new Vector4(v2.x, v2.y, v2.z, 1));
#if UNITY_EDITOR
            mat.SetTexture("_Cube", maker.cube);
#endif

        }
        
       
        

    }
}
