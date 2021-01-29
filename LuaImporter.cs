using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.Experimental.AssetImporters;
using System.IO;

[ScriptedImporter(1, ".lua")]
public class LuaImporter : ScriptedImporter
{
    public override void OnImportAsset(AssetImportContext ctx)
    {
        var luaTxt = File.ReadAllText(ctx.assetPath); //作为string读取

        Debug.Log("Import:" + ctx.assetPath);

        var assetsText = new TextAsset(luaTxt); //转化为TextAsset，也可写个LuaAsset的类作为保存对象，但要继承Object的类

        ctx.AddObjectToAsset("main obj", assetsText);  //这一步和下面一步看似重复了，但少了哪一步都会报异常

        ctx.SetMainObject(assetsText);
    }
}