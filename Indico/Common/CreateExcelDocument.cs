using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
//using Microsoft.Office.Tools.Excel;
using Excel = Microsoft.Office.Interop.Excel;
using System.Diagnostics;

using Indico.BusinessObjects;
using Microsoft.Office.Core;
using System.Runtime.InteropServices;
using System.IO;

namespace Indico.Common
{
    class CreateExcelDocument
    {
        private Excel.Application xlApp = new Excel.Application();
        private Excel.Workbook xlWorkBook = null;
        private Excel.Worksheet xlWorkSheet = null;
        private Excel.Range workSheet_range = null;
        private object misValue = System.Reflection.Missing.Value;
        private object missing = System.Reflection.Missing.Value;

        public CreateExcelDocument(string folderPath, string fileName, float width, float height, float topPadding, bool isCarton)
        {
            if (isCarton)
            {
                CreateCartonBarcodeDocument(folderPath, fileName, width, height, topPadding);
            }
            else
            {
                CreatePolyBagBarcodeDocument(folderPath, fileName, width, height, topPadding);
            }
        }

        public CreateExcelDocument(bool isPrice)
        {
            CreateDocument(isPrice);
        }

        public CreateExcelDocument()
        {

        }

        public CreateExcelDocument(string openfilePath)
        {
            OpenDocument(openfilePath);
        }

