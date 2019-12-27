using System.Collections;
using System.Collections.Generic;
using UnityEngine;
 
[RequireComponent(typeof(MeshRenderer))]
public class SharedLightMap : MonoBehaviour {


    public MeshRenderer target;
    MeshRenderer selfMr;
    void CopyLightMapData(MeshRenderer src , MeshRenderer target)
    {
        target.lightmapIndex = src.lightmapIndex;
  
        target.lightmapScaleOffset = src.lightmapScaleOffset;
        
        target.realtimeLightmapIndex = src.realtimeLightmapIndex;
        target.realtimeLightmapScaleOffset = src.realtimeLightmapScaleOffset;
        target.gameObject.isStatic = true;
    }

    void UpdateData()
    {
        if (null == selfMr)
            selfMr = GetComponent<MeshRenderer>();
        if (null == target)
            return;
        CopyLightMapData(target, selfMr);
    }
	// Use this for initialization
	void Start () {

        UpdateData();

    }
	
	// Update is called once per frame
	void Update () {
        UpdateData();
    }
}
