using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class VirtualPointLightReceive : MonoBehaviour
{
    public VirtualPointLight light;

    // Start is called before the first frame update
    void Start()
    {
        //Renderer r = GetComponent<Renderer>();
        //r.materials;
    }

    // Update is called once per frame
    void Update()
    {
        if (light != null)
        {
            Vector4 data = light.transform.position;
            data.w = 1.0f/light.range  ;
            Shader.SetGlobalVector("_VirtualPointLightPos", data);
            Vector4 col = light.color;
            Shader.SetGlobalVector("_VirtualPointLightColor", col);

        }
    }
}