        public void CreateDocument(bool isPrice)
        {
            try
            {
                xlApp.Visible = true;
                xlWorkBook = xlApp.Workbooks.Add(1);
                xlWorkSheet = (Excel.Worksheet)xlWorkBook.Sheets[1];

                if (isPrice)
                {
                    xlWorkSheet.Cells[1, 1].EntireColumn.ColumnWidth = 13;  // A
                    xlWorkSheet.Cells[1, 2].EntireColumn.ColumnWidth = 30;  // B
                    xlWorkSheet.Cells[1, 3].EntireColumn.ColumnWidth = 10;  // C
                    xlWorkSheet.Cells[1, 4].EntireColumn.ColumnWidth = 36;  // D
                    xlWorkSheet.Cells[1, 5].EntireColumn.ColumnWidth = 50; // E
                    xlWorkSheet.Cells[1, 6].EntireColumn.ColumnWidth = 40;  // F
                    xlWorkSheet.Cells[1, 7].EntireColumn.ColumnWidth = 10;  // G
                    xlWorkSheet.Cells[1, 8].EntireColumn.ColumnWidth = 10;  // H
                    xlWorkSheet.Cells[1, 9].EntireColumn.ColumnWidth = 10;  // I
                    xlWorkSheet.Cells[1, 10].EntireColumn.ColumnWidth = 10;  // J
                    xlWorkSheet.Cells[1, 11].EntireColumn.ColumnWidth = 10;  // K
                    xlWorkSheet.Cells[1, 12].EntireColumn.ColumnWidth = 10;  // L
                    xlWorkSheet.Cells[1, 13].EntireColumn.ColumnWidth = 10;  // M
                    xlWorkSheet.Cells[1, 14].EntireColumn.ColumnWidth = 10;  // N
                    xlWorkSheet.Cells[1, 15].EntireColumn.ColumnWidth = 10;  // O
                    xlWorkSheet.Cells[1, 16].EntireColumn.ColumnWidth = 10;  // P
                    xlWorkSheet.Cells[1, 17].EntireColumn.ColumnWidth = 10;  // Q
                    xlWorkSheet.Cells[1, 18].EntireColumn.ColumnWidth = 10;  // R
                    xlWorkSheet.Cells[1, 19].EntireColumn.ColumnWidth = 10;  // S
                    xlWorkSheet.Cells[1, 20].EntireColumn.ColumnWidth = 10;  // T
                    xlWorkSheet.Cells[1, 21].EntireColumn.ColumnWidth = 10;  // U
                    xlWorkSheet.Cells[1, 22].EntireColumn.ColumnWidth = 10;  // V
                    xlWorkSheet.Cells[1, 23].EntireColumn.ColumnWidth = 10;  // W
                    xlWorkSheet.Cells[1, 24].EntireColumn.ColumnWidth = 10;  // X
                    xlWorkSheet.Cells[1, 25].EntireColumn.ColumnWidth = 10;  // Y
                    xlWorkSheet.Cells[1, 26].EntireColumn.ColumnWidth = 10;  // Z
                    xlWorkSheet.Cells[1, 27].EntireColumn.ColumnWidth = 10;  // AA
                    xlWorkSheet.Cells[1, 28].EntireColumn.ColumnWidth = 10;  // AB
                    xlWorkSheet.Cells[1, 29].EntireColumn.ColumnWidth = 10;  // AC
                    xlWorkSheet.Cells[1, 30].EntireColumn.ColumnWidth = 10;  // AD

                    xlWorkSheet.Application.ActiveWindow.SplitRow = 6;
                    xlWorkSheet.Application.ActiveWindow.SplitColumn = 6;
                    xlWorkSheet.Application.ActiveWindow.FreezePanes = true;
                    //xlApp.ErrorCheckingOptions.BackgroundChecking = false;
                    //xlApp.ErrorCheckingOptions.NumberAsText = false;
                    xlWorkSheet.Application.ErrorCheckingOptions.BackgroundChecking = false;
                    xlWorkSheet.Application.ErrorCheckingOptions.NumberAsText = false;
                }
                else
                {
                    xlWorkSheet.Cells[1, 1].EntireColumn.ColumnWidth = 20;  // A
                    xlWorkSheet.Cells[1, 2].EntireColumn.ColumnWidth = 2.7;  // B
                    xlWorkSheet.Cells[1, 3].EntireColumn.ColumnWidth = 2.7;  // C
                    xlWorkSheet.Cells[1, 4].EntireColumn.ColumnWidth = 2.7;  // D
                    xlWorkSheet.Cells[1, 5].EntireColumn.ColumnWidth = 2.7; // E
                    xlWorkSheet.Cells[1, 6].EntireColumn.ColumnWidth = 2.7;  // F
                    xlWorkSheet.Cells[1, 7].EntireColumn.ColumnWidth = 2.7;  // G
                    xlWorkSheet.Cells[1, 8].EntireColumn.ColumnWidth = 2.7;  // H
                    xlWorkSheet.Cells[1, 9].EntireColumn.ColumnWidth = 2.7;  // I
                    xlWorkSheet.Cells[1, 10].EntireColumn.ColumnWidth = 2.7;  // J
                    xlWorkSheet.Cells[1, 11].EntireColumn.ColumnWidth = 2.7;  // K
                    xlWorkSheet.Cells[1, 12].EntireColumn.ColumnWidth = 2.7;  // L
                    xlWorkSheet.Cells[1, 13].EntireColumn.ColumnWidth = 2.7;  // M
                    xlWorkSheet.Cells[1, 14].EntireColumn.ColumnWidth = 2.7;  // N   
                    xlWorkSheet.Cells[1, 15].EntireColumn.ColumnWidth = 2.7;  // O
                    xlWorkSheet.Cells[1, 16].EntireColumn.ColumnWidth = 2.7;  // P
                    xlWorkSheet.Cells[1, 17].EntireColumn.ColumnWidth = 2.7;  // Q   

                    xlWorkSheet.Application.ErrorCheckingOptions.BackgroundChecking = false;
                    xlWorkSheet.Application.ErrorCheckingOptions.NumberAsText = false;
                }


            }
            catch (Exception ex)
            {
                string str = ex.Message;
            }
            finally
            {

            }
        }

        public void CreateDocument()
        {

        }

        public void OpenDocument(string filePath)
        {
            xlApp = new Excel.Application();
            xlApp.Visible = true;
            xlWorkBook = xlApp.Workbooks.Open(filePath);
            xlWorkSheet = (Excel.Worksheet)xlWorkBook.Worksheets.get_Item(1);
        }

