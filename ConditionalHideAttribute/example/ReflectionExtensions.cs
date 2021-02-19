using UnityEditor;

using System;
using System.Linq;
using System.Reflection;
using System.Collections.Generic;

// Researched from:
// https://answers.unity.com/questions/929293/get-field-type-of-serializedproperty.html
// https://stackoverflow.com/questions/7072088/why-does-type-getelementtype-return-null

public static class ReflectionExtensions
{
    public static Type GetType(SerializedProperty property)
    {
        string[] splitPropertyPath = property.propertyPath.Split('.');
        Type type = property.serializedObject.targetObject.GetType();

        for (int i = 0; i < splitPropertyPath.Length; i++)
        {
            if (splitPropertyPath[i] == "Array")
            {
                type = type.GetEnumerableType();
                i++; //skip "data[x]"
            }
            else
                type = type.GetField(splitPropertyPath[i], BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.FlattenHierarchy | BindingFlags.Instance).FieldType;
        }

        return type;
    }

    public static Type GetEnumerableType(this Type type)
    {
        if (type == null)
            throw new ArgumentNullException("type");

        if (type.IsGenericType && type.GetGenericTypeDefinition() == typeof(IEnumerable<>))
            return type.GetGenericArguments()[0];

        var iface = (from i in type.GetInterfaces()
                     where i.IsGenericType && i.GetGenericTypeDefinition() == typeof(IEnumerable<>)
                     select i).FirstOrDefault();

        if (iface == null)
            throw new ArgumentException("Does not represent an enumerable type.", "type");

        return GetEnumerableType(iface);
    }
}