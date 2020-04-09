using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class FileHelper  {
        
        static void GetAllFile(string path, List<string> files)
        {
            DirectoryInfo theFolder = new DirectoryInfo(@path);
            //遍历文件
            foreach (FileInfo NextFile in theFolder.GetFiles())
            {
                files.Add(NextFile.FullName);
            }
            //遍历文件夹
            foreach (DirectoryInfo NextFolder in theFolder.GetDirectories())
            {
                GetAllFile(NextFolder.FullName,files);
            }
        }
 
       public static List<string> GetAllFile(string path) {
            List<string> files = new List<string>();
            GetAllFile(path, files);
            return files;
        }
	 
}
