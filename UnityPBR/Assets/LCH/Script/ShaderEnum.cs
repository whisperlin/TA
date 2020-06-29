using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ShaderEnum
{
    public enum CullMode
    {
        Off = UnityEngine.Rendering.CullMode.Back,
        On = UnityEngine.Rendering.CullMode.Off
    }
}
 