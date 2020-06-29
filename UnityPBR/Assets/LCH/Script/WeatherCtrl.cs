using System.Collections;
using System.Collections.Generic;
using UnityEngine;
 
[ExecuteInEditMode]
[DisallowMultipleComponent]
public class WeatherCtrl : MonoBehaviour {

    [Label("背光")]
    public Color backLight = new Color(0.3f, 0.3f, 0.3f, 1f);
    public Texture rain_normal = null;
    //[Header("雪 噪点")]
    public Texture _SnowNoise;

    [Label("是否开启雨")]
	public bool openRain = false;
	bool  openRain0 = false;

	[Label("雨法线强度", 0.1f, 1.0f)]
	public float rainBumpPower = 0.8f;//雨法线强度

	[Label("天气颜色",0.5f, 1.0f)]
 
    public float weatherColorIntensity = 0.8f;

	[Label("高光粗糙度度", 1f, 1.4f)]

	public float SmoothnessRate = 1.0f;

	[Label("是否开启雪")]
	public bool openSnow = false;
	bool  openSnow0 = false;
	[Label("雪强度", 0f, 1f)]
	public float _SnowPower = 0.0f;
	[Label("雪颜色")]
	public Color _SnowColor = new Color32(200,215,255,255);
	[Label("雪高光锐度", 0f, 1f)]
	public float _SnowGloss;

	[Label("消融学调节/默认", 1f, 2.5f)]
	public float _SnowMeltPower = 2.1f;


 
    //[Header("亮度")]
    //public Color brightness = new Color(0.5f, 0.5f, 0.5f);

    void Start () {
		
	}
    //确保整个场景只存在一个 WeatherCtrl对象.
    void CheckSingleton( )
	{
        if (Application.platform == RuntimePlatform.WindowsEditor)
        {
            WeatherCtrl[] wps = GameObject.FindObjectsOfType<WeatherCtrl>();
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
        UploadParams();
    }

    void OnDisable()
    {
        //Shader.DisableKeyword("RAIN_ENABLE");
		//Shader.DisableKeyword("_ISNORMALSNOW_ON");
        Shader.SetGlobalFloat("global_weather_state", 0);
        Shader.SetGlobalTexture("_WeatherCtrlTex0", null);
        Debug.Log("OnDisable");

        
        
    }
    public void UploadParams()
    {
        if (null == _SnowNoise)
            _SnowNoise = Resources.Load("snow_noise") as Texture;
        if (null == rain_normal)
            rain_normal = Resources.Load("rain_normal") as Texture;

        Shader.SetGlobalVector("weather_intensity", new Vector4(weatherColorIntensity, rainBumpPower, 0, 0));
        Shader.SetGlobalTexture("_WeatherCtrlTex0", rain_normal);
        Shader.SetGlobalFloat("SmoothnessRate", SmoothnessRate);

        Shader.SetGlobalFloat("_SnowPower", 1.0f - _SnowPower);
        Shader.SetGlobalColor("_SnowColor", _SnowColor);
        Shader.SetGlobalTexture("_SnowNoise", _SnowNoise);

        Shader.SetGlobalFloat("_SnowGloss", _SnowGloss);
        Shader.SetGlobalFloat("_SnowMeltPower", _SnowMeltPower);
        Shader.SetGlobalColor("_BackLight", backLight);
    }
    void SetWeatherState()
    {
        if (openSnow)
        {
            Shader.SetGlobalFloat("global_weather_state", 1);
        }
        else if (openRain)
        {
            Shader.SetGlobalFloat("global_weather_state", 2);
        }
        else
        {
            Shader.SetGlobalFloat("global_weather_state", 0);
        }
    }
    void Update() {

        
		if (openSnow0 != openSnow) {
            openSnow0 = openSnow;
            if (openSnow)
            {
                openRain0 = openRain = false;
            }
            SetWeatherState();

        }

		if (openRain0 != openRain) {
             
			openRain0 = openRain;
            if (openRain)
            {
                openSnow0 = openSnow = false;
            }
            SetWeatherState(); ;
        }
 

        if(Application.platform == RuntimePlatform.WindowsEditor )
        {

            UploadParams();
            
        }
        
        //Shader.SetGlobalFloat("FrameTime", Time.time);


        //Shader.EnableKeyword("BRIGHTNESS_ON");
        //Shader.SetGlobalColor("_Brightness", brightness);
    }
}
