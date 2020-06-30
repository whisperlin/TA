using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TgaUtil;
public class ClearChannel : EditorWindow {

	[MenuItem("Tools/清除图层")]
	static void Init()
	{
		EditorWindow.GetWindow<ClearChannel>("图层清除工具").Show ();
	}
	bool [] cha = new bool[4];
	Texture2D  editorTex ;

	void OnGUI()
	{
 
		editorTex = (Texture2D)EditorGUILayout.ObjectField ("贴图", editorTex , typeof(Texture2D));
		cha[0] = GUILayout.Toggle (cha[0],"R通道");
		cha[1] = GUILayout.Toggle (cha[1],"G通道");
		cha[2] = GUILayout.Toggle (cha[2],"B通道");
		cha[3] = GUILayout.Toggle (cha[3],"R通道");

		if (GUILayout.Button ("清除")) {
			if (null != editorTex) {
				string path = AssetDatabase.GetAssetPath (editorTex);
				var pixs = editorTex.GetPixels ();
				for (int i = 0; i < pixs.Length; i++) {
					pixs [i] = new Color (cha[0] ? 0: pixs[i].r  , cha[1] ? 0: pixs[i].g, cha[2] ? 0: pixs[i].b , cha[3] ? 0: pixs[i].a);
				}
				editorTex.SetPixels (pixs);
				editorTex.Apply ();
				var data = TgaUtil.Texture2DEx.EncodeToTGA (editorTex);
				System.IO.File.WriteAllBytes (path, data);
			}
		}
	}
}
