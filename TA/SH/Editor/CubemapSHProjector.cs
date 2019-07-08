using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class CubemapSHProjector : EditorWindow
{
    //PUBLIC FIELDS
    public Cubemap input_cubemap;
	public Texture2D env_map;
    public Cubemap test;
    Camera cam;
    //PRIVATE FIELDS
    public bool isCopyNew = false;
 
    private Vector4[]   coefficients;

	public bool modle = false;

	public bool sun = false;
	public bool enableLight = false;

    private SerializedProperty sp_input_cubemap;

    private Texture2D tmp = null;

	List<Light> lights = new List<Light> ();

    [MenuItem("TA/SH9环境球工具")]
    static void Init()
    {
        CubemapSHProjector window = (CubemapSHProjector)EditorWindow.GetWindow(typeof(CubemapSHProjector));
        window.Show();
    }

    private void OnFocus()
    {
        Initialize();
    }

    private void OnEnable()
    {
        Initialize();
    }

    private void Initialize()
    {
 
 
    }
    private void setSH9Global()
    {
        for (int i = 0; i < 9; ++i)
        {
            string param = "g_sph" + i.ToString();
            Shader.SetGlobalVector(param, coefficients[i]);
        }
    }
    void ModifyTextureReadable()
    {
        string path = AssetDatabase.GetAssetPath(input_cubemap);
        if (null == path || path.Length == 0)
        {
            return;
        }
        TextureImporter textureImporter = AssetImporter.GetAtPath(path) as TextureImporter;
        if (null == textureImporter)
            return;
        textureImporter.isReadable = true;
        textureImporter.SaveAndReimport();
    }

	void ModifyTextureReadable(Texture2D tex)
	{
		string path = AssetDatabase.GetAssetPath(tex);
		if (null == path || path.Length == 0)
		{
			return;
		}
		TextureImporter textureImporter = AssetImporter.GetAtPath(path) as TextureImporter;
		if (null == textureImporter)
			return;
		textureImporter.isReadable = true;
		textureImporter.SaveAndReimport();
	}
    Cubemap CopyFromEnvMap()
    {
         
        if (null == cam)
        {
            GameObject obj = new GameObject();
            obj.hideFlags = HideFlags.HideAndDontSave;
            cam = obj.AddComponent<Camera>();
			cam.cullingMask = 0;
            Skybox sb = obj.AddComponent<Skybox>();
            sb.material = new Material(Shader.Find("Skybox/Cubemap"));
            sb.material.SetTexture("_Tex", input_cubemap);
            cam.enabled = false;
        }
        Cubemap cm = new Cubemap(512, TextureFormat.RGBA32, false);
        cam.RenderToCubemap(cm);
        return cm;
    }
    private void OnGUI()
    {

		modle = EditorGUILayout.Toggle ("CubeMap", modle);
		if (modle) {
		
			input_cubemap = EditorGUILayout.ObjectField("Input Cubemap", input_cubemap, typeof(Cubemap), true) as Cubemap;
			isCopyNew = EditorGUILayout.Toggle("从环境球获取",isCopyNew);
			if (input_cubemap != null) {
				EditorGUILayout.Space ();

				if (GUILayout.Button ("CPU Uniform 9 Coefficients")) {
					Cubemap cm = input_cubemap;
					if (isCopyNew)
						test = cm = CopyFromEnvMap ();

					ModifyTextureReadable ();
					coefficients = new Vector4[9];
					if (SphericalHarmonics.CPU_Project_Uniform_9Coeff (cm, coefficients)) {
						setSH9Global();
					}
					if (isCopyNew)
						GameObject.DestroyImmediate (cm, true);
				}

				EditorGUILayout.Space ();

				if (GUILayout.Button ("CPU Monte Carlo 9 Coefficients")) {
					Cubemap cm = input_cubemap;
					if (isCopyNew)
						cm = CopyFromEnvMap ();
					ModifyTextureReadable ();
					coefficients = new Vector4[9];
					if (SphericalHarmonics.CPU_Project_MonteCarlo_9Coeff (cm, coefficients, 4096)) {
						setSH9Global();
					}
					if (isCopyNew)
						GameObject.DestroyImmediate (cm, true);
				}

				EditorGUILayout.Space ();

				if (GUILayout.Button ("GPU Uniform 9 Coefficients")) {
					Cubemap cm = input_cubemap;
					if (isCopyNew)
						input_cubemap = cm = CopyFromEnvMap ();
					ModifyTextureReadable ();
					coefficients = new Vector4[9];
					if (SphericalHarmonics.GPU_Project_Uniform_9Coeff (cm, coefficients)) {
						setSH9Global();
					}
					if (isCopyNew)
						GameObject.DestroyImmediate (cm, true);
				}

				EditorGUILayout.Space ();

				if (GUILayout.Button ("GPU Monte Carlo 9 Coefficients")) {
					Cubemap cm = input_cubemap;
					if (isCopyNew)
						cm = CopyFromEnvMap ();
					ModifyTextureReadable ();
					coefficients = new Vector4[9];
					if (SphericalHarmonics.GPU_Project_MonteCarlo_9Coeff (cm, coefficients)) {
						setSH9Global();
					}
					if (isCopyNew)
						GameObject.DestroyImmediate (cm, true);
				}

				EditorGUILayout.Space ();



			}
		}
		else
		{


			env_map = EditorGUILayout.ObjectField ("360环境球", env_map, typeof(Texture2D), true) as Texture2D;

			if(env_map)
				sun = EditorGUILayout.Toggle ("太阳",sun);

			enableLight = EditorGUILayout.Toggle ("灯光",enableLight);

			if (enableLight) {

				GUILayout.BeginHorizontal ();
				if (GUILayout.Button ("+")) {
					lights.Add (null);
				}
				if (GUILayout.Button ("-")) {
					if(lights.Count>0)
						lights.RemoveAt (lights.Count-1);
				}


				GUILayout.EndHorizontal ();
				for (int i = 0; i < lights.Count; i++) {
					lights[i] = EditorGUILayout.ObjectField ("360环境球", lights[i], typeof(Light), true) as Light;
				}
			
			}
			bool hasLight = false;
			for (int i = 0; i < lights.Count; i++) {
				if (lights [i] != null) {
					hasLight = true;
					break;
				}
			}
			//lights
			if (hasLight || env_map != null) {
				EditorGUILayout.Space();

				if (GUILayout.Button("CPU Uniform 9 Coefficients"))
				{
					ModifyTextureReadable(env_map);
					List<Light> ls = new List<Light> ();
					foreach (Light l in lights) {
						if (l != null)
							ls.Add (l);
					}

					coefficients = new Vector4[9];
					if (SphericalHarmonics.CPU_Project_360HJQ(env_map, coefficients,4096,sun,ls.ToArray()))
					{
						setSH9Global();
					}

				}
			}

		}
       

        
        

 
       


		if (coefficients != null && coefficients.Length == 9)
        {

			if (GUILayout.Button ("保存")) {
				SH9Data data = SH9Data.CreateInstance<SH9Data> ();
				data.coefficients = coefficients;

				string path = EditorUtility.SaveFilePanelInProject ("Save SH9 Data", "ibl.asset", "asset",
					"Please enter a file name to save the texture to");
				if (path.Length != 0) {

					if (System.IO.File.Exists (path)) {
						/*if (EditorUtility.DisplayDialog("目标已存在", "替换", "取消"))
							{
								
							}*/

						data.test = new Vector4 (1, 0, 0, 1);
						data = AssetDatabase.LoadAssetAtPath<SH9Data> (path);
						data.coefficients = coefficients;
						AssetDatabase.SaveAssets ();
					} else {
						data.test = Vector4.one;
						AssetDatabase.CreateAsset (data, path);
						AssetDatabase.ImportAsset (path); 
					}
				}

			}
			EditorGUILayout.Space();
            for (int i = 0; i < 9; ++i)
            {
                EditorGUILayout.LabelField("c_" + i.ToString() + ": " + coefficients[i].ToString("f4"));
            }
        }
        

        EditorGUILayout.Space();
        if (tmp != null)
            GUILayout.Label(tmp);
    }
}
