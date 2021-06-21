using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using UnityEngine;

public class HttpHelperHandle
{
    public bool isFinish = false;

    public bool HasError = false;
    public int totalSize = 0;
    public int curSize = 0;
    public System.Exception error;
    public HttpStatusCode statusCode;
    public string txt;
    internal string url;
 
}

public class HttpHelper : MonoBehaviour
{

    public static string GetFileFormatMD5(string file)
    {
        StringBuilder sb = new StringBuilder();
        using (var md5 = System.Security.Cryptography.MD5.Create())
        {
            FileStream fs = new FileStream(file, FileMode.Open, FileAccess.Read);
            byte[] retVal = md5.ComputeHash(fs);
            fs.Close();
            for (int i = 0; i < retVal.Length; i++)
            {
                sb.Append(retVal[i].ToString("x2"));
            }
        }
        return sb.ToString();
    }
    public static HttpHelperHandle StartDownLoad( string url, string path)
    {
        HttpHelperHandle handle = new HttpHelperHandle();
        handle.url = url;
        handle.isFinish = false;
        CoroutineUtil.RunCoroutine(HttpDownloadFile(url, path, handle));
        return handle;
    }

    public static HttpHelperHandle StartDownLoadWithMD5(  string url, string path,string md5)
    {
        HttpHelperHandle handle = new HttpHelperHandle();
        handle.url = url;
        handle.isFinish = false;
        CoroutineUtil.RunCoroutine(HttpDownloadFileWithMD5(url, path, handle, md5));
        return handle;
    }

    public static IEnumerator HttpDownloadFileWithMD5(string url, string path, HttpHelperHandle handle,string md5)   //从Http下载文件
    {
        HttpWebRequest request = null;
        HttpWebResponse response = null;
        Stream responseStream = null;
        Stream stream = null;
        handle.HasError = false;
   
        handle.url = url;
        int size = 0;

        //如果文件存在，检查md5
        if(System.IO.File.Exists(path))
        {
            string _md5 = HttpHelper.GetFileFormatMD5(path);
            if (_md5 == md5)
            {
                handle.isFinish = true;
                goto finish;
            }
        }
        bool reconnend = false;
        //是否断点续传
        string temp = path + ".dltmp";
        long fileLength = 0;
        if (System.IO.File.Exists(path) && System.IO.File.Exists(temp))
        {
            string _md5 = System.IO.File.ReadAllText(temp);
            fileLength = new System.IO.FileInfo(path).Length;
            if (_md5 == md5)
            {
                reconnend = true;
            }
        }
        //非写入新md5
        if(!reconnend)
            System.IO.File.WriteAllText(temp, md5);
        //byte[] bArr = new byte[1024 * 128];
        byte[] bArr = new byte[500];
        try
        {
#if UNITY_ANDROID
            Debug.LogError("WebRequest" + url);
#endif
            request = WebRequest.Create(url) as HttpWebRequest;
            //发送请求并获取相应回应数据
            if (reconnend)
            {
                request.AddRange(fileLength);
            }

            response = request.GetResponse() as HttpWebResponse;
            handle.statusCode = response.StatusCode;
            if (response.StatusCode == HttpStatusCode.OK|| response.StatusCode == HttpStatusCode.PartialContent)
            {
                handle.totalSize = (int)response.ContentLength;
                responseStream = response.GetResponseStream();
                if (reconnend)
                {
                    //创建本地文件写入流
                    stream = new FileStream(path, FileMode.Append);
                    //responseStream.Seek(fileLength,SeekOrigin.Begin);
                }
                else
                {
                    //创建本地文件写入流
                    stream = new FileStream(path, FileMode.Create);
                    
                }
                size = responseStream.Read(bArr, 0, (int)bArr.Length);
            }
            else
            {
                size = 0;
                handle.isFinish = true;
                handle.error = null;
 
            }



        }
        catch (System.Exception e)
        {
            handle.isFinish = true;
            handle.error = e;
            handle.HasError = true;
 
        }
 
        while (size > 0)
        {
            stream.Write(bArr, 0, size);
            handle.curSize += size;
            try
            {
                size = responseStream.Read(bArr, 0, (int)bArr.Length);

            }
            catch (System.Exception e)
            {
                handle.isFinish = true;
                handle.error = e;
                handle.HasError = true;
 
            }
            yield return null;
        }
       
        if (null != stream)
            stream.Close();
        if (null != responseStream)
            responseStream.Close();
        if (null != request)
            request.Abort();
        finish:
        handle.isFinish = true;
    }
    public static IEnumerator HttpDownloadFile(string url, string path, HttpHelperHandle handle)   //从Http下载文件
    {
        HttpWebRequest request = null;
        HttpWebResponse response = null;
        Stream responseStream = null;
        Stream stream = null;
        handle.HasError = false;
        handle.url = url;
        int size = 0;
        
        byte[] bArr = new byte[1024*128];
        try
        {
#if UNITY_ANDROID
            Debug.LogError("WebRequest" + url);
#endif
            request = WebRequest.Create(url) as HttpWebRequest;
            //发送请求并获取相应回应数据
            response = request.GetResponse() as HttpWebResponse;
            handle.statusCode = response.StatusCode;
            if (response.StatusCode == HttpStatusCode.OK)
            {
                handle.totalSize = (int)response.ContentLength;
                //直到request.GetResponse()程序才开始向目标网页发送Post请求
                responseStream = response.GetResponseStream();

                //创建本地文件写入流
                stream = new FileStream(path, FileMode.Create);
                //stream.Dispose();//防止错误IOException: Sharing violation on path 的解决方案
                size = responseStream.Read(bArr, 0, (int)bArr.Length);
            }
            else
            {
                size = 0;
                handle.isFinish = true;
                handle.error = null;
                handle.HasError = true;
                handle.statusCode = response.StatusCode;
            }

            
           
        }
        catch (System.Exception e)
        {
            handle.isFinish = true;
            handle.error = e;
            handle.HasError = true;
            handle.statusCode = response.StatusCode;
        }

        while (size > 0)
        {
            stream.Write(bArr, 0, size);
            handle.curSize += size;
            size = responseStream.Read(bArr, 0, (int)bArr.Length);
            yield return null;
        }
        
        if (null != stream)
            stream.Close();
        if (null != responseStream)
            responseStream.Close();
        if (null != request)
            request.Abort();
        handle.isFinish = true;

    }

