using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum REFLECTION_TEXTURE_SIZE
{
    s1 = 1,
    s2 = 3,
    s4 = 4,
}
[ExecuteInEditMode]
public class Reflection : MonoBehaviour
{
    public REFLECTION_TEXTURE_SIZE textureSise = REFLECTION_TEXTURE_SIZE.s2;
    public Camera targetCamera;

    public Camera reflectionCamera;

    public RenderTexture rt;

    public LayerMask cullMark = -1;


    // Update is called once per frame
    void LateUpdate()
    {

        if (null == targetCamera)
            targetCamera = Camera.main;
        if (null == targetCamera)
            return;
        if (null == reflectionCamera)
        {
            GameObject g = new GameObject("Reflection Camera");
            g.name = "Reflection Camera";
            g.transform.parent = transform;
            reflectionCamera = g.AddComponent<Camera>();
        }
        reflectionCamera.targetTexture = null;

        Vector3 lossyScale = transform.lossyScale;
        Vector3 localScale = transform.localScale;

        lossyScale.x = Mathf.Max(lossyScale.x, 0.00000001f);
        lossyScale.y = Mathf.Max(lossyScale.y, 0.00000001f);
        lossyScale.z = Mathf.Max(lossyScale.z, 0.00000001f);
        transform.localScale = new Vector3(localScale.x / lossyScale.x, localScale.y / lossyScale.y, localScale.z / lossyScale.z);

        LchCommonResource.CheckRT(ref rt, targetCamera.pixelWidth / (int)textureSise, targetCamera.pixelHeight / (int)textureSise, 16,RenderTextureFormat.Default,true);
 
        reflectionCamera.transform.parent = transform;
        reflectionCamera.CopyFrom(targetCamera);
        reflectionCamera.targetTexture = rt;
        reflectionCamera.cullingMask = cullMark;
        reflectionCamera.enabled = false;
        var t = targetCamera.transform;
        var t2 = reflectionCamera.transform;
        var local = transform.worldToLocalMatrix.MultiplyPoint(t.position);
        local.y = -local.y;
        t2.localPosition = local;
        var forward = t.forward;
        forward.y = -forward.y;
        t2.forward = forward;
        var projectionMatrix = GL.GetGPUProjectionMatrix(reflectionCamera.projectionMatrix, false);
        var vp = projectionMatrix * t2.worldToLocalMatrix;
        Shader.SetGlobalMatrix("_LchReflectionMatrix", vp);
        Shader.SetGlobalTexture("_LchReflectionTex", rt);
        reflectionCamera.Render();
        
    }

    private void OnDisable()
    {
        reflectionCamera.targetTexture = null;
        LchCommonResource.SafeRelease(ref rt);
    }
}
