//#define DEBUG_HTTP_MANAGER
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using System.Threading;
using UnityEngine;


[ExecuteInEditMode]
public class HttpManager   : MonoBehaviour
{
    static HttpManager self;
#if UNITY_EDITOR
    private void Update()
    {
        //这个用来在编辑器停止运行时关掉线程
        if (!Application.isPlaying)
        {
            Release();
            GameObject.DestroyImmediate(this.gameObject);
        }
    }
#endif
    private void OnDisable()
    {
        Release();
    }
    private void OnDestroy()
    {
        Release();
    }
    /// <summary>
    /// 线程休眠时间 默认值50
    /// </summary>
    public static int SleepTime
    {
        get => sleepTime; set
        {
            if (value < 1)
                value = 1;
            sleepTime = value;
            halfSleepTime = Mathf.Max(sleepTime / 2, 1)
;        }
    }
    /// <summary>
    /// 线程休眠时间 默认值50
    /// </summary>
    public static int MaxReadSize
    {
        get => maxReadSize; set
        {
            if (value < 1)
                value = 1;
            maxReadSize = Mathf.Min(maxReadSize, BUFFER_SIZE);
            maxReadSize = value;
        }
    }
    public static int Timeout
    {
        get => timeout;
        set
        {
            if (value < 5000)
                value = 5000;
            timeout = value;
        }
    }
    public static int ReadWriteTimeout
    {
        get => readWriteTimeout;
        set
        {
            if (value < 3000)
                value = 3000;
            readWriteTimeout = value;
        }
    }
    
    const int BUFFER_SIZE = 1024 * 256;
    static int maxReadSize = BUFFER_SIZE;
    static byte[] tempBuffer = new byte[BUFFER_SIZE];

    //已经下载成功的文件的句柄.
    static HashSet<int> scuessHash = new HashSet<int>();

    static Dictionary<int, HttpHandle> downloading = new Dictionary<int, HttpHandle>();

    static SimpleClassPool<HttpNode> nodes = new SimpleClassPool<HttpNode>();
    static HttpHandle scuessHandle = new HttpHandle(true);
    static HttpNodeArray array = new HttpNodeArray();

    static Thread thread;
    static bool isRuning = true;
    static int sleepTime = 60;
    static int halfSleepTime = 30;
    static int timeout = 60000;
    static int readWriteTimeout = 10000;


    private static bool pause = false;
    public static bool Pause
    {
        get { return pause; }
        set { pause = value; }
    }

    public static void Release()
    {
        Debug.LogError("closs download thread");
        isRuning = false;
#if UNITY_EDITOR
        if (null != thread)
            thread.Abort();
#endif
        thread = null;
        
    }
    public static HttpHandle StartDownLoadWithMD5(string url, string path, string md5, bool priority)
    {
 
        if (null == thread)
        {
            GameObject g = new GameObject("HttpManager");
            g.hideFlags = HideFlags.DontSaveInEditor;
            Debug.LogError("add clost listen");
            GameObject.DontDestroyOnLoad(g);
            //这个只是为了退出游戏时释放线程.
            self = g.AddComponent<HttpManager>();

            thread = new Thread(DownLoadThread);
            thread.Priority = System.Threading.ThreadPriority.BelowNormal;
            isRuning = true;
            thread.Start();
        }
        int hashCode = url.GetHashCode();
        //已经下载成功的直接返回.
        HttpHandle handle;
        if (scuessHash.Contains(hashCode))
        {
#if DEBUG_HTTP_MANAGER
            Debug.Log("文件已经下载过了"+ url);
#endif
            
            return scuessHandle;
        }
        //下载队列中
        if (downloading.TryGetValue(hashCode, out handle))
        {
            if (!handle.node.priority && priority)
            {
                handle.node.priority = priority;
                array.RemoveNode(handle.node);
                array.AddNode(handle.node);
            }
            //priority
            return handle;
        }
        //添加入下载队列。
        handle = new HttpHandle();
        handle.url = url;
        handle.isFinish = false;
        handle.savePath = path;
        handle.md5 = md5;
        downloading.Add(hashCode, handle);

        HttpNode node = new HttpNode();
        node.priority = priority;
        node.handle = handle;
        handle.node = node;
        array.AddNode(node);
        return handle;
    }
    static void DownLoadThread()
    {
        while (isRuning)
        {
            if (pause || array.IsEmpty())
            {
                Thread.Sleep(100);
            }
            else
            {
                HttpNode node = DownLoad();
                if (node.handle.isFinish && node.handle.scuess)
                {
                    downloading.Remove(node.handle.url.GetHashCode());
                    array.RemoveNode(node);
                    node.handle.node = null;
     
                    scuessHash.Add(node.handle.url.GetHashCode());
                }
            }
        }
    }
    
