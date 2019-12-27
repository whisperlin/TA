using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class GrasslNormalDir : MonoBehaviour {

    
    public bool alwayUpdate = true;
    public Vector3 angle;

    void SetParams()
    {
        var v = Matrix4x4.TRS(Vector3.zero, Quaternion.Euler(new Vector3(angle.x, angle.y, angle.z)), Vector3.one).MultiplyVector(Vector3.back);
        v.Normalize();
    }

    private void OnDisable()
    {
        
    }
    // Use this for initialization
    void Start () {
        SetParams();
    }
	
	// Update is called once per frame
	void Update () {
        SetParams();
    }
}
