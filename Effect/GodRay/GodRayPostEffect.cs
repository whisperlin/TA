using UnityEngine;

/*public enum GodRayPostEffectModel
{
    [EnumAttirbute("深度模式")]
    Depth = 0,
    [EnumAttirbute("颜色模式")]
    Color = 1,
    [EnumAttirbute("颜色和深度模式")]
    DepthAndColor = 2,
}*/

public enum GodRayPostEffectDevModel
{
    NORMAL,
    DEVELOP1,
    DEVELOP2,
}

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class GodRayPostEffect : MonoBehaviour
{
    //[CNEnum(typeof(GodRayPostEffectModel), "高亮提取模式")]
    //public GodRayPostEffectModel model = GodRayPostEffectModel.Color;

    [Label("深度提取")]
    public bool depthEnabel = true;
    [Label("深度控制阈值", "depthEnabel")]
    [Range(0.0f, 1.0f)]
    public float depthThreshold = 0.8f;
    [Label("颜色提取阙值")]
    public bool colorEnable = false;
    [Label("高亮部分提取阈值", "colorEnable")]
    public Color colorThreshold = new Color(0.25f,0.25f,0.25f,1);

    [Label("提取高亮结果Pow倍率，适当降低颜色过亮的情况", "colorEnable")]
    [Range(1f, 4.0f)]
    public float lightPowFactor = 1.0f;

    [Label("光源最大限制", "colorEnable")]
    [Range(0.0f, 1.0f)]
    public float lightMaxRadius = 1;

    [Label("产生体积光的范围")]
    [Range(0.0f, 5.0f)]
    public float lightRadius = 2.0f;

    

    [Label("体积光颜色")]
    [ColorUsage(false,true)]
    public Color lightColor = Color.white;
 
    [Label("径向模糊uv采样偏移值")]
    [Range(0.0f, 10.0f)]
    public float samplerScale = 1;
    //Blur迭代次数
    [Range(1, 3)]
    public int blurIteration = 2;
    [Header("降低分辨率倍率")]
    [Range(0, 2)]
    public int downSample = 1;

    [Label("光源位置")]
    public Transform lightTransform;

    [Label("噪点")]
    public Texture2D noise;

    public Vector4 noise_ST = new Vector4(0.5f,0.5f,0.5f,0.5f);

    public Camera targetCamera = null;
    public Material _Material;

    public GodRayPostEffectDevModel dev_model = GodRayPostEffectDevModel.NORMAL;
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
            if (depthEnabel)
            {
 
                _Material.EnableKeyword("FROM_DEPTH");
            }
            else
            {
                _Material.DisableKeyword("FROM_DEPTH");
            }

            if (colorEnable)
            {

                _Material.EnableKeyword("FROM_COLOR");
            }
            else
            {
                _Material.DisableKeyword("FROM_COLOR");
            }

             
            if (noise)
            {
                _Material.SetTexture("_Noise", noise);
                _Material.SetVector("_Noise_ST", noise_ST);
                
                _Material.EnableKeyword("NOISE_TEXTURE");
            }
            else
            {
                _Material.DisableKeyword("NOISE_TEXTURE");
            }
           
            int rtWidth = source.width >> downSample;
            int rtHeight = source.height >> downSample;
            //RT分辨率按照downSameple降低
            RenderTexture temp1 = RenderTexture.GetTemporary(rtWidth, rtHeight, 0, source.format);

            //计算光源位置从世界空间转化到视口空间
            Vector3 viewPortLightPos = new Vector3(.5f, .5f, 0);
            if (null != lightTransform)
            {
                Vector3 worldPos = transform.position + lightTransform.forward * 1000f;
                viewPortLightPos = targetCamera.WorldToViewportPoint(worldPos);
            }
           

            //将shader变量改为PropertyId，以及将float放在Vector中一起传递给Material会更省一些，but，我懒
            _Material.SetVector("_ColorThreshold", colorThreshold);
            _Material.SetVector("_ViewPortLightPos", new Vector4(viewPortLightPos.x, viewPortLightPos.y, viewPortLightPos.z, 0));
            _Material.SetFloat("_LightRadius", lightRadius);
            _Material.SetFloat("_PowFactor", lightPowFactor);
            _Material.SetFloat("_DepthThreshold", depthThreshold);

            _Material.SetFloat("_LightMaxRadius", lightMaxRadius);
            
            //根据阈值提取高亮部分,使用pass0进行高亮提取，比Bloom多一步计算光源距离剔除光源范围外的部分
            Graphics.Blit(source, temp1, _Material, 0);

            if (dev_model == GodRayPostEffectDevModel.DEVELOP1)
            {
                Graphics.Blit(temp1, destination);
                RenderTexture.ReleaseTemporary(temp1);
                return;
            }

            _Material.SetVector("_ViewPortLightPos", new Vector4(viewPortLightPos.x, viewPortLightPos.y, viewPortLightPos.z, 0));
            _Material.SetFloat("_LightRadius", lightRadius);
            //径向模糊的采样uv偏移值
            float samplerOffset = samplerScale / source.width;
            //径向模糊，两次一组，迭代进行
            for (int i = 0; i < blurIteration; i++)
            {
                RenderTexture temp2 = RenderTexture.GetTemporary(rtWidth, rtHeight, 0, source.format);
                float offset = samplerOffset * (i * 2 + 1);
                _Material.SetVector("_offsets", new Vector4(offset, offset, 0, 0));
                Graphics.Blit(temp1, temp2, _Material, 1);

                offset = samplerOffset * (i * 2 + 2);
                _Material.SetVector("_offsets", new Vector4(offset, offset, 0, 0));
                Graphics.Blit(temp2, temp1, _Material, 1);
                RenderTexture.ReleaseTemporary(temp2);
            }
            if (dev_model == GodRayPostEffectDevModel.DEVELOP2)
            {
                Graphics.Blit(temp1, destination);
                RenderTexture.ReleaseTemporary(temp1);
                return;
            }

            _Material.SetTexture("_BlurTex", temp1);
            _Material.SetVector("_LightColor", lightColor);
 
            //最终混合，将体积光径向模糊图与原始图片混合，pass2
            Graphics.Blit(source, destination, _Material, 2);

            //释放申请的RT
            RenderTexture.ReleaseTemporary(temp1);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