        public void CreatePolyBagBarcodeDocument(string folderPath, string fileName, float width, float height, float topPadding)
        {
            try
            {
                xlApp.Visible = true;
                xlWorkBook = xlApp.Workbooks.Add(1);
                xlWorkSheet = (Excel.Worksheet)xlWorkBook.Sheets[1];
                xlWorkSheet.Application.ActiveWindow.SplitColumn = 2;

                float floatTop = 0;
                int startCoord = 0;

                List<string> lstFileNames = Directory.GetFiles(folderPath).Select(f => new FileInfo(f)).OrderBy(f => f.CreationTime).Select(m => m.FullName).ToList();

                foreach (string imagePath in lstFileNames)
                {
                    startCoord = (startCoord == 0) ? 1 : startCoord + 6;

                    xlWorkSheet.Shapes.AddPicture(imagePath, MsoTriState.msoFalse, MsoTriState.msoCTrue, 0, floatTop, width, height);
                    xlWorkSheet.Range[xlWorkSheet.Cells[startCoord, 1], xlWorkSheet.Cells[startCoord + 5, 6]].Merge();
                    xlWorkSheet.HPageBreaks.Add(xlWorkSheet.Cells[startCoord + 6, 1]);
                    floatTop += topPadding;
                }

                xlWorkSheet.Application.ActiveWindow.FreezePanes = true;
                xlWorkSheet.Application.ErrorCheckingOptions.BackgroundChecking = false;
                xlWorkSheet.Application.ErrorCheckingOptions.NumberAsText = false;

                //xlWorkBook.SaveAs(folderPath + fileName, Excel.XlFileFormat.xlWorkbookNormal);
                //xlWorkBook.Close(true);
                //xlApp.Quit();
                this.CloseDocument(folderPath + fileName);

                //Marshal.ReleaseComObject(xlApp);
            }
            catch (Exception ex)
            {
                string str = ex.Message;
            }
            finally
            {

            }
        }

        public void CreateCartonBarcodeDocument(string folderPath, string fileName, float width, float height, float topPadding)
        {
            try
            {
                xlApp.Visible = true;
                xlWorkBook = xlApp.Workbooks.Add(1);
                xlWorkSheet = (Excel.Worksheet)xlWorkBook.Sheets[1];
                xlWorkSheet.Application.ActiveWindow.SplitColumn = 2;

                float floatTop = 0;
                int startCoord = 0;

                List<string> lstFileNames = Directory.GetFiles(folderPath).Select(f => new FileInfo(f)).OrderBy(f => f.CreationTime).Select(m => m.FullName).ToList();

                foreach (string imagePath in lstFileNames)
                {
                    startCoord = (startCoord == 0) ? 1 : startCoord + 17;

                    xlWorkSheet.Shapes.AddPicture(imagePath, MsoTriState.msoFalse, MsoTriState.msoCTrue, 0, floatTop, width, height);
                    xlWorkSheet.Range[xlWorkSheet.Cells[startCoord, 1], xlWorkSheet.Cells[startCoord + 16, 9]].Merge();
                    xlWorkSheet.HPageBreaks.Add(xlWorkSheet.Cells[startCoord + 17, 1]);
                    floatTop += topPadding;
                }

                xlWorkSheet.Application.ActiveWindow.FreezePanes = true;
                xlWorkSheet.Application.ErrorCheckingOptions.BackgroundChecking = false;
                xlWorkSheet.Application.ErrorCheckingOptions.NumberAsText = false;

                //xlWorkBook.SaveAs(folderPath + fileName, Excel.XlFileFormat.xlWorkbookNormal);
                //xlWorkBook.Close(true);
                //xlApp.Quit();
                this.CloseDocument(folderPath + fileName);

                //Marshal.ReleaseComObject(xlApp);
            }
            catch (Exception ex)
            {
                string str = ex.Message;
            }
            finally
            {

            }
        }

        private void ReleaseObject(object obj)
        {
            try
            {
                System.Runtime.InteropServices.Marshal.ReleaseComObject(obj);
                obj = null;
            }
            catch (Exception)
            {
                obj = null;
            }
            finally
            {
                GC.Collect();
            }
        }

        /* public void CloseDocument()
         {
             xlWorkBook.Close(true, misValue, misValue);
             xlApp.Quit();

             ReleaseObject(xlWorkSheet);
             ReleaseObject(xlWorkBook);
             ReleaseObject(xlApp);
         }*/

