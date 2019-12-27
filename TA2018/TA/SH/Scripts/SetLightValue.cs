using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetLightValue : MonoBehaviour
{
    [Label("光照范围", -1f, 1f)]
    public float RoleLightPower = 0;
    // Start is called before the first frame update
    private void OnEnable()
    {
        SetGlobalSH9[] gs  = GameObject.FindObjectsOfType<SetGlobalSH9>();
        for (int i = 0; i < gs.Length; i++)
        {
            gs[i].RoleLightPower = RoleLightPower;
        }
    }

     
}