    static HttpNode DownLoad()
    {
        HttpNode node =  array.GetBegin();
        HttpNode curBegin = null;
        HttpHandle handle = node.handle;
        HttpWebRequest request = null;
        HttpWebResponse response = null;
        Stream responseStream = null;
        Stream stream = null;
        handle.statusCode = HttpStatusCode.OK;
        handle.error = null;
        int size = 0;
        //如果文件存在，检查md5
        if (System.IO.File.Exists(handle.savePath))
        {
            string _md5 = HttpHelper.GetFileFormatMD5(handle.savePath);
            if (_md5 == handle.md5)
            {
#if DEBUG_HTTP_MANAGER
                Debug.Log("本地md5一致" + handle.url);
#endif
                handle.isFinish = true;
                handle.scuess = true;
                goto finish;
            }
        }
        string saveDir = Path.GetDirectoryName(handle.savePath);
        //判断保存路径是否存在
        if (!Directory.Exists(saveDir))
        {
            Directory.CreateDirectory(saveDir);
        }
        bool reconnend = false;
        //是否断点续传
        string temp = handle.savePath + ".dltmp";
        long fileLength = 0;
        if (System.IO.File.Exists(handle.savePath) && System.IO.File.Exists(temp))
        {
            string _md5 = System.IO.File.ReadAllText(temp);
            fileLength = new System.IO.FileInfo(handle.savePath).Length;
            if (_md5 == handle.md5)
            {
                reconnend = true;
            }
        }
       
        bool isFinish = false;
        try
        {
#if DEBUG_HTTP_MANAGER
            Debug.Log("开始下载" + handle.url);
#endif
#if UNITY_ANDROID
            Debug.LogError("WebRequest" + handle.url);
#endif
            request = WebRequest.Create(handle.url) as HttpWebRequest;
            request.Timeout = timeout;
            request.ReadWriteTimeout = readWriteTimeout;
            if (reconnend)
            {
                request.AddRange(fileLength);
            }
            //发送请求并获取相应回应数据
            response = request.GetResponse() as HttpWebResponse;
            handle.statusCode = response.StatusCode;

            if (response.StatusCode == HttpStatusCode.OK || response.StatusCode == HttpStatusCode.PartialContent)
            {
                //handle.totalSize = Mathf.Max(handle.totalSize, (int)response.ContentLength);
                responseStream = response.GetResponseStream();
                if (reconnend)
                {
                    //创建本地文件写入流
                    stream = new FileStream(handle.savePath, FileMode.Append);
                }
                else
                {
                    //创建本地文件写入流
                    stream = new FileStream(handle.savePath, FileMode.Create);
                }
#if DEBUG_HTTP_MANAGER
                Debug.Log("第一次取" + handle.url);
#endif
                size = responseStream.Read(tempBuffer, 0, maxReadSize);
            }
            else
            {
                size = 0;
                handle.error = null;
            }
            while (size > 0)
            {
                if (!isRuning)
                    goto closeSocke;
                stream.Write(tempBuffer, 0, size);
                handle.curSize += size;

                if (size < handle.totalSize)
                {
                    if (!reconnend)
                    {
                        System.IO.File.WriteAllText(temp, handle.md5);
                        reconnend = true;
                    }
                   
                }
                
               

                if (pause)
                {
                    goto closeSocke;
                }
                if (node.priority)
                {
                    Thread.Sleep(halfSleepTime);
                }
                else
                {
                    curBegin = array.GetBegin();
                    if (curBegin != null && curBegin.priority)
                    {
                        goto closeSocke;
                    }
                    Thread.Sleep(sleepTime);
                }
                
                size = responseStream.Read(tempBuffer, 0, maxReadSize);
 
                
                

            }
            isFinish = true;
            handle.error = null;
            if (reconnend)
            {
                if(System.IO.File.Exists(temp))
                    System.IO.File.Delete(temp);
            }
            
        }
        catch (System.Net.WebException ex)
        {
            Debug.LogError(ex);

            if (ex.Status == WebExceptionStatus.ProtocolError &&  ex.Response != null)
            {
                var resp = (HttpWebResponse)ex.Response;
                handle.statusCode = resp.StatusCode;
                if (resp.StatusCode == HttpStatusCode.NotFound)
                {
 
                    //Debug.LogError("无法找到文件" + handle.url);
                    handle.isFinish = true;
                    handle.scuess = false;


                }
                else
                {
          
                }
            }
            else
            {
                 
            }
             
        }
        catch (System.Exception e)
        {
            handle.error = e;
            
        }
        closeSocke:
        try
        {
            
            if (null != responseStream)
                responseStream.Close();
            if (null != stream)
                stream.Close();
            Thread.Sleep(10);
            if (isFinish)
            {
                //下载完之后校验md5
                string _md5 = HttpHelper.GetFileFormatMD5(handle.savePath);
                if (_md5 == handle.md5)
                {
#if DEBUG_HTTP_MANAGER
                    if (handle.node.priority)
                        Debug.Log("下载" + handle.url + "成功" + handle.node.priority);
#endif
                    
                    handle.isFinish = true;
                    handle.scuess = true;
                }
                else
                {
                    //重新下载后md5依然出错.
                    if (handle.lastErrorMd5 == _md5)
                    {
                        handle.isFinish = true;
                        handle.scuess = true;
#if DEBUG_HTTP_MANAGER
                   
                        Debug.LogError("md5不一致，服务器上的就是它了 " + handle.url + " "+ _md5);
#endif
                    }
                    else
                    {
                        handle.isFinish = false;
                        handle.lastErrorMd5 = _md5;

                        Debug.LogError("md5不一致，重新下载" + handle.url);
                    }
                   
                }
            }
            
        }
        catch (System.Exception e)
        {
            handle.error = e;
        }
        finish:
        
        return node;
    }
}


