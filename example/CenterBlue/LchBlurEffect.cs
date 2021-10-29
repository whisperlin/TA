using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

#if UNITY_EDITOR
using UnityEditor;
#endif

[RequireComponent(typeof(Camera))]
[RequireComponent(typeof(ImageEffectManager))]
[ExecuteInEditMode]

public class LchBlurEffect : MonoBehaviour, LchImageEffectInterface
{
    static public LchBlurEffect glboalLchBlurEffect;
    [Range(0f, 0.02f)]
    public float offset = 0.01f;
    public Shader shader;

 
#if UNITY_EDITOR
    public Material mat;
#else
      Material mat;
#endif

    ImageEffectManager mgr = null;
    private void OnEnable()
    {
        if (null == mgr)
            mgr = GetComponent<ImageEffectManager>();
        mgr.Add(this);
        glboalLchBlurEffect = this;
    }
    private void OnDisable()
    {
        if (null == mgr)
            mgr = GetComponent<ImageEffectManager>();
        mgr.Remove(this);
        if (glboalLchBlurEffect == this)
            glboalLchBlurEffect = null;
    }
    Camera cam;
    public void SetTargatPosition(Vector3 pos)
    {
        if (null == cam)
            cam = GetComponent<Camera>();

        Vector3 p =  cam.WorldToScreenPoint( pos );
        Vector4 uv = new Vector4(p.x / cam.pixelWidth, p.y/cam.pixelHeight, 0, 1);
        Debug.Log(uv);
        mat.SetVector(_Center, uv);

    }
    void Start()
    {

    }
    void OnDestroy()
    {
    }
    void InitData()
    {
        if (null == shader)
            shader = Shader.Find("Hidden/Lch/BlurEffect");
        if (null == mat)
            mat = new Material(shader);
 

    }
#if UNITY_EDITOR
    private void Update()
    {

        InitData();
    }
#endif
    static int _Offset = Shader.PropertyToID("_Offset");
    static int _Center = Shader.PropertyToID("_Center");


    private void LateUpdate()
    {
        mat.SetFloat(_Offset, offset);
        
    }

    public void OnRenderImageEffect(RenderTexture source, RenderTexture destination)
    {
        InitData();
        
        Graphics.Blit(source, destination, mat);

    }

    int LchImageEffectInterface.GetPriority()
    {
        return 0;
    }

    bool LchImageEffectInterface.isEffectEnable()
    {
        return true;
    }

}
