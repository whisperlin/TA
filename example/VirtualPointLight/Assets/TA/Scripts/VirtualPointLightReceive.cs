using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[RequireComponent(typeof(Renderer))]
[ExecuteInEditMode]
public class VirtualPointLightReceive : MonoBehaviour
{
    public VirtualPointLight light;

    Renderer _renderer;

    // Start is called before the first frame update
    void Start()
    {
        _renderer = GetComponent<Renderer>();
       
        //Renderer r = GetComponent<Renderer>();
        //r.materials;
    }
    MaterialPropertyBlock props;
    // Update is called once per frame
    void Update()
    {
        if (light != null)
        {
            if(null == _renderer)
                _renderer = GetComponent<Renderer>();
            if(null == props)
                props = new MaterialPropertyBlock();
            Vector4 data = light.transform.position;
            data.w = 1.0f/light.range  ;
            Vector4 col = light.color;
            _renderer.GetPropertyBlock(props);
            props.SetVector("_VirtualPointLightPos", data);
            props.SetVector("_VirtualPointLightColor", col);
            _renderer.SetPropertyBlock(props);

        }
    }
}
