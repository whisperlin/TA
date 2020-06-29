using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class ReplaymentShader : MonoBehaviour
{
    public Shader shader;
    public bool isWork = true;
    public Camera cam;
    public bool fromShadowMark = true;
    private void OnEnable()
    {
        cam = GetComponent<Camera>();
    }
    private void OnDisable()
    {
        
    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (null != shader && isWork)
        {
            cam.SetReplacementShader(shader, "");
        }
        else
        {
            cam.ResetReplacementShader();
            
        }
        if (fromShadowMark)
        {
            Shader.EnableKeyword("FROM_SHADOW_MARK");
        }
        else
        {
            Shader.DisableKeyword("FROM_SHADOW_MARK");
        }
    }
}
