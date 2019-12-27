using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SetHitData : MonoBehaviour {

    static string[] prop_names = new string[] {"_HitData0", "_HitData1", "_HitData2", "_HitData3", "_HitData4" };
    public float radius = 1;
    [Range(0,4)]
    public int index = 0;
 
     
	// Update is called once per frame
	void Update () {
 
        Shader.SetGlobalVector(prop_names[index], new Vector4(transform.position.x, transform.position.y, transform.position.z, radius));
    }
    private void OnDisable()
    {
        Shader.SetGlobalVector(prop_names[index], new Vector4(0, 0,0, 0));
    }
    
}
