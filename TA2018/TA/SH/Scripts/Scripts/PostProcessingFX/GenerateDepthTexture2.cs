using UnityEngine;
using System.Collections;

public class GenerateDepthTexture2 : MonoBehaviour {
	public LayerMask casterLayer;
	public Shader shader;
	public float Near;
	public float Far;
	public float Size;
	public int TextureSize = 512;
	[Range(0,0.1f)]
	public float Bias;
	[Range(0,1)]
	public float Strength;
	private Matrix4x4 biasMatrix;
	private Camera depthCamera;
	private RenderTexture depthTexture;
	private bool isActive = true;
	private bool _isActive = true;
	// Use this for initialization
	void Awake () {
		GameObject go = new GameObject("depthCamera");
		depthCamera = go.AddComponent<Camera>();
		depthCamera.transform.position = Vector3.zero;
		depthCamera.transform.rotation = transform.rotation;
		depthCamera.transform.localPosition += transform.forward * Near;
		depthCamera.transform.parent = transform;
		depthCamera.orthographic = true;
		
		depthCamera.clearFlags = CameraClearFlags.SolidColor;
		depthCamera.backgroundColor = Color.white;
		depthTexture = new RenderTexture(TextureSize,TextureSize, 16, RenderTextureFormat.ARGB32);
		depthTexture.filterMode = FilterMode.Bilinear;
		depthCamera.targetTexture = depthTexture;
		depthCamera.SetReplacementShader(shader, null);
		depthCamera.enabled = false;
		biasMatrix = Matrix4x4.identity;
		biasMatrix[ 0, 0 ] = 0.5f;
		biasMatrix[ 1, 1 ] = 0.5f;
		biasMatrix[ 2, 2 ] = 0.5f;
		biasMatrix[ 0, 3 ] = 0.5f;
		biasMatrix[ 1, 3 ] = 0.5f;
		biasMatrix[ 2, 3 ] = 0.5f;
	}

	void OnDestroy()
	{
		RenderTexture.DestroyImmediate(depthTexture);
	}

	void OnGUI()
	{
		if(depthTexture != null)
		{
			GUI.DrawTextureWithTexCoords(new Rect(0,20, 150,150), depthTexture, new Rect(0,0,1,1), false);
		}

		if(GUI.Button(new Rect(Screen.width - 150, 0, 150,100), "HARD"))
		{
			Shader.EnableKeyword("HARD_SHADOW");
			Shader.DisableKeyword("SOFT_SHADOW_4Samples");
			Shader.DisableKeyword("SOFT_SHADOW_4x4");
		}

	

		if(GUI.Button(new Rect(Screen.width - 150, 200, 150,100), "SOFT_4Samples"))
		{
			Shader.DisableKeyword("HARD_SHADOW");
			Shader.EnableKeyword("SOFT_SHADOW_4Samples");
			Shader.DisableKeyword("SOFT_SHADOW_4x4");
		}

		 

//		if(GUI.Button(new Rect(Screen.width - 150, 400, 150,100), isActive?"Disable":"Enable"))
//		{
//			isActive = !isActive;
//		}
		GUI.Label(new Rect(Screen.width - 190, 495, 150,100),"Bias");
		Bias = GUI.HorizontalSlider(new Rect(Screen.width - 150, 500, 150,200), Bias, -0.02F, 0.01F);
	}

	void LateUpdate()
	{
		if(_isActive != isActive)
		{
			_isActive = isActive;
			if(isActive)
			{
				depthTexture = new RenderTexture(TextureSize,TextureSize, 16, RenderTextureFormat.ARGB32);
				depthTexture.filterMode = FilterMode.Point;
			}else
			{
				RenderTexture.DestroyImmediate(depthTexture);
			}
		}
		if(isActive)
		{
			depthCamera.cullingMask = casterLayer;
			depthCamera.orthographicSize = Size;
			depthCamera.farClipPlane = Far;
			depthCamera.Render();
			Matrix4x4 depthProjectionMatrix = depthCamera.projectionMatrix;
			Matrix4x4 depthViewMatrix = depthCamera.worldToCameraMatrix;
			Matrix4x4 depthVP = depthProjectionMatrix * depthViewMatrix ;
			Matrix4x4 depthVPBias = biasMatrix * depthVP;
			Shader.SetGlobalMatrix("_depthVPBias", depthVPBias);
			Shader.SetGlobalMatrix("_depthV", depthViewMatrix);
			Shader.SetGlobalTexture("_kkShadowMap", depthCamera.targetTexture);
			Shader.SetGlobalFloat("_bias", Bias);
			Shader.SetGlobalFloat("_strength", 1 - Strength);
			Shader.SetGlobalFloat("_farplaneScale", 1/Far);
		}
	}


}
