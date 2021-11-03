using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class WaterManager : MonoBehaviour
{
    public GameObject WaterPlane;
    public float WaterPlaneWidth = 10;
    public float WaterPlaneLength = 10;
    public float WaveRadius = 0.01f;
    public float WaveSpeed = 0.5f;
    public float WaveViscosity = 0.15f; //粘度
    public float WaveAtten = 0.98f; //衰减
    [Range(0, 0.999f)]
    public float WaveHeight = 0.999f;
    public int WaveTextureResolution = 512;
    public UnityEngine.UI.RawImage WaveMarkDebugImg;
    public UnityEngine.UI.RawImage PrevWaveTransmitDebugImg;
    private RenderTexture m_waterWaveMarkTexture;
    private RenderTexture m_prevWaveMarkTexture;
    private RenderTexture m_curRT;
    private RenderTexture m_prevRT;
    private Material m_waveTransmitMat;
    private Vector4 m_waveTransmitParams;
    private Vector4 m_waveMarkParams;

    
    // Start is called before the first frame update
    void OnEnable()
    {
        m_waterWaveMarkTexture = new RenderTexture(WaveTextureResolution, WaveTextureResolution, 0, RenderTextureFormat.Default);
        m_waterWaveMarkTexture.name = "m_waterWaveMarkTexture";
        m_waterWaveMarkTexture.wrapMode = TextureWrapMode.Repeat;

        m_prevWaveMarkTexture = new RenderTexture(WaveTextureResolution, WaveTextureResolution, 0, RenderTextureFormat.Default);
        m_prevWaveMarkTexture.name = "m_prevWaveMarkTexture";
        m_prevWaveMarkTexture.wrapMode = TextureWrapMode.Repeat;
        m_curRT = m_waterWaveMarkTexture;
        m_prevRT = m_prevWaveMarkTexture;

        m_waveTransmitMat = new Material(Shader.Find("Unlit/WaveTransmitShader"));

        Shader.SetGlobalTexture("_WaveResult", m_waterWaveMarkTexture);
        Shader.SetGlobalFloat("_WaveHeight", WaveHeight);

        if(null != WaveMarkDebugImg)
        WaveMarkDebugImg.texture = m_waterWaveMarkTexture;
        if (null != PrevWaveTransmitDebugImg)
            PrevWaveTransmitDebugImg.texture = m_prevWaveMarkTexture;
        InitWaveTransmitParams();
    }
    private void OnDisable()
    {
        if (null != m_waterWaveMarkTexture)
            GameObject.DestroyImmediate(m_waterWaveMarkTexture, true);
        if (null != m_prevWaveMarkTexture)
            GameObject.DestroyImmediate(m_prevWaveMarkTexture, true);
        if (null != m_waveTransmitMat)
            GameObject.DestroyImmediate(m_waveTransmitMat, true);
    }

    public void InitWaveTransmitParams()
    {
        float uvStep = 1.0f / WaveTextureResolution;
        float dt = Time.fixedDeltaTime;
        //最大递进粘性
        float maxWaveStepVisosity = uvStep / (2 * dt) * (Mathf.Sqrt(WaveViscosity * dt + 2));
        //粘度平方 u^2
        float waveVisositySqr = WaveViscosity * WaveViscosity;
        //当前速度
        float curWaveSpeed = maxWaveStepVisosity * WaveSpeed;
        //速度平方 c^2
        float curWaveSpeedSqr = curWaveSpeed * curWaveSpeed;
        //波单次位移平方 d^2
        float uvStepSqr = uvStep * uvStep;

        float i = Mathf.Sqrt(waveVisositySqr + 32 * curWaveSpeedSqr / uvStepSqr);
        float j = 8 * curWaveSpeedSqr / uvStepSqr;

        //波传递公式
        // (4 - 8 * c^2 * t^2 / d^2) / (u * t + 2) + (u * t - 2) / (u * t + 2) * z(x,y,z, t - dt) + (2 * c^2 * t^2 / d ^2) / (u * t + 2)
        // * (z(x + dx,y,t) + z(x - dx, y, t) + z(x,y + dy, t) + z(x, y - dy, t);

        //ut
        float ut = WaveViscosity * dt;
        //c^2 * t^2 / d^2
        float ctdSqr = curWaveSpeedSqr * dt * dt / uvStepSqr;
        // ut + 2
        float utp2 = ut + 2;
        // ut - 2
        float utm2 = ut - 2;
        //(4 - 8 * c^2 * t^2 / d^2) / (u * t + 2) 
        float p1 = (4 - 8 * ctdSqr) / utp2;
        //(u * t - 2) / (u * t + 2)
        float p2 = utm2 / utp2;
        //(2 * c^2 * t^2 / d ^2) / (u * t + 2)
        float p3 = (2 * ctdSqr) / utp2;

        m_waveTransmitParams.Set(p1, p2, p3, uvStep);

        Debug.LogFormat("i {0} j {1} maxSpeed {2}", i, j, maxWaveStepVisosity);
        Debug.LogFormat("p1 {0} p2 {1} p3 {2}", p1, p2, p3);
    }

    private void LateUpdate()
    {
        WaterPlaneCollider();
        WaveTransmit();
    }
    /*private void OnPreRender()
    {
        
    }*/

    Vector2 hitPos = Vector2.zero;
    bool hasHit = false;
    void WaterPlaneCollider()
    {
        hasHit = false;
        if (Input.GetMouseButton(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hitInfo = new RaycastHit();
            bool ret = Physics.Raycast(ray.origin, ray.direction, out hitInfo);
            if (ret)
            {
                
                Vector3 waterPlaneSpacePos = WaterPlane.transform.worldToLocalMatrix * new Vector4(hitInfo.point.x, hitInfo.point.y, hitInfo.point.z, 1);

                float dx = (waterPlaneSpacePos.x / WaterPlaneWidth) + 0.5f;
                float dy = (waterPlaneSpacePos.z / WaterPlaneLength) + 0.5f;
                dx = 1 - dx;
                dy = 1 - dy;

                hitPos.Set(dx, dy);
                m_waveMarkParams.Set(dx, dy, WaveRadius * WaveRadius, WaveHeight);
                //Debug.LogError(hitPos);
                hasHit = true;
            }
        }
    }

    void WaveTransmit()
    {
        m_waveTransmitMat.SetVector("_WaveTransmitParams", m_waveTransmitParams);
        m_waveTransmitMat.SetFloat("_WaveAtten", WaveAtten);

        if (hasHit)
        {
            m_waveTransmitMat.SetVector("_WaveMarkParams", m_waveMarkParams);
            m_waveTransmitMat.EnableKeyword("HIT");
        }
        else
        {
            m_waveTransmitMat.DisableKeyword("HIT");
        }
        Graphics.Blit(m_curRT, m_prevRT, m_waveTransmitMat);
        RenderTexture rt = m_curRT;
        m_curRT = m_prevRT;
        m_prevRT = rt;
    }
}
