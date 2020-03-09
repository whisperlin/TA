using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class FogCtrl : MonoBehaviour {


    [Range(0.001f,0.03f)]
    public float fogDensity;

    public bool fog = true;
    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        RenderSettings.fogDensity = fogDensity;
        RenderSettings.fog = fog;
    }
}