        public void CloseDocument(string file)
        {
            try
            {
                xlWorkBook.Saved = true;
                xlWorkBook.SaveCopyAs(file);//, Excel.XlFileFormat.xlWorkbookNormal, misValue, misValue, misValue, misValue, Excel.XlSaveAsAccessMode.xlShared, misValue, misValue, misValue, misValue, misValue);
                xlWorkBook.Close(true, misValue, misValue);
                xlApp.Quit();

            }
            catch (System.Runtime.InteropServices.COMException comEx)
            {
                IndicoLogging.log.Error("Error occured while saving excel Create Excel Document Class", comEx);
            }
            finally
            {
                ReleaseObject(xlWorkSheet);
                this.ReleaseObject(xlWorkBook);
                this.ReleaseObject(xlApp);
                this.KillExcel();
            }
        }

        public void CloseDocument()
        {
            try
            {
                xlWorkBook.Saved = true;
                //xlWorkBook.SaveCopyAs(file);//, Excel.XlFileFormat.xlWorkbookNormal, misValue, misValue, misValue, misValue, Excel.XlSaveAsAccessMode.xlShared, misValue, misValue, misValue, misValue, misValue);
                xlWorkBook.Close(true, misValue, misValue);
                xlApp.Quit();

            }
            catch (System.Runtime.InteropServices.COMException comEx)
            {
                IndicoLogging.log.Error("Error occured while closing excel Create Excel Document Class", comEx);
            }
            finally
            {
                ReleaseObject(xlWorkSheet);
                this.ReleaseObject(xlWorkBook);
                this.ReleaseObject(xlApp);
                this.KillExcel();
            }
        }

        private void KillExcel()
        {
            Process[] AllProcesses = Process.GetProcessesByName("excel");

            // check to kill the right process
            foreach (Process ExcelProcess in AllProcesses)
            {
                //if (myHashtable.ContainsKey(ExcelProcess.Id) == false)
                ExcelProcess.Kill();
            }

            AllProcesses = null;
        }

        public void AddHeaderData(int row, int col, string data, string cell1, string cell2, bool isMergeCells, bool isFontBold, string fontName, int fontSize, Excel.XlHAlign alignment, string format)
        {
            xlWorkSheet.Cells[row, col] = data;
            xlWorkSheet.Cells[row, col].HorizontalAlignment = alignment;

            Excel.Range range = xlWorkSheet.get_Range(cell1, cell2);
            range.NumberFormat = format;
            range.MergeCells = isMergeCells;
            range.Font.Name = fontName;
            range.Font.Bold = isFontBold;
            range.Font.Size = fontSize;
            range.WrapText = true;
            //range.AutoFilter("1", "<>", Microsoft.Office.Interop.Excel.XlAutoFilterOperator.xlOr, "", true);
        }

        public void AddHeaderDataWithBackgroundColor(int row, int col, string data, string cell1, string cell2, bool isMergeCells, bool isFontBold, string fontName, int fontSize, Excel.XlHAlign alignment)
        {
            xlWorkSheet.Cells[row, col] = data;
            xlWorkSheet.Cells[row, col].HorizontalAlignment = alignment;

            Excel.Range range = xlWorkSheet.get_Range(cell1, cell2);
            range.NumberFormat = "Text";
            range.MergeCells = isMergeCells;
            range.Font.Name = fontName;
            range.Font.Bold = isFontBold;
            range.Font.Size = fontSize;
            range.WrapText = true;
            range.Cells.Interior.Color = System.Drawing.Color.Orange;
            //range.NumberFormat = "Text";
        }

        public void AddData(int row, int col, string data, string cell1, string cell2, string format, Excel.XlHAlign alignment)
        {
            xlWorkSheet.Cells[row, col].HorizontalAlignment = alignment;
            xlWorkSheet.Cells[row, col] = data;
            workSheet_range = xlWorkSheet.get_Range(cell1, cell2);
            workSheet_range.NumberFormat = format;

        }

