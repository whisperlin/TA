using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class CharactorGUI :  ShaderGUI
{

    
    override public void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {

        Material targetMat = materialEditor.target as Material;

        List<MaterialProperty> result = new List<MaterialProperty>(properties);
        bool b = targetMat.IsKeywordEnabled("S_DEVELOP");
        ShaderGUIHelper.RemoveExclusion( properties, b, new string[] { "_CtrlTex" },new string[] { "_SpecMap", "_GlossMap",  "metallic_ctrl_tex" } ,result);
        ShaderGUIHelper.RemoveRroperty(result, "S_DEVELOP");
        ShaderGUIHelper.RemoveRroperty(result, "S_BAKE");

        bool b_m = targetMat.IsKeywordEnabled("_ISMETALLIC_ON");
		bool b_e = targetMat.IsKeywordEnabled("_ISMEMISSION_ON");
		bool b_c = targetMat.IsKeywordEnabled("_ISMEMISSION_COL");
		bool b_3s = targetMat.IsKeywordEnabled("_ISS3_ON");
		ShaderGUIHelper.RemoveExclusion(properties, b_3s, new string[] { "_DifSC", "_BackColor"  },new string[] { "_S3SPower", "_BRDFTex"  }, result);


		ShaderGUIHelper.RemoveExclusion(properties, b_3s&&b, new string[] { }, new string[] {   "_AO"  }, result);
		//"_AO",

		ShaderGUIHelper.RemoveExclusion(properties, b_m, new string[] { }, new string[] { "environment_reflect", "metallic_color",   "metallic_power","_IsMetaDiffuseColor", "_MetalShadow" }, result);


		ShaderGUIHelper.RemoveExclusion(properties, b_e, new string[] { }, new string[] {   "_Emission"  }, result);
		ShaderGUIHelper.RemoveExclusion(properties, b_e||b_m, new string[] { }, new string[] {   "metallic_ctrl_tex"  }, result);

		ShaderGUIHelper.RemoveExclusion(properties, b_c, new string[] { }, new string[] {   "_ClothColor"  }, result);

 

		//_SnowMeltPower
		//_SnowLocalPower

		var _BRDFTex = targetMat.GetTexture("_BRDFTex");
		if(null == _BRDFTex)
		{
			string path1 = "Assets/TA/lut/wrap ramp.psd";
			if (System.IO.File.Exists (path1)) {
				var t = AssetDatabase.LoadAssetAtPath<Texture2D>(path1);
				targetMat.SetTexture("_BRDFTex",t);
			}
        }
        base.OnGUI(materialEditor, result.ToArray());
        if (b)
        {
            if (GUILayout.Button("保存并退出开发者模式"))
            {

                var _SpecMap = targetMat.GetTexture("_SpecMap");
                var _GlossMap =  targetMat.GetTexture("_GlossMap");
                var _AO = targetMat.GetTexture("_AO");
                var metallic_ctrl_tex =  targetMat.GetTexture("metallic_ctrl_tex");

                string path = ShaderGUIHelper.GetAssetPathAndName(targetMat) + "Ctrl.tga";
                ShaderGUIHelper.CombineTextureToTga(path, new Texture[] { _SpecMap, _GlossMap, _AO, metallic_ctrl_tex },new bool []{ true,false,true,true});
                AssetDatabase.ImportAsset(path);
                 
                var t = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
                targetMat.SetTexture("_CtrlTex",t);
                ShaderGUIHelper.SaveMatAndClearTexture(targetMat, new string[] { "_SpecMap", "_GlossMap", "_AO", "metallic_ctrl_tex" });
                targetMat.DisableKeyword("S_DEVELOP");
            } 
        }
        else
        {
            if (GUILayout.Button("进入开发者模式"))
            { 
                ShaderGUIHelper.LoadTextureFormSaveMat (targetMat, new string[] { "_SpecMap", "_GlossMap", "_AO", "metallic_ctrl_tex" });
                targetMat.EnableKeyword("S_DEVELOP");
            }
        }




    }
}