using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class LensFare : MonoBehaviour {

    public Vector3 sun = new Vector3(0,180,0);
    public Texture2D sunTexure;
    public int sunCount = 5;
    public float sunRange = 0.3f;
    public Vector4[] indexs = new Vector4[] { 
        new Vector4(0,0f,0.3f,1f)
    };
    [Range(0f,0.5f)]
    public float sun_radius = 0.1f;
    
    public LayerMask occludieMark = - 1;
    public bool enbaleReplayShader = true;
#if UNITY_EDITOR
    public bool develop = false;
#endif

    Camera mCamera;
    Camera mOccludieCamera;
    Transform mOccludieCameraTransform;
    
    
    public Shader shader;
    public Shader shaderAvg;
    public Shader shaderSpr;
    public RenderTexture rt;
    public RenderTexture rt1x1;
    public float length = 500;

 
    GameObject sunObj;
    Mesh mesh;
    Vector3 [] vs;
    Vector2[] uvs;
    Color[] cols;
    int[] tras;

    void InitArray(int count)
    {
        if (vs == null || vs.Length != count*4)
        {
            vs = new Vector3[count*4];
        }
        if (uvs == null || uvs.Length != count * 4)
        {
            uvs = new Vector2[count * 4];
        }
        if (cols == null || cols.Length != count * 4)
        {
            cols = new Color[count * 4];
        }
        if (tras == null || tras.Length != count * 6)
        {
            tras = new int[count * 6];
        }
        
        
    }
 
    Material copyMat;
    Material sunMat;
    // Use this for initialization
    void Start () {
		
	}
    
    Vector3 LerpV(Vector3 v1, Vector3 v2, float t)
    {
        float t2 = 1.0f - t;
        return v1 * t2 + v2 * t;
    }
    // Update is called once per frame
    void Update()
    {
        
		var _SunDirect = Quaternion.Euler(sun) * Vector3.forward;
		if (null == mCamera)
			mCamera = GetComponent<Camera>();
		var _CameraDir = mCamera.transform.forward;
		float  sdotv = Vector3.Dot(_SunDirect, _CameraDir);
		Debug.Log ("sdotv"+sdotv);
		Shader.SetGlobalVector("_SunDirect", new Vector4(_SunDirect.x, _SunDirect.y, _SunDirect.z, 1.0f - sun_radius));

#if UNITY_EDITOR
        if (develop)
        {
            Shader.EnableKeyword("DEVELOP_SKY_BOX");
        }
        else
        {
            Shader.DisableKeyword("DEVELOP_SKY_BOX");
        }
        shader = Shader.Find("TA/Hidden/LensFlareOcclusion");
        shaderAvg = Shader.Find("TA/Hidden/Average");
        shaderSpr = Shader.Find("TA/Hidden/SunLensFlare");
#endif

        

        if (null == sunTexure)
            return;

        

        length = mCamera.farClipPlane - mCamera.nearClipPlane;
        Vector3 mainPointPos = transform.position;
        Vector3 farClipPlanePos = mainPointPos + _SunDirect * length;
        Vector3 viewPos = mCamera.worldToCameraMatrix.MultiplyPoint(farClipPlanePos);
        Vector3 projPos = mCamera.projectionMatrix.MultiplyPoint(viewPos);


        float wh = ((float)Screen.height) / ((float)Screen.width);

        bool b = sdotv > 0 && Mathf.Abs(projPos.x)-1f < sunRange* wh && Mathf.Abs(projPos.y)-1f < sunRange;

        bool vis = Application.isPlaying;
#if UNITY_EDITOR
        b = b && (develop || vis);
 
 
#endif
            //Debug.Log("sdotv = " + sdotv);
            if (null != sunObj)
            sunObj.SetActive(b);
        if (!b)
        {
            return;
        }

        float delta = 1.0f / sunCount;
        if (null == sunMat)
        {
            sunMat = new Material(shaderSpr);
        }
        sunMat.SetTexture("_MainTex", sunTexure);

        sunMat.SetTexture("_AlphaTex", rt1x1);
 
        if (null == rt)
        {
            rt = new RenderTexture(32, 32, 16);
            rt.hideFlags = HideFlags.DontSave;
        }
        if (null == rt1x1)
        {
            rt1x1 = new RenderTexture(1, 1, 16);
            rt1x1.hideFlags = HideFlags.DontSave;
        }
        if (null == mOccludieCamera)
        {
            GameObject g = new GameObject("OccludieCamera");
            mOccludieCamera = g.AddComponent<Camera>();
            mOccludieCameraTransform = g.transform;
            mOccludieCamera.clearFlags = CameraClearFlags.SolidColor;
            mOccludieCamera.orthographic = true;
            mOccludieCamera.orthographicSize = 0.2f;
            //mOccludieCamera.enabled = false;
            mOccludieCamera.targetTexture = rt;
            g.hideFlags = HideFlags.DontSave;
            mOccludieCamera.backgroundColor = Color.white;
        }
        mOccludieCamera.enabled = false;
        

        
        

        int count = indexs.Length;
       
       

#if UNITY_EDITOR
 
    if (develop || vis)
#else
    if (vis)
#endif
        //if (vis)
        {
           
            InitArray(count);
            if (null == mesh)
            {
                mesh = new Mesh();
                mesh.MarkDynamic();
                mesh.bounds = new Bounds(Vector3.zero, new Vector3(100000, 100000, 100000));
                mesh.hideFlags = HideFlags.DontSave;
            }
            mesh.Clear();
           
            
            for (int i = 0; i < count; i++)
            {
                var ids = indexs[i];
                int _id = (int)ids.x;

                float u0 = delta * _id;
                float u1 = u0 + delta;
                int i0 = i * 4;
                int b0 = i0;
                Vector3 _pos = LerpV(projPos,Vector3.zero, ids.y);
                //{ new Vector3(-1, -1, 0.1f), new Vector3(1, -1, 0.1f), new Vector3(-1, 1, 0.1f), new Vector3(1, 1, 0.1f) };
                vs[i0++] = new Vector3(-ids.z* wh + _pos.x, -ids.z + _pos.y, 0.1f);
                vs[i0++] = new Vector3( ids.z* wh + _pos.x, -ids.z + _pos.y, 0.1f);
                vs[i0++] = new Vector3(-ids.z* wh + _pos.x,  ids.z + _pos.y, 0.1f);
                vs[i0++] = new Vector3( ids.z* wh + _pos.x,  ids.z + _pos.y, 0.1f);
                i0 = i * 4;

                cols[i0++] = new Color(ids.w, ids.w, ids.w);
                cols[i0++] = new Color(ids.w, ids.w, ids.w);
                cols[i0++] = new Color(ids.w, ids.w, ids.w);
                cols[i0++] = new Color(ids.w, ids.w, ids.w);

                i0 = i * 4;
                //{ new Vector2(u0, 0), new Vector2(u1, 0), new Vector2(u0, 1), new Vector2(u1, 1) };
                uvs[i0++] = new Vector2(u0, 0);
                uvs[i0++] = new Vector2(u1, 0);
                uvs[i0++] = new Vector2(u0, 1);
                uvs[i0++] = new Vector2(u1, 1);
                i0 = i * 6;
                tras[i0++] = b0+0;
                tras[i0++] = b0+2;
                tras[i0++] = b0+1;
                tras[i0++] = b0+1;
                tras[i0++] = b0+2;
                tras[i0++] = b0+3;

                
            }
            mesh.vertices = vs;
            mesh.uv = uvs;
            mesh.colors = cols;
            mesh.triangles = tras;
            mesh.bounds = new Bounds(Vector3.zero, new Vector3(100000, 100000, 100000));
            if (null == sunObj)
            {
                GameObject g = new GameObject("Sun sprite");
                g.hideFlags = HideFlags.DontSave;
                MeshFilter mf = g.AddComponent<MeshFilter>();
                mf.mesh = mesh;
                MeshRenderer mr = g.AddComponent<MeshRenderer>();
                mr.material = sunMat;
                sunObj = g;
            }
        }
        else
        {
            //ResizedArray(0);
        }

         

#if UNITY_EDITOR

        Debug.DrawLine(mainPointPos, farClipPlanePos, Color.green);
#endif
        if (null == copyMat)
        {
            copyMat = new Material(shaderAvg);
        }
        //mOccludieCamera.clearFlags = CameraClearFlags.Skybox;
        mOccludieCamera.cullingMask = occludieMark;
        mOccludieCamera.transform.position = mainPointPos ;
        mOccludieCamera.transform.forward = farClipPlanePos-mainPointPos;
        mOccludieCamera.ResetReplacementShader();
        if (enbaleReplayShader)
        {
            mOccludieCamera.RenderWithShader(shader, null);
        }
        else
        {
            mOccludieCamera.Render(); ;
        }
            
        
           


        Graphics.Blit(rt, rt1x1, copyMat);
        mOccludieCamera.farClipPlane = mCamera.farClipPlane;
        mOccludieCamera.nearClipPlane = mCamera.nearClipPlane;

        Vector3 screen_pos =  mCamera.WorldToScreenPoint(farClipPlanePos);
        


        
    }

     
    void OnDrawGizmosSelected()
    {

        var _SunDirect = Quaternion.Euler(sun) *Vector3.forward;

        
        Gizmos.color = Color.red;
        Gizmos.DrawSphere(transform.position + _SunDirect * length,  1+length/30);
    }
}