    public static HttpHelperHandle StartGetText(  string url )
    {
        HttpHelperHandle handle = new HttpHelperHandle();
        handle.url = url;
        handle.isFinish = false;
        CoroutineUtil.RunCoroutine(GetText(url, handle));
        return handle;
    }
    public static IEnumerator GetText(string url,   HttpHelperHandle handle)   //从Http下载文件
    {
   
        HttpWebRequest request = null;
        HttpWebResponse response = null;
        Stream responseStream = null;
         
        handle.HasError = false;
        handle.url = url;
        handle.txt = "";
        int size = 0;
        MemoryStream memStream = new MemoryStream(1024 * 128);
        // 设置参数string
        byte[] bArr = new byte[1024 * 128];
        try
        {
#if UNITY_ANDROID
            Debug.LogError("WebRequest" + url);
#endif
            request = WebRequest.Create(url) as HttpWebRequest;
            //发送请求并获取相应回应数据
            response = request.GetResponse() as HttpWebResponse;
            handle.statusCode = response.StatusCode;
            if (response.StatusCode == HttpStatusCode.OK)
            {
                handle.totalSize = (int)response.ContentLength;
                //直到request.GetResponse()程序才开始向目标网页发送Post请求
                responseStream = response.GetResponseStream();

                //stream.Dispose();//防止错误IOException: Sharing violation on path 的解决方案
                size = responseStream.Read(bArr, 0, (int)bArr.Length);
            }
            else
            {
                size = 0;
                handle.isFinish = true;
                handle.error = null;
                handle.HasError = true;
                handle.statusCode = response.StatusCode;
            }



        }
        catch (System.Exception e)
        {
            handle.isFinish = true;
            handle.error = e;
            handle.HasError = true;
            handle.statusCode = response.StatusCode;
        }

        while (size > 0)
        {
            memStream.Write(bArr, 0, size);
            
            //stream.Write(bArr, 0, size);
            handle.curSize += size;
            size = responseStream.Read(bArr, 0, (int)bArr.Length);
            yield return null;
        }
        if (null != responseStream)
            responseStream.Close();
        if (null != request)
            request.Abort();
        handle.txt = System.Text.Encoding.UTF8.GetString(memStream.ToArray());
        handle.isFinish = true;

    }

}
