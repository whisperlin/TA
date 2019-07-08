using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetHitData : MonoBehaviour {

    public float radius = 1;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        Shader.SetGlobalVector("_HitData0", new Vector4(transform.position.x, transform.position.y, transform.position.z, radius));
        

    }
}
