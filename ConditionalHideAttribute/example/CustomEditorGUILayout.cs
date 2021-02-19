using UnityEngine;
using UnityEditor;
 
public static class CustomEditorGUILayout
{
    public static bool PropertyField(SerializedProperty property, params GUILayoutOption[] options)
    {
        return PropertyField(property, new GUIContent(property.displayName), false, options);
    }

    public static bool PropertyField(SerializedProperty property, GUIContent label, params GUILayoutOption[] options)
    {
        return PropertyField(property, label, false, options);
    }

    public static bool PropertyField(SerializedProperty property, bool includeChildren, params GUILayoutOption[] options)
    {
        return PropertyField(property, new GUIContent(property.displayName), includeChildren, options);
    }

    public static bool PropertyField(SerializedProperty property, GUIContent label, bool includeChildren, params GUILayoutOption[] options)
    {
        if (includeChildren || property.propertyType == SerializedPropertyType.Generic)
        {
            property.isExpanded = EditorGUILayout.Foldout(property.isExpanded, property.displayName);
            if (includeChildren && property.isExpanded)
            {
                foreach (SerializedProperty childProperty in property)
                    PropertyField(childProperty, new GUIContent(property.displayName), false, options);
            }

            return false;
        }
        Rect position = EditorGUILayout.GetControlRect(label.text.Length > 0, EditorGUI.GetPropertyHeight(property), options);
        CustomEditorGUI.PropertyField(position, property, label, includeChildren);
        return property.hasChildren && property.isExpanded && !includeChildren;
    }
}