        public void AddHeaderDataWithOrientation(int row, int col, string data, string cell1, string cell2, bool isMergeCells, bool isFontBold, string fontName, int fontSize, Excel.XlVAlign alignment, string format, int Orientation, System.Drawing.Color color)
        {
            xlWorkSheet.Cells[row, col] = data;
            xlWorkSheet.Cells[row, col].VerticalAlignment = alignment;

            Excel.Range range = xlWorkSheet.get_Range(cell1, cell2);
            range.Orientation = Orientation;
            range.NumberFormat = format;
            range.MergeCells = isMergeCells;
            range.Font.Name = fontName;
            range.Font.Bold = isFontBold;
            range.Font.Color = color;
            range.Font.Size = fontSize;
            range.WrapText = true;
            //range.AutoFilter("1", "<>", Microsoft.Office.Interop.Excel.XlAutoFilterOperator.xlOr, "", true);
        }

        public void AddDataWithBackgroundColor(int row, int col, string data, string cell1, string cell2, string format, Excel.XlHAlign alignment)
        {
            xlWorkSheet.Cells[row, col].HorizontalAlignment = alignment;
            xlWorkSheet.Cells[row, col] = data;
            workSheet_range = xlWorkSheet.get_Range(cell1, cell2);
            workSheet_range.Cells.Interior.Color = System.Drawing.Color.Orange;
            workSheet_range.NumberFormat = format;
        }

        public Excel.Range GetRange(string cell1, string cell2)
        {
            return xlWorkSheet.get_Range(cell1, cell2);
        }

        public void AutoFilter(int rownum)
        {
            xlWorkSheet.EnableAutoFilter = true;
            Excel.Range range = xlWorkSheet.get_Range("A6", "F" + rownum + "");
            range.AutoFilter("1", "<>", Microsoft.Office.Interop.Excel.XlAutoFilterOperator.xlOr, "", true);
            // xlWorkSheet.ListObjects.AddEx(Excel.XlListObjectSourceType.xlSrcRange, range, misValue, Microsoft.Office.Interop.Excel.XlYesNoGuess.xlNo, misValue).Name = "PriceList";
            // xlWorkSheet.ListObjects.get_Item("PriceList").TableStyle = "TableStyleMedium4";

        }

        public void BorderAround(string cell1, string cell2)
        {
            Excel.Range range = xlWorkSheet.get_Range(cell1, cell2);
            range.Borders.LineStyle = Excel.XlLineStyle.xlContinuous;
            range.Borders.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Black);
        }

        public void ResizeCell(int cell1, int cell2, int width)
        {
            xlWorkSheet.Cells[cell1, cell2].EntireColumn.ColumnWidth = width;
        }

        public string ReadCell(string cell)
        {
            return xlWorkSheet.get_Range(cell, misValue).Text;
        }

        public int ReturnExcelRowCount()
        {
            return (xlWorkSheet.UsedRange.Row + xlWorkSheet.UsedRange.Rows.Count - 1);
        }

        public void ConvertToPDF(string _filepath)
        {
            xlWorkBook.ExportAsFixedFormat(Microsoft.Office.Interop.Excel.XlFixedFormatType.xlTypePDF, _filepath, Microsoft.Office.Interop.Excel.XlFixedFormatQuality.xlQualityStandard, false, true, missing, missing, false, missing);            
        }

        public void ConvertToXPS(string _filepath)
        {
            xlWorkBook.ExportAsFixedFormat(Microsoft.Office.Interop.Excel.XlFixedFormatType.xlTypeXPS, _filepath, Microsoft.Office.Interop.Excel.XlFixedFormatQuality.xlQualityStandard, false, true, missing, missing, false, missing);
        }

        public void ConvertToText(string _filepath)
        {
            //xlWorkSheet.SaveAs(this.Path + @"\XMLCopy.xls", Excel.XlFileFormat.xlXMLSpreadsheet, missing, missing, false, false, Excel.XlSaveAsAccessMode.xlNoChange,missing, missing, missing, missing, missing);
            xlWorkSheet.SaveAs(_filepath, Excel.XlFileFormat.xlUnicodeText, missing, missing, false, false, Excel.XlSaveAsAccessMode.xlNoChange, missing, missing, missing);
            // xlWorkSheet.SaveAs(_filepath, " ", Encoding.UTF8);
        }
    }
}
