using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[DisallowMultipleComponent]
[ExecuteInEditMode]
public class ShadowMarkTex2dAry : MonoBehaviour
{
 
    public Texture2DArray shadowMark;
    // Start is called before the first frame update
    void Start()
    {
        
    }
    private void OnEnable()
    {
        if (null != shadowMark)
        {
            Shader.SetGlobalTexture("CmbShadowMark", shadowMark);

            Shader.EnableKeyword("COMBINE_SHADOWMARK");
        }
    }

#if UNITY_EDITOR
    // Update is called once per frame
    void Update()
    {
        if (null != shadowMark)
        {
            Shader.SetGlobalTexture("CmbShadowMark", shadowMark);

            Shader.EnableKeyword("COMBINE_SHADOWMARK");
        }
    }
#endif
    private void OnDisable()
    {
        Shader.DisableKeyword("COMBINE_SHADOWMARK");
    }
}
