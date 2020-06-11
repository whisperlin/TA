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
    }
    class Program
    {
        static void Main(string[] args)
        {
            
            string importExcelPath = @"G:\TA\Excel\Test.xls";
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
                //Dictionary<string, object> row;
                List<string> keys = new List<string>();
                List<TYPE> types = new List<TYPE>();

                for (int j = sheet.FirstRowNum; j < sheet.LastRowNum; j++)
                {
                    Dictionary<string, object> lines = new Dictionary<string, object>();
                    IRow row = (IRow)sheet.GetRow(j);
                    
                    for (int k = row.FirstCellNum; k < row.LastCellNum; k++)
                    {
                        string cellValue = row.GetCell(k).ToString();
                        if (j == sheet.FirstRowNum)
                        {
                            keys.Add(cellValue);
                        }
                        else if (j > sheet.FirstRowNum + 2 && k < keys.Count)
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
                            }
                            catch (Exception e)
                            {
                                System.Console.ForegroundColor = ConsoleColor.Red;
                                System.Console.WriteLine("第{0}行第{1}列{2}:{3}格式出错",j,k,keys[k],cellValue);
                                Console.Read();
                            }
                            
                        }
                        else if (j == sheet.FirstRowNum + 2)
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
                    if (j == sheet.FirstRowNum + 2)
                    {
                        if (keys.Count != types.Count)
                            break;
                    }
                    if (lines.Count > 0)
                        data.Add(lines);
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
