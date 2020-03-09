using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
[RequireComponent(typeof(MeshRenderer))]
[DisallowMultipleComponent]
public class SetLightmapData : MonoBehaviour
{
    public static bool openEffect = true;
    Renderer _render;
    private MaterialPropertyBlock prop;

    void SetData()
    {
        if(null == _render)
            _render = GetComponent<MeshRenderer>();
        if (null == prop)
            prop = new MaterialPropertyBlock();
        _render.GetPropertyBlock(prop);
        prop.SetFloat("_lightMapIndex", _render.lightmapIndex);
        _render.SetPropertyBlock(prop);
    }
    
    private void OnEnable()
    {
        SetData();
         
    }

#if UNITY_EDITOR
    void Update()
    {
        SetData();
    }
#endif
    
}
