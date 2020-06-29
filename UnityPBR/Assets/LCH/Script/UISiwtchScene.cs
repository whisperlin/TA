using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class UISiwtchScene : MonoBehaviour
{
    public string[] sceneArrays;
    // Start is called before the first frame update
     

    // Update is called once per frame
    public void Next()
    {
        for (int i = 0; i < sceneArrays.Length; i++)
        {
            if (sceneArrays[i] == SceneManager.GetActiveScene().name)
            {
                i++;
                i %= sceneArrays.Length;
                SceneManager.LoadScene(sceneArrays[i]);//level1为我们要切换到的场景
                break;
            }


        }
       
    }
}
