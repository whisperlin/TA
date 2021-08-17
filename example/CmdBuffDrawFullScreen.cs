using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent( typeof(Camera))]
public class CmdBuffDrawFullScreen : MonoBehaviour
{
    public Camera cam;
    public Material mat;

    [SerializeField] private RenderTexture sssmRT;
    private Mesh mesh;
    private CommandBuffer cmdBuff;
    private void Start()
    {
        cam = GetComponent<Camera>();
 
        cam.depthTextureMode |= DepthTextureMode.Depth;

        mesh = new Mesh();
        mesh.vertices = new Vector3[]
        {
            new Vector3(-1,1,0),    // bl
            new Vector3(-1,-1,0),   // tl
            new Vector3(1,-1,0),    // tr
            new Vector3(1,1,0),     // br
        };
        mesh.uv = new Vector2[]
        {
            new Vector2(0,0),       // bl
            new Vector2(0,1),       // tl
            new Vector2(1,1),       // tr
            new Vector2(1,0),       // br
        };
        mesh.triangles = new int[]
        {
            0, 1, 2,
            0, 2, 3
        };
    }
    private void OnPreRender()
    {
        if (sssmRT == null || sssmRT.width != Screen.width || sssmRT.height != Screen.height)
        {
            if (sssmRT) RenderTexture.ReleaseTemporary(sssmRT);
            sssmRT = RenderTexture.GetTemporary(Screen.width, Screen.height, 0);//, RenderTextureFormat.R8);
            sssmRT.name = "sssmRT";

            if (cmdBuff == null)
            {
                cmdBuff = new CommandBuffer();
                cmdBuff.name = "After Depth TEX";
            }

            cmdBuff.Clear();

            cmdBuff.SetRenderTarget(sssmRT);
            cmdBuff.ClearRenderTarget(true, true, Color.white);

            cmdBuff.DrawMesh(mesh, Matrix4x4.identity, mat);

            cam.RemoveCommandBuffer(CameraEvent.AfterDepthTexture, cmdBuff);
            cam.AddCommandBuffer(CameraEvent.AfterDepthTexture, cmdBuff);
        }
    }

    private void OnDestroy()
    {
        if (sssmRT) RenderTexture.ReleaseTemporary(sssmRT);

        if (cam != null && cmdBuff != null)
        {
            cam.RemoveCommandBuffer(CameraEvent.AfterDepthTexture, cmdBuff);
            cmdBuff.Release();
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(sssmRT, (RenderTexture)null);
    }
}