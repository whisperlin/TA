using UnityEngine;
using System;
using System.Collections;

#if UNITY_EDITOR
using UnityEditor;
[CustomPropertyDrawer(typeof(LabelAttribute))]
public class ConditionalHidePropertyDrawer : PropertyDrawer
{
    private bool GetConditionalHideAttributeResult(LabelAttribute condHAtt, SerializedProperty property)
    {
        bool enabled = true;
        string propertyPath = property.propertyPath;  
        string conditionPath = propertyPath.Replace(property.name, condHAtt.ConditionalSourceField); 
        SerializedProperty sourcePropertyValue = property.serializedObject.FindProperty(conditionPath);
        if (sourcePropertyValue != null)
        {
            enabled = sourcePropertyValue.boolValue;
        }
        return enabled == condHAtt.condictionValue;
    }
    public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
    {
        LabelAttribute condHAtt = (LabelAttribute)attribute;
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
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        LabelAttribute condHAtt = (LabelAttribute)attribute;
        bool enabled = true;
        if(condHAtt.ctrlByParam)
            enabled = GetConditionalHideAttributeResult(condHAtt, property);
        bool wasEnabled = GUI.enabled;
        GUI.enabled = enabled;
        if ( enabled)
        {
            label.text = condHAtt.Label;
            if (condHAtt.condiction)
            {
                if (property.propertyType == SerializedPropertyType.Float)
                {
                    EditorGUI.Slider(position, property, condHAtt.min, condHAtt.max, label);
                }
                else if (property.propertyType == SerializedPropertyType.Integer)
                {
                    EditorGUI.IntSlider(position, property, (int)condHAtt.min, (int)condHAtt.max, label);
                }
                else if (property.propertyType == SerializedPropertyType.Color)
                {
                    EditorGUI.BeginChangeCheck();
                    Color colorValue;
                    if (property.name.Contains("HDR"))
                    {
                         colorValue = EditorGUI.ColorField(position, label, property.colorValue,true,true,true);
                    }
                    else
                    {
                         colorValue = EditorGUI.ColorField(position, label, property.colorValue);
                    }
                    if (EditorGUI.EndChangeCheck())
                    {
                        property.colorValue = colorValue;
                    }
                }
                else
                {
                    EditorGUI.PropertyField(position, property, label, true);
                }
            }
            else
            {
                if (property.propertyType == SerializedPropertyType.Color)
                {
                    EditorGUI.BeginChangeCheck();
                    Color colorValue;
                    if (property.name.Contains("HDR"))
                    {
                        colorValue = EditorGUI.ColorField(position, label, property.colorValue, true, true, true);
                    }
                    else
                    {
                        colorValue = EditorGUI.ColorField(position, label, property.colorValue);
                    }
                    if (EditorGUI.EndChangeCheck())
                    {
                        property.colorValue = colorValue;
                    }
                }
                else
                {
                    EditorGUI.PropertyField(position, property, label, true);
                }
            }
        }
        GUI.enabled = wasEnabled;
    }
}
#endif
[AttributeUsage(AttributeTargets.Field | AttributeTargets.Property |
    AttributeTargets.Class | AttributeTargets.Struct, Inherited = true)]
public class LabelAttribute : PropertyAttribute
{
    public string ConditionalSourceField = "";
    public string Label = "";
    public bool condiction = false;
    public float max;
    public float min;
    public bool ctrlByParam = true;
    public bool condictionValue = true;
    public LabelAttribute(string label,string conditionalSourceField)
    {
        if (conditionalSourceField.StartsWith("!"))
        {
            this.ConditionalSourceField = conditionalSourceField.Substring(1);
            condictionValue = false;
        }
        else
        {
            this.ConditionalSourceField = conditionalSourceField;
            condictionValue = true;
        }
        this.Label = "    "+label;
        condiction = false;
        ctrlByParam = true;
    }
    public LabelAttribute(string label, string conditionalSourceField,float min,float max)
    {
        this.Label = "    "+label;
        if (conditionalSourceField.StartsWith("!"))
        {
            this.ConditionalSourceField = conditionalSourceField.Substring(1);
            condictionValue = false;
        }
        else
        {
            this.ConditionalSourceField = conditionalSourceField;
            condictionValue = true;
        }
        condiction = true;
        this.max = max;
        this.min = min;
        this.ctrlByParam = true;
    }
    public LabelAttribute(string label, float min, float max)
    {
        this.Label = label;
        condiction = true;
        this.max = max;
        this.min = min;
        this.ctrlByParam = false;
    }
    public LabelAttribute(string label )
    {
        this.Label = label;
        condiction = false;
        this.ctrlByParam = false;
    }

}
