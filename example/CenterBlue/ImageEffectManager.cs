using System;
using System.Collections;
using System.Collections.Generic;
using Kino;
using UnityEngine;

public delegate void RenderImageEffectDelegate(RenderTexture source, RenderTexture destination);

public interface LchImageEffectInterface
{
    int GetPriority();

    bool isEffectEnable();
    void OnRenderImageEffect(RenderTexture source, RenderTexture destination);
}

[RequireComponent(typeof(LchImageEffect))]
[ExecuteInEditMode]
[DisallowMultipleComponent]
public class ImageEffectManager : MonoBehaviour,IComparer<LchImageEffectInterface>
{

#if UNITY_EDITOR
    private void Update()
    {
        this.hideFlags = HideFlags.HideInInspector;

    }
#endif

    public LchImageEffect effect;

    private void Start()
    {

    }
    public List<LchImageEffectInterface> handles = new List<LchImageEffectInterface>();
 
    public void OnPreRender()
    {
        if(null== effect)
            effect =   GetComponent<LchImageEffect>();
        int enableCount = 0;
        effect.Clear();
        for (int i = 0; i < handles.Count; i++)
        {
            var v = handles[i];
            if (v.isEffectEnable())
            {
                enableCount++;
                effect.Add(v.OnRenderImageEffect);
            }
        }

        if (enableCount == 0)
        {
            effect.enabled = false;
        }
        else
        {
            effect.enabled = true;
        }
    }

    internal void Add(LchImageEffectInterface i)
    {
        handles.Add(i);

        handles.Sort(Compare);
    }

    internal void Remove(LchImageEffectInterface i)
    {
        handles.Remove(i);
    }

    public int Compare(LchImageEffectInterface x, LchImageEffectInterface y)
    {
        return x.GetPriority() - y.GetPriority();
    }
}
