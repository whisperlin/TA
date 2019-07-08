using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[DisallowMultipleComponent]
public class DepthTextureType : MonoBehaviour {
    public DepthTextureMode mode = DepthTextureMode.Depth;
    Camera mCamera;
	// Use this for initialization
	void Start () {
        mCamera = GetComponent<Camera>();

    }
	
	// Update is called once per frame
	void Update () {
        mCamera.depthTextureMode = mode;

    }
}
