
using UnityEngine;
public enum DepthGodRaytModel
{
    NORMAL,
    DEVELOP1,
    DEVELOP2,
}
[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class DepthGodRays : MonoBehaviour
{
    [Label("深度控制阈值", 0.0f, 1.0f)]
    public float depthThreshold = 0.8f;
    [Label("光源偏移距离",0f,0.1f)]
    public float offsetLen = 0.05f;
    [Label("产生体积光的范围", 0.0f, 1.0f)]
    public float lightRadius = 2.0f;
    [Label("体积光颜色", 0.0f, 1.0f)]
    public Color lightColoHDR = Color.white;
    [Label("中心颜色", 0.0f, 1.0f)]
    public Color centerColor = Color.black;
    [Label("降低分辨率倍率", 2, 5)]
    public int downSample = 4;
    [Label("光源位置")]
    public Transform lightTransform;
    [Label("噪点")]
    public Texture2D noise;
    [Label("噪点控制")]
    public Vector4 noise_ST = new Vector4(100f, 100f, 1f, 1f);

    public Camera targetCamera = null;
    public Material _Material;

    public DepthGodRaytModel model = DepthGodRaytModel.NORMAL;
    void Awake()
    {
        targetCamera = GetComponent<Camera>();
    }
    void OnEnable()
    {
        targetCamera.depthTextureMode = DepthTextureMode.Depth;
    }
    void OnDistable()
    {
        targetCamera.depthTextureMode = DepthTextureMode.None;
    }
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_Material && targetCamera)
        {
            Vector3 dir0 = lightTransform.forward;
            Vector3 dir1 = transform.forward;
            dir0.y = 0;
            dir1.y = 0;
            float d = Vector3.Dot(dir0.normalized, dir1.normalized);
            if (d > 0)
            {
                Graphics.Blit(source, destination);
                return ;
            }
            _Material.SetTexture("_Noise", noise);
            _Material.SetVector("_Noise_ST", noise_ST);
            _Material.EnableKeyword("NOISE_TEXTURE");
            _Material.SetFloat("_OffsetLen", offsetLen);
            _Material.SetColor("_Color", centerColor);
            int rtWidth = source.width >> downSample;
            int rtHeight = source.height >> downSample;
            RenderTexture temp1 = RenderTexture.GetTemporary(rtWidth, rtHeight, 0, source.format);

            Vector3 viewPortLightPos = new Vector3(.5f, .5f, 0);
            if (null != lightTransform)
            {
                Vector3 worldPos = transform.position + lightTransform.forward * 1000f;
                viewPortLightPos = targetCamera.WorldToViewportPoint(worldPos);
            }
            _Material.SetVector("_ViewPortLightPos", new Vector4(viewPortLightPos.x, viewPortLightPos.y, viewPortLightPos.z, 0));
            _Material.SetFloat("_LightRadius", lightRadius);
            _Material.SetFloat("_DepthThreshold", depthThreshold);
            Graphics.Blit(source, temp1, _Material, 0);

            if (model == DepthGodRaytModel.DEVELOP1)
            {
                Graphics.Blit(temp1, destination);
                RenderTexture.ReleaseTemporary(temp1);
                return;
            }

            _Material.SetVector("_ViewPortLightPos", new Vector4(viewPortLightPos.x, viewPortLightPos.y, viewPortLightPos.z, 0));
            _Material.SetFloat("_LightRadius", lightRadius);

            RenderTexture temp2 = RenderTexture.GetTemporary(rtWidth, rtHeight, 0, source.format);
            Graphics.Blit(temp1, temp2, _Material, 1);

            if (model == DepthGodRaytModel.DEVELOP2)
            {
                Graphics.Blit(temp2, destination);
                RenderTexture.ReleaseTemporary(temp1);
                return;
            }
            _Material.SetTexture("_BlurTex", temp2);
            _Material.SetVector("_LightColor", lightColoHDR);

            Graphics.Blit(source, destination, _Material, 2);
            RenderTexture.ReleaseTemporary(temp1);
            RenderTexture.ReleaseTemporary(temp2);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
 
