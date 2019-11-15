
using UnityEngine;


[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
 
public class ImageEffectMgr : MonoBehaviour
{
	#region Public Properties


	public float thresholdGamma {
		get { return Mathf.Max(threshold, 0); }
		set { threshold = value; }
	}

	public float thresholdLinear {
		get { return GammaToLinear(thresholdGamma); }
		set { threshold = LinearToGamma(value); }
	}



	[Header("颜色剔除值")]
	[SerializeField]
	[Range(0,2)]
	public  float threshold = 0.8f;


	[Header("剔除值附件对比度")]
	[SerializeField]
	[Range(0,1)]
	public  float softKnee = 0.5f;


	[Header("半径(向下采样层数)")]
	[SerializeField]
	[Range(2,5)]
	public  int radius = 2;


	[Header("强度调整")]
	[SerializeField]
	[Range(0,1)]
	public float intensity = 0.8f;


	[Header("bloom调试模式")]
	[SerializeField]
	public bool bloomDebugMode = false;

 


	#endregion

	#region Private Members

	[SerializeField, HideInInspector]
	Shader _shader;

	Material _material;

	const int kMaxIterations = 16;
	RenderTexture[] _blurBuffer1 = new RenderTexture[kMaxIterations];
	RenderTexture[] _blurBuffer2 = new RenderTexture[kMaxIterations];

	float LinearToGamma(float x)
	{
		#if UNITY_5_3_OR_NEWER
		return Mathf.LinearToGammaSpace(x);
		#else
		if (x <= 0.0031308f)
		return 12.92f * x;
		else
		return 1.055f * Mathf.Pow(x, 1 / 2.4f) - 0.055f;
		#endif
	}

	float GammaToLinear(float x)
	{
		#if UNITY_5_3_OR_NEWER
		return Mathf.GammaToLinearSpace(x);
		#else
		if (x <= 0.04045f)
		return x / 12.92f;
		else
		return Mathf.Pow((x + 0.055f) / 1.055f, 2.4f);
		#endif
	}

	#endregion

	#region MonoBehaviour Functions

	void OnEnable()
	{
		var shader = _shader ? _shader : Shader.Find("Hidden/Bloom");
		_material = new Material(shader);
		_material.hideFlags = HideFlags.DontSave;
	}

	void OnDisable()
	{
		DestroyImmediate(_material);
	}


	RenderTexture myRenderTexture;
	void OnPreRender()
	{
 
		myRenderTexture = RenderTexture.GetTemporary(Screen.width,Screen.height,24, RenderTextureFormat.DefaultHDR);
		myRenderTexture.filterMode = FilterMode.Trilinear;
		myRenderTexture.antiAliasing = 2;
		Camera.main.targetTexture = myRenderTexture;
	}
	void OnPostRender()
	{
		Camera.main.targetTexture = null;

		RenderTexture source = myRenderTexture;
 
		OnBloomEffect (source,  null as RenderTexture);
 
		RenderTexture.ReleaseTemporary(myRenderTexture);
	}
	const int prefilter = 0;
	const int downsampler = 1;
	const int Upsampler = 2;
	const int Combiner = 3;
	//void OnRenderImage(RenderTexture source, RenderTexture destination)
	void OnBloomEffect(RenderTexture source, RenderTexture destination)
	{
		var useRGBM = Application.isMobilePlatform;

		// source texture size
		var tw = source.width;
		var th = source.height;



		tw /= 2;
		th /= 2;

		// blur buffer format
		var rtFormat = useRGBM ?
		RenderTextureFormat.Default : RenderTextureFormat.DefaultHDR;

		// determine the iteration count
		var logh = Mathf.Log(th, 2) + radius - 8;
		var logh_i = (int)logh;
		var iterations = Mathf.Clamp(logh_i, 1, kMaxIterations);

		// update the shader properties
		var lthresh = thresholdLinear;
		_material.SetFloat("_Threshold", lthresh);

		var knee = lthresh * softKnee + 1e-5f;
		var curve = new Vector3(lthresh - knee, knee * 2, 0.25f / knee);
		_material.SetVector("_Curve", curve);


		_material.SetFloat("_PrefilterOffs",  /*-0.5f*/  0.0f);

		_material.SetFloat("_SampleScale", 0.5f + logh - logh_i);
		_material.SetFloat("_Intensity", intensity);


		if (bloomDebugMode ) {
			Graphics.Blit(source, destination, _material, prefilter);
			return;
		}
		// prefilter pass
		var prefiltered = RenderTexture.GetTemporary(tw, th, 0, rtFormat);


		Graphics.Blit(source, prefiltered, _material, prefilter);

		// construct a mip pyramid
		var last = prefiltered;
		for (var level = 0; level < iterations; level++)
		{
			_blurBuffer1[level] = RenderTexture.GetTemporary(
				last.width / 2, last.height / 2, 0, rtFormat
			);


			Graphics.Blit(last, _blurBuffer1[level], _material, downsampler);

			last = _blurBuffer1[level];
		}

		// upsample and combine loop
		for (var level = iterations - 2; level >= 0; level--)
		{
			var basetex = _blurBuffer1[level];
			_material.SetTexture("_BaseTex", basetex);

			_blurBuffer2[level] = RenderTexture.GetTemporary(
				basetex.width, basetex.height, 0, rtFormat
			);


			Graphics.Blit(last, _blurBuffer2[level], _material, Upsampler);
			last = _blurBuffer2[level];
		}

		// finish process
		_material.SetTexture("_BaseTex", source);

		Graphics.Blit(last, destination, _material, Combiner);

		// release the temporary buffers
		for (var i = 0; i < kMaxIterations; i++)
		{
			if (_blurBuffer1[i] != null)
				RenderTexture.ReleaseTemporary(_blurBuffer1[i]);

			if (_blurBuffer2[i] != null)
				RenderTexture.ReleaseTemporary(_blurBuffer2[i]);

			_blurBuffer1[i] = null;
			_blurBuffer2[i] = null; 
		}

		RenderTexture.ReleaseTemporary(prefiltered);
	}

	#endregion
}
