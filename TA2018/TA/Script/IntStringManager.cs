using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IntStringManager 
{

    static Dictionary<int, string> temps = new Dictionary<int, string>();
    public static string GetIntString(int c)
    {
        string val;
        if (temps.TryGetValue(c,out val))
        {
            return val;
        }
        val = c.ToString();
        temps[c] = val;
        return val;

    }
}
