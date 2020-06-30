using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class TextureChannelTool : EditorWindow {



	public enum OPTIONS
	{
		R = 0,
		G = 1,
		B = 2,
		A = 3,
	}

	[MenuItem("Tools/图层通道合并")]
	static void Init()
	{
		EditorWindow.GetWindow<TextureChannelTool>("图层通道合并工具").Show ();
	}
	Texture2D[] editorArray = new Texture2D[4];
	OPTIONS [] types = new OPTIONS[]{OPTIONS.R,OPTIONS.R,OPTIONS.R,OPTIONS.R};

	void CombineMesh(string savePath)
	{
		Texture2D black = new Texture2D (1, 1, TextureFormat.RGBA32, false);
		black.SetPixel (0, 0, Color.black);
		black.Apply ();
		int width = 0;
		int height = 0;
		for (int i = 0; i < editorArray.Length; i++) {
			if (null == editorArray [i]) {
				editorArray [i] = black;
				continue;
			}
			width = Mathf.Max (width, editorArray [i].width);
			height = Mathf.Max (height, editorArray [i].height);
		}
		if (width == 0)
			return;
		RenderTexture [] temp = new RenderTexture[ editorArray.Length];
		Texture2D [] temp2 = new Texture2D[ editorArray.Length];
 
		for (int i = 0; i < editorArray.Length; i++) {
			temp[i]  = RenderTexture.GetTemporary (width, height);

			if (null != editorArray [i]) {
				Graphics.Blit (editorArray [i], temp [i]);
			}
		 

			temp2 [i] = new Texture2D (width, height,TextureFormat.RGBA32,false);
		 
			RenderTexture.active = 	temp[i] ;
			temp2 [i] .ReadPixels(new Rect(0, 0, width, height), 0, 0);
			temp2 [i].Apply ();
			RenderTexture.ReleaseTemporary (temp[i] );
		}

		Texture2D final = new Texture2D (width, height, TextureFormat.RGBA32,false);
		float [] _cols = new float[4];
		for(int i = 0 ; i < width ;i++)
		{
			for (int j = 0; j < height; j++) {
				for(int k = 0 ; k < 4 ; k++)
				{
					switch (types [k]) {
					case OPTIONS.R:
						_cols[k] = temp2 [k].GetPixel (i, j).r;
						break;
					case OPTIONS.G:
						_cols[k] = temp2 [k].GetPixel (i, j).g;
						break;
					case OPTIONS.B:
						_cols[k] = temp2 [k].GetPixel (i, j).b;
						break;
					default:
						_cols[k] = temp2 [k].GetPixel (i, j).a;
						break;	
					}
				}

				 
				final.SetPixel (i, j, new Color(_cols[0] ,  _cols[1] ,  _cols[2] ,_cols[3] ));
			}
		}
		final.Apply ();
		for (int i = 0; i < editorArray.Length; i++) {
			GameObject.DestroyImmediate (temp2 [i]);
		}
		byte[] date = TgaUtil.Texture2DEx.EncodeToTGA (final, true);
		//byte [] date =  final.EncodeToPNG ();
		System.IO.File.WriteAllBytes (savePath, date);
		GameObject.DestroyImmediate (final);
		GameObject.DestroyImmediate (black);

	}

    void CombineMesh2(string savePath)
    {
        Texture2D black = new Texture2D(1, 1, TextureFormat.RGBA32, false);
        black.SetPixel(0, 0, Color.black);
        black.Apply();
        int width = 0;
        int height = 0;
        for (int i = 0; i < editorArray.Length; i++)
        {
            if (null == editorArray[i])
            {
                editorArray[i] = black;
                continue;
            }
            width = Mathf.Max(width, editorArray[i].width);
            height = Mathf.Max(height, editorArray[i].height);
        }
        if (width == 0)
            return;
        RenderTexture[] temp = new RenderTexture[editorArray.Length];
        Texture2D[] temp2 = new Texture2D[editorArray.Length];

        for (int i = 0; i < editorArray.Length; i++)
        {
            temp[i] = RenderTexture.GetTemporary(width, height);

            if (null != editorArray[i])
            {
                Graphics.Blit(editorArray[i], temp[i]);
            }


            temp2[i] = new Texture2D(width, height, TextureFormat.RGBA32, false);

            RenderTexture.active = temp[i];
            temp2[i].ReadPixels(new Rect(0, 0, width, height), 0, 0);
            temp2[i].Apply();
            RenderTexture.ReleaseTemporary(temp[i]);
        }

        Texture2D final = new Texture2D(width, height, TextureFormat.RGBA32, false);
        float[] _cols = new float[4];
        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < height; j++)
            {
                for (int k = 0; k < 4; k++)
                {
                    switch (types[k])
                    {
                        case OPTIONS.R:
                            _cols[k] = temp2[k].GetPixel(i, j).r;
                            break;
                        case OPTIONS.G:
                            _cols[k] = temp2[k].GetPixel(i, j).g;
                            break;
                        case OPTIONS.B:
                            _cols[k] = temp2[k].GetPixel(i, j).b;
                            break;
                        default:
                            _cols[k] = temp2[k].GetPixel(i, j).a;
                            break;
                    }
                }

                final.SetPixel(i, j, new Color(_cols[0], _cols[1], _cols[2], _cols[3]));
            }
        }
        final.Apply();
        for (int i = 0; i < editorArray.Length; i++)
        {
            GameObject.DestroyImmediate(temp2[i]);
        }
        byte[] date = final.EncodeToPNG();
        //byte [] date =  final.EncodeToPNG ();
        System.IO.File.WriteAllBytes(savePath, date);
        GameObject.DestroyImmediate(final);
        GameObject.DestroyImmediate(black);

    }
    int toolBar = 0;
    bool isTGA = true;

    void OnGUI()
	{
		
		GUILayout.Label ("R通道");
		editorArray [0] = (Texture2D)EditorGUILayout.ObjectField (editorArray [0], typeof(Texture2D));
		types[0] = (OPTIONS)EditorGUILayout.EnumPopup("来自通道:", types[0] );
		GUILayout.Label ("G通道");
		editorArray [1] = (Texture2D)EditorGUILayout.ObjectField (editorArray [1], typeof(Texture2D));
		types[1] = (OPTIONS)EditorGUILayout.EnumPopup("来自通道:", types[1] );
		GUILayout.Label ("B通道");
		editorArray [2] = (Texture2D)EditorGUILayout.ObjectField (editorArray [2], typeof(Texture2D));
		types[2] = (OPTIONS)EditorGUILayout.EnumPopup("来自通道:", types[2] );
		GUILayout.Label ("A通道");
		editorArray [3] = (Texture2D)EditorGUILayout.ObjectField (editorArray [3], typeof(Texture2D));
		types[3] = (OPTIONS)EditorGUILayout.EnumPopup("来自通道:", types[3] );

        isTGA = EditorGUILayout.Toggle("tga", isTGA);
        if (GUILayout.Button ("合成")) {
			bool found = false;
			for (int i = 0; i < 4; i++) {
				if (editorArray[i] != null)
					found = true;
			}
			if (!found) {
				EditorUtility.DisplayDialog ("提示", "没有图片呗选择", "ok");
				return;
			}
            if (isTGA)
            {
                string path = EditorUtility.SaveFilePanelInProject("Save Texture", "TextureName", "tga",
                "请输入保存文件名");
                if (path.Length != 0)
                {
                    CombineMesh(path);
                }
            }
            else
            {
                string path = EditorUtility.SaveFilePanelInProject("Save Texture", "TextureName", "png",
                "请输入保存文件名");
                if (path.Length != 0)
                {
                    CombineMesh2(path);
                }
            }
			
		}
	}
}
