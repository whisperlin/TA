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
        //Look for the sourcefield within the object that the property belongs to
        string propertyPath = property.propertyPath; //returns the property path of the property we want to apply the attribute to
        string conditionPath = propertyPath.Replace(property.name, condHAtt.ConditionalSourceField); //changes the path to the conditionalsource property path
        SerializedProperty sourcePropertyValue = property.serializedObject.FindProperty(conditionPath);

        if (sourcePropertyValue != null)
        {
            enabled = sourcePropertyValue.boolValue;
        }
        else
        {
            Debug.LogWarning("Attempting to use a ConditionalLabelAttribute but no matching SourcePropertyValue found in object: " + condHAtt.ConditionalSourceField);
        }

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
          
            return base.GetPropertyHeight(property, label);
        }
        else
        {
            return 0.1f;
        }
       
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
                else
                {
                    EditorGUI.PropertyField(position, property, label, true);
                }
            }
            else
            {
                EditorGUI.PropertyField(position, property, label, true);
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
    public string ConditionalSourceField = "";
    public string Label = "";
    public bool condiction = false;
    public float max;
    public float min;
    public bool ctrlByParam = true; 

    public LabelAttribute(string label,string conditionalSourceField)
    {
        this.ConditionalSourceField = conditionalSourceField;
      
        this.Label = "    "+label;
        condiction = false;
        ctrlByParam = true;
    }

    public LabelAttribute(string label, string conditionalSourceField,float min,float max)
    {
        this.Label = "    "+label;
        this.ConditionalSourceField = conditionalSourceField;
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