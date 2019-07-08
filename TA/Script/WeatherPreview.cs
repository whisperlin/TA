using System.Collections;
using System.Collections.Generic;
using UnityEngine;
 
[ExecuteInEditMode]
[DisallowMultipleComponent]
public class WeatherPreview : MonoBehaviour {

    //[Header("雨贴图")]
    [HideInInspector]public Texture rain_normal = null;
    //[Header("雪 噪点")]
    [HideInInspector]public Texture _SnowNoise;

    [Header("是否开启雨")]
	public bool openRain = false;
	bool  openRain0 = false;

	[Header("雨法线强度")]
    [Range(0.1f,1.0f)]
	public float rainBumpPower = 0.8f;//雨法线强度

	[Header("天气颜色")]
    [Range(0.1f, 1.0f)]
    public float weatherColorIntensity = 0.74f;

	[Header("高光粗糙度度")]
	[Range(1f,1.4f)]
	public float SmoothnessRate = 1.0f;


 

	[Header("是否开启雪")]
	public bool openSnow = false;
	bool  openSnow0 = false;
	[Header("雪强度")]
	[Range(0f,1f)]
	public float _SnowPower = 0.0f;

	[Header("雪颜色")]
	public Color _SnowColor = new Color32(200,215,255,255);

   

	[Header("雪高光锐度")]
	[Range(0f,1f)]
	public float _SnowGloss;


	[Header("消融学调节/默认")]
	[Range(1f,2.5f)]
	public float _SnowMeltPower = 2.1f;


 
    [Header("亮度")]
    public Color brightness = new Color(0.5f, 0.5f, 0.5f);

    void Start () {
		
	}
    //确保整个场景只存在一个 WeatherPreview对象.
    void CheckSingleton( )
	{
        if (Application.platform == RuntimePlatform.WindowsEditor)
        {
            WeatherPreview[] wps = GameObject.FindObjectsOfType<WeatherPreview>();
            for (int i = 0; i < wps.Length; i++)
            {
                if (wps[i].gameObject == this.gameObject)
                    continue;
                GameObject.DestroyImmediate(wps[i]);
            }
        }
	}
    void OnEnable()
    {
        _SnowNoise = Resources.Load("snow_noise") as Texture;
        rain_normal = Resources.Load("rain_normal") as Texture;
        CheckSingleton ();
        //Shader.EnableKeyword("RAIN_ENABLE");
        Shader.SetGlobalVector("weather_intensity", new Vector4(0.74f, 0.8f, 0, 0));
        Shader.SetGlobalTexture("_WeatherCtrlTex0", rain_normal);
		Shader.SetGlobalFloat ("SmoothnessRate", SmoothnessRate);
		

		Shader.SetGlobalColor ("_SnowColor", _SnowColor);

		Shader.SetGlobalTexture("_SnowNoise", _SnowNoise);

		Shader.SetGlobalFloat ("_SnowGloss", _SnowGloss);

		Shader.SetGlobalFloat ("_SnowMeltPower", _SnowMeltPower);


		if (openSnow) {
			Shader.EnableKeyword("SNOW_ENABLE");
		}
		else {
			Shader.DisableKeyword("SNOW_ENABLE");
		}
		openSnow0 = openSnow;

		if (openRain) {
			Shader.EnableKeyword("RAIN_ENABLE");
		}
		else {
			Shader.DisableKeyword("RAIN_ENABLE");
		}
		openRain0 = openRain;




		//_IsNormalSnow
		Shader.SetGlobalFloat ("_SnowPower", 1.0f-_SnowPower);

        Debug.Log("OnEnable");
    }

    void OnDisable()
    {
        Shader.DisableKeyword("RAIN_ENABLE");
		Shader.DisableKeyword("_ISNORMALSNOW_ON");
        Shader.SetGlobalTexture("_WeatherCtrlTex0", null);
        Debug.Log("OnDisable");

        
        
    }

    // Update is called once per frame
    void Update() {

        
		if (openSnow0 != openSnow) {
			if (openSnow) {
				Shader.EnableKeyword("SNOW_ENABLE");
			}
			else {
				Shader.DisableKeyword("SNOW_ENABLE");
			}
			openSnow0 = openSnow;
		}

		if (openRain0 != openRain) {
			if (openRain) {
				Shader.EnableKeyword("RAIN_ENABLE");
			}
			else {
				Shader.DisableKeyword("RAIN_ENABLE");
			}
			openRain0 = openRain;
		}
 

        if(Application.platform == RuntimePlatform.WindowsEditor )
        {
			
            if (null== _SnowNoise)
                _SnowNoise = Resources.Load("snow_noise") as Texture;
            if (null == rain_normal)
                rain_normal = Resources.Load("rain_normal") as Texture;

            Shader.SetGlobalVector("weather_intensity", new Vector4(weatherColorIntensity, rainBumpPower, 0, 0));
            Shader.SetGlobalTexture("_WeatherCtrlTex0", rain_normal);
			Shader.SetGlobalFloat ("SmoothnessRate", SmoothnessRate);

			Shader.SetGlobalFloat ("_SnowPower", 1.0f-_SnowPower);
			Shader.SetGlobalColor ("_SnowColor", _SnowColor);
			Shader.SetGlobalTexture("_SnowNoise", _SnowNoise);

			Shader.SetGlobalFloat ("_SnowGloss", _SnowGloss);
			Shader.SetGlobalFloat ("_SnowMeltPower", _SnowMeltPower);
        }
        
        Shader.SetGlobalFloat("FrameTime", Time.time);


        Shader.EnableKeyword("BRIGHTNESS_ON");
        Shader.SetGlobalColor("_Brightness", brightness);
    }
}
