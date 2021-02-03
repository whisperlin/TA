using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;

#if UNITY_EDITOR
using UnityEditor;
[CustomPropertyDrawer(typeof(LabelAttribute))]
public class ConditionalHidePropertyDrawer : PropertyDrawer
{
    private bool GetConditionalHideAttributeResult(LabelAttribute condHAtt, SerializedProperty property)
    {

        if (condHAtt.conditionalSourceField.Length<=0)
        {
            return true;
            
        }
        bool enabled = true;
        //Look for the sourcefield within the object that the property belongs to
        string propertyPath = property.propertyPath; //returns the property path of the property we want to apply the attribute to
        
        string conditionPath = propertyPath;
        int index = conditionPath.LastIndexOf(".");
        if (index > 0)
        {
            conditionPath = conditionPath.Substring(0, index + 1) + condHAtt.conditionalSourceField;
        }
        else
        {
            conditionPath= condHAtt.conditionalSourceField;
        }

        //string conditionPath = propertyPath.Replace(property.name, condHAtt.conditionalSourceField); //changes the path to the conditionalsource property path

        SerializedProperty sourcePropertyValue = property.serializedObject.FindProperty(conditionPath);
        if (sourcePropertyValue != null)
        {
            
            enabled = sourcePropertyValue.boolValue;
           
        }
        /*else
        {
           Debug.LogWarning("Attempting to use a ConditionalLabelAttribute but no matching SourcePropertyValue found in object: " + condHAtt.ConditionalSourceField);
        }*/

        return enabled;
    }
    public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
    {
        //get the attribute data
        LabelAttribute condHAtt = (LabelAttribute)attribute;
        //check if the propery we want to draw should be enabled
        bool enabled = GetConditionalHideAttributeResult(condHAtt, property);
        if (enabled)
        {
            return EditorGUI.GetPropertyHeight(property, label);
        }
        else
        {
            return 0.1f;
        }
       
    }
    void CommonProperty(Rect position,SerializedProperty property)
    {
        if (property.propertyType == SerializedPropertyType.Enum)
        {
            var type = property.serializedObject.targetObject.GetType();
            var field = type.GetField(property.name);
            var enumtype = field.FieldType;
            List<string> m_displayNames = new List<string>();
            foreach (var enumName in property.enumNames)
            {
                var enumfield = enumtype.GetField(enumName);
                var hds = enumfield.GetCustomAttributes(typeof(HeaderAttribute), false);
                m_displayNames.Add(hds.Length <= 0 ? enumName : ((HeaderAttribute)hds[0]).header);
            }
            EditorGUI.BeginChangeCheck();
            var value = EditorGUI.Popup(position, property.name, property.enumValueIndex, m_displayNames.ToArray());
            if (EditorGUI.EndChangeCheck())
            {
                property.enumValueIndex = value;
            }
        }
        else if (property.isArray)
        {
            ArrayGUI( position,property);
        }
        else
        {

            EditorGUI.PropertyField(position, property);
        }
    }
    void ArrayGUI(Rect position, SerializedProperty property)
    {
        SerializedProperty arraySizeProp = property.FindPropertyRelative("Array.size");
        EditorGUILayout.PropertyField(arraySizeProp);

        EditorGUI.indentLevel++;

        for (int i = 0; i < arraySizeProp.intValue; i++)
        {
            CommonProperty(position, property.GetArrayElementAtIndex(i));
            EditorGUILayout.PropertyField(property.GetArrayElementAtIndex(i));
        }
        EditorGUI.indentLevel--;
    }
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        //get the attribute data
        LabelAttribute condHAtt = (LabelAttribute)attribute;
        //check if the propery we want to draw should be enabled
        bool enabled = true;
        if(condHAtt.ctrlByParam)
            enabled = GetConditionalHideAttributeResult(condHAtt, property);
        //Enable/disable the property
        bool wasEnabled = GUI.enabled;
        GUI.enabled = enabled;

