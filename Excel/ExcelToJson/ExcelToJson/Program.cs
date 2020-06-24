using Newtonsoft.Json;
using NPOI.SS.UserModel;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExcelToJson
{
    public enum TYPE
    {
        String,
        Int,
        Float,
        Enum,
    }
    public struct Remap
    {
        public string name;
        public string condiction;
        public int condictionValue;
        public int index;
  
    }
    class Program
    {
        static void Main(string[] args)
        {
            
            string importExcelPath = @"G:\TA\Excel\skill.xls";
            string outDir = "out";
            if (args.Length > 0)
            {
                importExcelPath = args[0];
                outDir = args[1];
            }
            if (!Directory.Exists(outDir))
            {
                Directory.CreateDirectory(outDir);
            }
            IWorkbook workbook = WorkbookFactory.Create(importExcelPath);
            
            for (int i = 0; i < workbook.NumberOfSheets; i++)
            {
                ISheet sheet = workbook.GetSheetAt(i);
                System.Console.WriteLine("table name {0}", sheet.SheetName);

                List<Dictionary<string, object>> data = new List<Dictionary<string, object>>();
 
                List<string> keys = new List<string>();
                Dictionary<int,Dictionary<string,int>> enums = new Dictionary<int,Dictionary<string, int>>();
                List<TYPE> types = new List<TYPE>();
                List<Remap> remaps = new List<Remap>();
                int r_id = -1;
                int r_type = -1;
                int r_enum = -1;
                int r_remap = -1;
                int r_data = -1;
                for (int j = sheet.FirstRowNum ; j <= sheet.LastRowNum; j++ )
                {
                    Dictionary<string, object> lines = new Dictionary<string, object>();
                    IRow row = (IRow)sheet.GetRow(j);
                    if (row == null)
                        continue;
                    if (j == sheet.FirstRowNum+1)
                    {
                        if (r_id == -1 || r_type == -1 || r_enum == -1 || r_data == -1)
                            break;
                    }
 
                    for (int k = row.FirstCellNum, cellIdZeroBase = 0; k <= row.LastCellNum; k++, cellIdZeroBase++)
                    {
                        var cell = row.GetCell(k);
                        if (null == cell)
                            continue;
                        string cellValue = cell.ToString();
                        if (j == 0)
                        {
                            if (cellIdZeroBase == 0)
                            {
                                try
                                {
                                    r_id = int.Parse(cellValue);
                                }
                                catch (Exception e)
                                {
                                }
                            }
                            if (cellIdZeroBase == 1)
                            {
                                try
                                {
                                    r_type = int.Parse(cellValue);
                                }
                                catch (Exception e)
                                {
                                }
                            }
                            if (cellIdZeroBase == 2)
                            {
                                try
                                {
                                    r_enum = int.Parse(cellValue);
                                }
                                catch (Exception e)
                                {
                                }
                            }
                            if (cellIdZeroBase == 3)
                            {
                                try
                                {
                                    r_remap = int.Parse(cellValue);
                                }
                                catch (Exception e)
                                {
                                }
                            }
                            if (cellIdZeroBase == 4)
                            {
                                try
                                {
                                    r_data = int.Parse(cellValue);
                                }
                                catch (Exception e)
                                {
                                }
                            }
                        }
                        else if (j == r_id)
                        {
                            if(cellValue.Length>0)
                                keys.Add(cellValue);
                        }
                        //remaps
                        else if (j == r_remap)
                        {
                            
                             
                            try
                            {
                                if (cellValue.Length > 0)
                                {
                                    Remap rm = new Remap();
                                    string[] ls = cellValue.Split('|');
                                    rm.name = ls[0];
                                    rm.condiction = ls[1];
                                    rm.condictionValue = int.Parse(ls[2]);
                                    rm.index = k;
                                    remaps.Add(rm);
                                }
                                
                            }
                            catch (Exception e)
                            {
                                System.Console.ForegroundColor = ConsoleColor.Red;
                                System.Console.WriteLine("第{0}行第{1}列{2}:{3} remap 定义错误", j, k, keys[k], cellValue);
                                Console.Read();
                            }
                           
                        }
                        else if (j == r_enum)
                        {
                            Dictionary<string, int> dict = new Dictionary<string, int>();
                            string[]  ls = cellValue.Split(',');
                            for (int eid = 0; eid < ls.Length; eid++)
                            {
                                dict[ls[eid] ] = eid;
                            }
                            enums[k] = dict;
                        }
                        else if (j >= r_data && k < keys.Count)
                        {
                            try
                            {
                                if (types[k] == TYPE.String)
                                {
                                    lines[keys[k]] = cellValue;
                                }
                                else if (types[k] == TYPE.Int)
                                {
                                    lines[keys[k]] = int.Parse(cellValue);
                                }
                                else if (types[k] == TYPE.Float)
                                {
                                    lines[keys[k]] = float.Parse(cellValue);
                                }
                                else if (types[k] == TYPE.Enum)
                                {
                                    //enums
                                    lines[keys[k]] = enums[k][cellValue];//float.Parse(cellValue);
                                }
                            }
                            catch (Exception e)
                            {
                                System.Console.ForegroundColor = ConsoleColor.Red;
                                System.Console.WriteLine("第{0}行第{1}列{2}:{3}格式出错\n{4}",j,k,keys[k],cellValue,e.ToString());
                                Console.Read();
                            }
                            
                        }
                        else if (j == r_type)
                        {
                            if (cellValue.Length > 0)
                            {
                                TYPE type = TYPE.String;
                                try
                                {
                                    type = (TYPE)Enum.Parse(typeof(TYPE), cellValue, true);
                                }
                                catch (Exception e)
                                {

                                }
                                types.Add(type);
                            }
                                
                        }
                    }
                    if (j == r_type)
                    {
                        if (keys.Count != types.Count)
                            break;
                    }
                    if (lines.Count > 0)
                        data.Add(lines);
                }
                foreach (var line in data)
                {
                    foreach (Remap value  in remaps)
                    {
                        int val = (int)line[value.condiction];
                        if (value.condictionValue == val)
                        {
                            line[value.name] = line[keys[value.index]];
                        }
                        line.Remove( keys[value.index]);
                    }
                }
                
               
                if (keys.Count > 0)
                {
                    
                    string jsonText = JsonConvert.SerializeObject(data);

                    System.IO.File.WriteAllText(outDir + "/" + sheet.SheetName + ".json", jsonText);
                }
                
            }

            

        }
    }
}
