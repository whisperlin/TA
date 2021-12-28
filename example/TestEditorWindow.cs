using System.Collections;
using System.Collections.Generic;
using UnityEngine;

 
using UnityEditor;
using System.Reflection;

public class TestWinow1 : EditorWindow
{
    string myString = "Hello World";
    bool groupEnabled;
    bool myBool = true;
    float myFloat = 1.23f;

    // Add menu named "My Window" to the Window menu
    [MenuItem("Window/My Window")]
    static void Init()
    {
        // Get existing open window or if none, make a new one:
        TestWinow1 window = (TestWinow1)EditorWindow.GetWindow(typeof(TestWinow1));
        window.Show();

        TestWinow2 window2 = (TestWinow2)EditorWindow.GetWindow(typeof(TestWinow2));
        window2.Show();


        System.Type t = typeof(EditorWindow);


        FieldInfo field = t.GetField("m_Parent", BindingFlags.NonPublic | BindingFlags.Instance);

        var m_Parnet = field.GetValue(window);


        var m_Parnet2 = field.GetValue(window2);
        Debug.LogError(m_Parnet.GetType());



        System.Type parnetType = m_Parnet.GetType();
        parnetType = parnetType.BaseType.BaseType.BaseType;

        var parentField = parnetType.GetField("m_Parent", BindingFlags.NonPublic | BindingFlags.Instance);

        var m_ParnetParnet = parentField.GetValue(m_Parnet);


        var SlipView = m_ParnetParnet.GetType();


   
        MethodInfo[] methods =  SlipView.GetMethods();
        foreach (var mt in methods)
        {
            if (mt.Name == "AddChild")
            {
                if (mt.GetParameters().Length == 1)
                {
                    string DoRet = mt.Invoke(m_ParnetParnet, new object[] { m_Parnet2 }).ToString();//执行
                }
                Debug.LogError(m_ParnetParnet.GetType());
                //Debug.LogError(m.Name + " " + m.GetParameters().Length);
            }
        }
      
    }

    void OnGUI()
    {
        GUILayout.Label("Window 1", EditorStyles.boldLabel);
        
    }
}

 

public class TestWinow2 : EditorWindow
{
    string myString = "Hello World";
    bool groupEnabled;
    bool myBool = true;
    float myFloat = 1.23f;

    
    void OnGUI()
    {
        GUILayout.Label("Base Settings", EditorStyles.boldLabel);
        myString = EditorGUILayout.TextField("Text Field", myString);

        groupEnabled = EditorGUILayout.BeginToggleGroup("Optional Settings", groupEnabled);
        myBool = EditorGUILayout.Toggle("Toggle", myBool);
        myFloat = EditorGUILayout.Slider("Slider", myFloat, -3, 3);
        EditorGUILayout.EndToggleGroup();
    }
}