        //Check if we should draw the property
        if ( enabled)
        {
            label.text = condHAtt.Label;
            if (condHAtt.type0 != null  )
            {
                var enumtype = condHAtt.type0;
                string[] enumNames = System.Enum.GetNames(enumtype);
                int selectIndex = 0;

                System.Array values = System.Enum.GetValues(enumtype);
                List<int> _values = new List<int>();
                foreach (var v in values)
                {
                    int _v = (int)v;
                    _values.Add(_v);


                }
                for (int i = 0; i < _values.Count; i++)
                {
                    if (_values[i] == property.intValue)
                    {
                        selectIndex = i;
                    }
                }

                List<string> m_displayNames = new List<string>();

                foreach (var enumName in enumNames)
                {
                    var enumfield = enumtype.GetField(enumName);
                    var hds = enumfield.GetCustomAttributes(typeof(HeaderAttribute), false);
                    m_displayNames.Add(hds.Length <= 0 ? enumName : ((HeaderAttribute)hds[0]).header);
                }


                EditorGUI.BeginChangeCheck();
                var _index = EditorGUI.Popup(position, label.text, selectIndex, m_displayNames.ToArray());
                if (EditorGUI.EndChangeCheck())
                {
                    property.intValue = _values[_index];
                }
            }
            else if (condHAtt.condiction)
            {
                if (property.propertyType == SerializedPropertyType.Float)
                {
                    EditorGUI.Slider(position, property, condHAtt.min, condHAtt.max, label);
                }
                else if (property.propertyType == SerializedPropertyType.Integer)
                {
                    EditorGUI.IntSlider(position, property, (int)condHAtt.min, (int)condHAtt.max, label);
                }
                else
                {
                    EditorGUI.PropertyField(position, property, label, true);
                }
            }
            else
            {

                if (property.propertyType == SerializedPropertyType.Enum)
                {
                    var _type = property.GetType();
 
                    var type = property.serializedObject.targetObject.GetType();
                    var field = type.GetField(property.name);
                    if (null == field || null == field.FieldType)
                    {
                        

                        EditorGUI.BeginChangeCheck();
                        var value = EditorGUI.Popup(position, label.text, property.enumValueIndex, property.enumDisplayNames);
                        if (EditorGUI.EndChangeCheck())
                        {
                            property.enumValueIndex = value;
                        }
                    }
                    else
                    {
                        var enumtype = field.FieldType;
                        List<string> m_displayNames = new List<string>();
                        foreach (var enumName in property.enumNames)
                        {
                            var enumfield = enumtype.GetField(enumName);
                            var hds = enumfield.GetCustomAttributes(typeof(HeaderAttribute), false);
                            m_displayNames.Add(hds.Length <= 0 ? enumName : ((HeaderAttribute)hds[0]).header);
                        }
                        EditorGUI.BeginChangeCheck();
                        var value = EditorGUI.Popup(position, label.text, property.enumValueIndex, m_displayNames.ToArray());
                        if (EditorGUI.EndChangeCheck())
                        {
                            property.enumValueIndex = value;
                        }
                     
                    }
                    
                }
                else
                {

                    EditorGUI.PropertyField(position, property, label, true);
                }
                
            }
 
            
        }

        //Ensure that the next property that is being drawn uses the correct settings
        GUI.enabled = wasEnabled;
    }
}
#endif

[AttributeUsage(AttributeTargets.Field | AttributeTargets.Property |
    AttributeTargets.Class | AttributeTargets.Struct, Inherited = true)]
public class LabelAttribute : PropertyAttribute
{
    //The name of the bool field that will be in control
    public string conditionalSourceField = "";
    public string Label = "";
    public bool condiction = false;
    public float max;
    public float min;
    public bool ctrlByParam = true;

 
    public System.Type type0 = null;
    public LabelAttribute(string label,string conditionalSourceField)
    {
        this.conditionalSourceField = conditionalSourceField;
      
        this.Label = "    "+label;
        condiction = false;
        ctrlByParam = true;
        type0 = null;
    }

    public LabelAttribute(string label, string conditionalSourceField,float min,float max)
    {
        this.Label = "    "+label;
        this.conditionalSourceField = conditionalSourceField;
        condiction = true;
        this.max = max;
        this.min = min;
        this.ctrlByParam = true;
        type0 = null;
    }
    public LabelAttribute(string label, float min, float max)
    {
        this.Label = label;
        condiction = true;
        this.max = max;
        this.min = min;
        this.ctrlByParam = false;
        type0 = null;
    }

    public LabelAttribute(string label )
    {
        this.Label = label;
        condiction = false;
        this.ctrlByParam = false;
        type0 = null;
    }


    public LabelAttribute(string label,System.Type t)
    {
        this.Label = label;
        condiction = false;
        this.ctrlByParam = false;
        type0 = t;
    }

}