public class HttpHandle
{
    public HttpHandle()
    {
    }
    public HttpHandle(bool isFinish)
    {
        this.isFinish = isFinish;
        this.scuess = true;
    }
    public bool isFinish = false;
    public int totalSize = 0;
    public int curSize = 0;
    public System.Exception error = null;
    public string url;
    public string savePath;
    public string md5;
    public string lastErrorMd5;
    public HttpStatusCode statusCode;
    public HttpNode node = null;
    public string txt;

    public bool scuess = false;
}

public class HttpNode
{
    /*public int id = 0;
    static int _count = 0;
    public HttpNode()
    {
        id = _count++;
    }*/
    public bool priority;
    public HttpNode next = null;
    public HttpNode before = null;
    public HttpHandle handle;

    /* ~HttpNode()
    {
        Debug.LogError("Release HttpNode"  );
    }*/
}
public class HttpNodeArray
{
    HttpNode begin = null;
    HttpNode end = null;
    private static object locker = new object();//创建锁
    public HttpNodeArray()
    {
    }
    public bool IsEmpty()
    {
        return begin == null;
    }
    public void AddNode(HttpNode node)
    {
        //Debug.Log("AddNode " + node.id);
        lock (locker)
        {
            if (begin == null)
            {
                begin = end = node;
                node.next = null;
                node.before = null;
                //goto finish;
                return;
            }
            if (node.priority)
            {
                if (begin.priority)
                {
                    var p = begin;
                    while (true)
                    {
                        //队尾
                        if (p == end)
                        {
                            p.next = node;
                            node.before = p;
                            node.next = null;
                            end = node;
                            //goto finish;
                            return;
                        }
                        else if (p.next.priority)
                        {
                            p = p.next;
                        }
                        else
                        {
                            node.next = p.next;
                            node.before = p;
                            p.next = node;
                            //PrintArray();
                            //goto finish;
                            return;
                        }
                    }
                }
                else
                {
                    node.next = begin;
                    begin = node;
                }
            }
            else
            {
                //队尾。
                end.next = node;
                node.next = null;
                node.before = end;
                end = node;
            }
        }
        //finish:
        //PrintArray();
    }

    /* public void PrintArray()
     {
         string txt = "";
         var p = begin;
         while (p != null)
         {
             txt += p.id  + "("+p.priority+") ";
             p = p.next;
         }
         Debug.Log(txt);
     }*/
    public HttpNode GetBegin()
    {
        return begin;
    }

    public void RemoveNode(HttpNode node)
    {
        //Debug.Log("RemoveNode "+node.id);
        if (null == node)
            return;
        lock (locker)
        {
            if (node == begin)
            {
                begin = begin.next;
                if (null == begin)
                    end = null;
                else
                    begin.before = null;


            }
            else
            {
                var p0 = node.before;
                var p1 = node.next;
                p0.next = p1;
                if (null != p1)
                    p1.before = p0;

            }
        }

        node.next = null;
        node.before = null;
        //PrintArray();
    }
}