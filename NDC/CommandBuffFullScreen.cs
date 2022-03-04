using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
public class CommandBuffFullScreen : MonoBehaviour
{

    public UnityEngine.Rendering.CameraEvent cameraEvent = UnityEngine.Rendering.CameraEvent.AfterForwardOpaque;
    Camera cam;
    private CommandBuffer commandBuffer;
    public Material mat;

    private void OnEnable()
    {
        if (null == cam)
            cam = GetComponent<Camera>();

        cam.depthTextureMode = DepthTextureMode.Depth;

        if (cam.orthographic)
        {
            mat.EnableKeyword("ORTHOGRAPHIC");
        }
        else
        {
            mat.DisableKeyword("ORTHOGRAPHIC");
        }
    
        commandBuffer = new CommandBuffer();
        commandBuffer.name = "Lch Buffer";
        commandBuffer.EnableShaderKeyword("IGORE_VP");
        commandBuffer.DrawMesh(MeshHelper.GetFullScreen(), Matrix4x4.identity, mat);
        commandBuffer.DisableShaderKeyword("IGORE_VP");
        cam.AddCommandBuffer(cameraEvent, commandBuffer);
    }

    private void OnDisable()
    {
        cam.RemoveCommandBuffer(cameraEvent, commandBuffer);
        commandBuffer.Release();
        commandBuffer = null;
    }
}
