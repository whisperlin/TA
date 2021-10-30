using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
namespace UnityEditor
{
    public class EnumAttirbute : PropertyAttribute
    {
        /// <summary>
        /// 枚举名称
        /// </summary>
        public string name;
        public EnumAttirbute(string name)
        {
            this.name = name;
        }
    }
    public class LCHEnumDrawer : MaterialPropertyDrawer
    {
        System.Type inputType = typeof(UnityEngine.Rendering.BlendMode);
        public LCHEnumDrawer(string enumName)  
        {
            inputType = System.Type.GetType(enumName);
        }
        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {

            List<string> displays = new List<string>();
            List<int> values = new List<int>();
            int intValue = (int)prop.floatValue;

            FieldInfo[] fields = inputType.GetFields();
            for (int i = 0; i < fields.Length; i++)
            {
                var info = fields[i];
                if (info.FieldType == typeof(System.Int32))
                    continue;
                
                int _value = (int)info.GetValue(null);
                values.Add(_value);
                EnumAttirbute[] enumAttributes = (EnumAttirbute[])info.GetCustomAttributes(typeof(EnumAttirbute), false);
                if (enumAttributes.Length > 0)
                {
                    displays.Add(enumAttributes[0].name);
                }
                else
                {
                    displays.Add(info.Name);
                }
            }
            int[] _intValue = values.ToArray();
            string [] _displays = displays.ToArray();
            int nIntValue = EditorGUILayout.IntPopup(label.text, intValue, _displays, _intValue);
            if (nIntValue != intValue)
            {
                prop.floatValue = nIntValue;
            }
        }
    }
}
 
