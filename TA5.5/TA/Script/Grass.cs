using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Grass : MonoBehaviour {

    public bool fadePhysics = true;
	// Use this for initialization
	void Start () {
        Renderer [] rds = GetComponentsInChildren<Renderer>();
        for (int i = 0; i < rds.Length; i++)
        {
            Renderer r =  rds[i];
            var ms = r.materials;
            for (int j = 0; j < ms.Length; j++)
            {
                ms[j].EnableKeyword("_FADEPHY_ON");
            }
        }
	}
	
	 
}
